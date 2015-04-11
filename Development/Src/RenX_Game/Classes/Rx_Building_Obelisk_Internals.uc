class Rx_Building_Obelisk_Internals extends Rx_Building_Team_Internals;

var Rx_Sentinel_Obelisk_Laser_Base laserSentinel;
var MaterialInstanceConstant CrystalGlowMIC;


simulated function Init(Rx_Building Visuals, bool isDebug )
{
	Super.Init(Visuals,isDebug);
	if(WorldInfo.NEtmode != NM_Client && !Rx_Building_Obelisk(Visuals).bLaserDisabled) 
	{
		SetupLaser();
	}	
}

function SetupLaser() 
{
	local vector v,v2;

	laserSentinel = Spawn(class'Rx_Sentinel_Obelisk_Laser_Base',,,,,,true);
	laserSentinel.SetOwner(self);
	laserSentinel.Team = self.TeamID;

	if(laserSentinel != none)
	{
		laserSentinel.bCollideWorld = true; //Turn off collision and translate, because collision may move the Sentinel away from the ceiling when it's spawned.
		v = BuildingSkeleton.GetBoneLocation('Ob_Fire');
		v.z += 100;
		laserSentinel.setFireStartLoc(v);
		v2 = BuildingVisuals.location;
		v2.z = v.z;
		v2 = v2 + Normal(v-v2)*100;
		laserSentinel.setlocation(v2);
		Rx_Building_Obelisk(BuildingVisuals).SentinelLocation = laserSentinel.location;

		laserSentinel.Initialize();
		CrystalGlowMIC = BuildingSkeleton.CreateAndSetMaterialInstanceConstant(0);

		Rx_SentinelWeapon_Obelisk(laserSentinel.SWeapon).CrystalGlowMIC = CrystalGlowMIC;
		laserSentinel.SController.TargetWaitTime = 6.0;
		laserSentinel.SController.bSeeFriendly=false;
		laserSentinel.SController.TargetWaitTime=3.0;
		laserSentinel.SController.SightCounterInterval=0.1;
		
		Rx_SentinelWeapon_Obelisk(laserSentinel.SWeapon).InitAndAttachMuzzleFlashes(BuildingSkeleton, 'Ob_Fire');
	}
}

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) 
{
	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	if(laserSentinel != None) 
	{
		laserSentinel.SController.NotifyTakeHit(EventInstigator,HitLocation,DamageAmount,DamageType,Momentum);
	}
	// FIXME: we need a Destroyed Event that fires when the building is destroyed
	if(bDestroyed) 
	{
		if(laserSentinel != None) {
			Rx_SentinelWeapon_Obelisk(laserSentinel.SWeapon).ClearTimer('crystalChargingGlow');
			Rx_SentinelWeapon_Obelisk(laserSentinel.SWeapon).CrystalGlowMIC.SetScalarParameterValue('Obelisk_Glow', 0.0); 
			Rx_SentinelWeapon_Obelisk(laserSentinel.SWeapon).FiringState=0;
			laserSentinel.SController.Cannon.Destroy();
			laserSentinel.Destroy();
		}
	}
}

function PowerLost()
{
	super.PowerLost();
	laserSentinel.SController.Cannon.Destroy();
	laserSentinel.Destroy();
}

DefaultProperties
{
	TeamID = TEAM_NOD
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh = SkeletalMesh'RX_BU_Oblisk.Mesh.SK_BU_Oblisk'
		PhysicsAsset = PhysicsAsset'RX_BU_Hand.Mesh.SK_HandofNod_Physics'
	End Object

	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_Obelisk_Destroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_Obelisk_UnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_Obelisk_Repaired'
	FriendlyBuildingSounds(BuildingDestructionImminent) = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_Obelisk_DestructionImminent'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Obelisk_Destroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Obelisk_UnderAttack'

	AttachmentClasses.Add(Rx_BuildingAttachment_Door_Nod)
}
