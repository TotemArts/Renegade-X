class Rx_Weapon_RepairGun extends Rx_BeamWeapon;

var int HealAmount;
var int MinHealAmount;
var() AudioComponent BeamSound;
var SoundCue BeamSoundCue;

var SoundCue StartAltFireSound;
var SoundCue EndAltFireSound;

var UTLinkBeamLight BeamLight;
var UTEmitter BeamEndpointEffect; 

/** saved heal ammount (in case of high frame rate */
var float SavedHealAmmount;
var bool bHealing;
var bool bKeepFiring;

/** cached cast of attachment class for calling coloring functions */
var class<Rx_Attachment_RepairGun> RepGunAttachmentClass;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	WeaponFireSnd[0].VolumeMultiplier = 0.3;    
	RepGunAttachmentClass = class<Rx_Attachment_RepairGun>(AttachmentClass);
}

simulated function bool IsEnemy(actor actor)
{
	if (Instigator.GetTeamNum() == 0 && actor.GetTeamNum() == 1)
		return true;
	else if (Instigator.GetTeamNum() == 1 && actor.GetTeamNum() == 0)
		return true;
	else 
		return false;
}

simulated function RepairVehicle(Rx_Vehicle vehicle, float DeltaTime)
{
	vehicle.ResetTime = 0.0;
	if (!IsEnemy(vehicle) &&
		vehicle.Health > 0 &&
		vehicle.Health < vehicle.HealthMax)
	{
		Repair(vehicle,DeltaTime);
	}
	else
	{
		bHealing = false;
	}
}

simulated function RepairPawn(Rx_Pawn pawn, float DeltaTime)
{
	if (!IsEnemy(pawn) && pawn.Health > 0 && (pawn.Health < pawn.HealthMax || pawn.Armor < pawn.ArmorMax) )
	{
		Repair(pawn,DeltaTime);
	}
	else
	{
		bHealing = false;
	}
}

simulated function RepairBuilding(Rx_Building building, float DeltaTime)
{
	local int repairableHealth;
	local int maxRepairableHealth;
	
	
	if(Rx_GRI(WorldInfo.GRI).buildingArmorPercentage > 0 && (Rx_Building_Techbuilding(building) == None && Rx_CapturableMCT(building) == None))
	{
		repairableHealth = building.GetArmor();
		maxRepairableHealth = building.GetMaxHealth() * Rx_GRI(WorldInfo.GRI).buildingArmorPercentage/100;
	}
	else
	{
		repairableHealth = building.GetHealth();
		maxRepairableHealth = building.GetMaxHealth();
	}
	
	if (!IsEnemy(building) &&
		!building.IsDestroyed() &&
		Rx_Building_Techbuilding(building) == none && // Do not repair tech building exteriors
		repairableHealth < maxRepairableHealth) 
	{
		Repair(building,DeltaTime);
	}
	else
	{
		if(Rx_CapturableMCT(building) != None
				&& !(Rx_CapturableMCT(building).ScriptGetTeamNum() == Instigator.GetTeamNum() && building.GetHealth() >= building.GetMaxHealth()) )
			Repair(building,DeltaTime);
		else
			bHealing = false;
	}
}

simulated function RepairBuildingAttachment(Rx_BuildingAttachment buildingAttachment, float DeltaTime)
{
	local int repairableHealth;
	local int maxRepairableHealth;	
	
	if(Rx_GRI(WorldInfo.GRI).buildingArmorPercentage > 0 && (Rx_Building_Techbuilding(buildingAttachment.OwnerBuilding.BuildingVisuals) == None && Rx_CapturableMCT(buildingAttachment.OwnerBuilding.BuildingVisuals) == None))
	{
		repairableHealth = buildingAttachment.OwnerBuilding.BuildingVisuals.GetArmor();
		maxRepairableHealth = buildingAttachment.OwnerBuilding.BuildingVisuals.GetMaxHealth() * Rx_GRI(WorldInfo.GRI).buildingArmorPercentage/100;
	}
	else
	{
		repairableHealth = buildingAttachment.OwnerBuilding.BuildingVisuals.GetHealth();
		maxRepairableHealth = buildingAttachment.OwnerBuilding.BuildingVisuals.GetMaxHealth();
	}	
	
	// Is a tech building MCT
	if (Rx_BuildingAttachment_MCT(buildingAttachment) != None && Rx_Building_TechBuilding_Internals(buildingAttachment.OwnerBuilding) != None &&
		!(Rx_BuildingAttachment_MCT(buildingAttachment).ScriptGetTeamNum() == Instigator.GetTeamNum() && buildingAttachment.OwnerBuilding.GetHealth() >= buildingAttachment.OwnerBuilding.GetMaxHealth() ) )
	{
		Repair(buildingAttachment,DeltaTime);
	}
	else if (!IsEnemy(buildingAttachment) && !buildingAttachment.OwnerBuilding.IsDestroyed() 
				&& repairableHealth < maxRepairableHealth) 
	{
		Repair(buildingAttachment,DeltaTime);
	}
	else
	{
		bHealing = false;
	}
}

simulated function RepairDeployedActor(Rx_Weapon_DeployedActor deployedActor, float DeltaTime)
{
	if (!deployedActor.bCanNotBeDisarmedAnymore 
			&& (IsEnemy(deployedActor) || (Rx_Weapon_DeployedProxyC4(deployedActor) != None 
												&& CurrentFireMode == 0
												&& Rx_Weapon_DeployedProxyC4(deployedActor).OwnerPRI == Instigator.PlayerReplicationInfo)))
	{
		Repair(deployedActor,DeltaTime,true);
	}
	else if (deployedActor.HP > 0 &&
			deployedActor.HP < deployedActor.MaxHP)
	{
		Repair(deployedActor,DeltaTime,false);
	}
	else
	{
		bHealing = false;
	}
}

simulated function Repair(Actor actor, float DeltaTime, optional bool Disarm = false)
{
	local int ActualHealAmmount;

	bHealing = true;

	SavedHealAmmount += HealAmount * DeltaTime;
	ActualHealAmmount = int(SavedHealAmmount);
	
	if(ActualHealAmmount < MinHealAmount) 
	{
		return;
	}

	SavedHealAmmount -= ActualHealAmmount;

	ConsumeRepairAmmo(ActualHealAmmount);
	
	if (Disarm)
	{
		actor.TakeDamage(ActualHealAmmount, Instigator.Controller,Instigator.FlashLocation,Vect(0,0,0), InstantHitDamageTypes[0],,self);
	}
	else
	{
		actor.HealDamage(ActualHealAmmount, Instigator.Controller, InstantHitDamageTypes[0]);
	}
}

simulated function ConsumeRepairAmmo(int ActualHealAmount)
{
	if (ShotCost[0] <= 0)
		return;
	CurrentAmmoInClip = Max(CurrentAmmoInClip-ActualHealAmount,0);
	AddAmmo(-ActualHealAmount);
}

simulated function UpdateAttachment()
{
	if (UTPawn(Instigator) != none && Rx_Attachment_RepairGun(UTPawn(Instigator).CurrentWeaponAttachment) != none)
	{
		 Rx_Attachment_RepairGun(UTPawn(Instigator).CurrentWeaponAttachment).bHealing = bHealing;
	}
	if (Rx_Pawn(Instigator) != none)
	{
		Rx_Pawn(Instigator).SetIsRepairing(bHealing);
	}
}

simulated function ProcessBeamHit(vector StartTrace, vector AimDir, out ImpactInfo Impact, float DeltaTime) 
{
	SetFlashLocation(Impact.HitLocation);

	if (Rx_Vehicle(Impact.HitActor)!= none)
	{
		RepairVehicle(Rx_Vehicle(Impact.HitActor),DeltaTime);
	}
	else if (Rx_Pawn(Impact.HitActor) != none)
	{
		RepairPawn(Rx_Pawn(Impact.HitActor),DeltaTime);
	}
	else if (Rx_Building(Impact.HitActor) != none)
	{
		RepairBuilding(Rx_Building(Impact.HitActor),DeltaTime);
	}
	else if (Rx_BuildingAttachment(Impact.HitActor) != none)
	{
		RepairBuildingAttachment(Rx_BuildingAttachment(Impact.HitActor),DeltaTime);
	}
	else if (Rx_Weapon_DeployedActor(Impact.HitActor) != none)
	{
		RepairDeployedActor(Rx_Weapon_DeployedActor(Impact.HitActor),DeltaTime);
	}
	else// We haven't hit anything we can repair.
	{
		bHealing = false;
	}

	UpdateAttachment();
}

simulated function UpdateBeamEmitter(vector FlashLocation, vector HitNormal, actor HitActor)
{
	
	Super.UpdateBeamEmitter(FlashLocation, HitNormal, HitActor);
		
	if(!bHealing) {
		KillEndpointEffect();
	}
	
	if ( BeamLight != None )
	{
		if ( HitNormal == vect(0,0,0) )
		{
			BeamLight.Beamlight.Radius = 48;
			if ( FastTrace(FlashLocation, FlashLocation-vect(0,0,32)) )
				BeamLight.SetLocation(FlashLocation - vect(0,0,32));
			else
				BeamLight.SetLocation(FlashLocation);
		}
		else
		{
			BeamLight.Beamlight.Radius = 32;
			BeamLight.SetLocation(FlashLocation + 16*HitNormal);
		}
		BeamLight.BeamLight.SetLightProperties(, RepGunAttachmentClass.default.BeamColor);
	}
	
	if (bHealing && WorldInfo.NetMode != NM_DedicatedServer && Instigator != None && Instigator.IsFirstPerson())
	{
		if (BeamEndpointEffect != None && !BeamEndpointEffect.bDeleteMe)
		{
			BeamEndpointEffect.SetLocation(FlashLocation);
			BeamEndpointEffect.SetRotation(rotator(HitNormal));
			if(BeamEndpointEFfect.LifeSpan > 0.0)
			{
				BeamEndpointEffect.ParticleSystemComponent.ActivateSystem();
				BeamEndpointEFfect.LifeSpan = 0.0;
			}
			if (BeamEndpointEffect.ParticleSystemComponent.Template != RepGunAttachmentClass.default.BeamEndpointTemplateWhenHealing)
			{
				BeamEndpointEffect.SetTemplate(RepGunAttachmentClass.default.BeamEndpointTemplateWhenHealing, true);
			}
		}
		else
		{
			BeamEndpointEffect = Spawn(class'UTEmitter', self,, FlashLocation, rotator(HitNormal));
			BeamEndpointEffect.SetTemplate(RepGunAttachmentClass.default.BeamEndpointTemplateWhenHealing, true);
			BeamEndpointEFfect.LifeSpan = 0.0;
		}
		if(BeamEndpointEffect != none)
		{
			if(HitActor != none && UTPawn(HitActor) == none)
			{
				BeamEndpointEffect.SetFloatParameter('Touch',1);
			}
			else
			{
				BeamEndpointEffect.SetFloatParameter('Touch',0);
			}
		}
	}    
	
}

simulated state WeaponBeamFiring
{

	simulated function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		if ( (PlayerController(Instigator.Controller) != None) && Instigator.IsLocallyControlled() && ((BeamLight == None) || BeamLight.bDeleteMe) )
		{
			BeamLight = spawn(class'UTLinkBeamLight');
		}
		
		if(CurrentFireMode == 1)
		{
			bKeepFiring = true;
			SetTimer(20,false,'ResetKeepFiring');
		} 
		else
		{
			bKeepFiring = false;
			//ClearPendingFire(1);		
		}

		WeaponPlaySound(StartAltFireSound);
	}
	
	simulated function EndState(Name NextStateName)
	{
		WeaponPlaySound(EndAltFireSound);
		bHealing = false;
		UpdateAttachment();
		
		Super.EndState(NextStateName);

		if ( BeamLight != None )
			BeamLight.Destroy();

	}    
	
	simulated function RefireCheckTimer()
	{
		//local UTPlayerController PC;

		// If weapon should keep on firing, then do not leave state and fire again.
		if( ShouldRefire() )
		{
			/**
			// trigger a view shake for the local player here, because effects are called every tick
			// but we don't want to shake that often
			PC = UTPlayerController(Instigator.Controller);
			if (PC != None && LocalPlayer(PC.Player) != None && CurrentFireMode < FireCameraAnim.length && FireCameraAnim[CurrentFireMode] != None)
			{
				PC.PlayCameraAnim(FireCameraAnim[CurrentFireMode], (GetZoomedState() > ZST_ZoomingOut) ? PC.GetFOVAngle() / PC.DefaultFOV : 1.0);
			}
			*/
			return;
		}

		// Otherwise we're done firing, so go back to active state.
		GotoState('Active');

		// if out of ammo, then call weapon empty notification
		if( !HasAnyAmmo() )
		{
			WeaponEmpty();
		}
	}    

}

simulated function ResetKeepFiring()
{
	bKeepFiring = false;
	ClearPendingFire(1);
}

simulated function bool ShouldRefire()
{
	if(bKeepFiring)
		return true;
	return super.ShouldRefire();
}	

simulated function BeginFire(Byte FireModeNum)
{
	//ClearPendingFire(1); 
	if(FireModeNum == 1 && bKeepFiring && PendingFire(1))
	{
		bKeepFiring = false;
		return;
	}
	bKeepFiring = false;			
	super.BeginFire(FireModeNum);
}

simulated function StopFire(byte FireModeNum)
{
	if(FireModeNum == 1 && bKeepFiring)
		return;
	bKeepFiring = false;
	//ClearPendingFire(1);	
	super.StopFire(FireModeNum);
}


simulated event Destroyed()
{
	super.Destroyed();
	if (BeamLight != None)
	{
		BeamLight.Destroy();
	}

	KillEndpointEffect();
}

simulated function SetBeamEmitterHidden(bool bHide)
{
	if (BeamEmitter[CurrentFireMode] != None && bHide)
	{
		KillEndpointEffect();
	}
	Super.SetBeamEmitterHidden(bHide);
}

simulated function KillBeamEmitter()
{
	Super.KillBeamEmitter();

	KillEndpointEffect();
}

simulated function KillEndpointEffect()
{
	if (BeamEndpointEffect != None)
	{
		BeamEndpointEffect.ParticleSystemComponent.DeactivateSystem();
		BeamEndpointEffect.LifeSpan = 2.0;
	}
}

function bool CanHeal(Actor Other)
{
    return true;
}

function bool CanAttack(Actor Other)
{
	if(Other.GetTeamNum() != 255 && (Other.GetTeamNum() != Owner.GetTeamNum())) {
		return false;
	}
	return super.CanAttack(Other);
}

simulated function bool UsesClientSideProjectiles(byte FireMode)
{
	return false;
}

DefaultProperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_RepairGun.Mesh.SK_WP_RepairGun_1P_Alternative'
		AnimSets(0)=AnimSet'RX_WP_RepairGun.Anims.AS_RepairGun_1P'
		Animations=MeshSequenceA
		FOV=55.0
		Scale=1.5
	End Object
	
	ArmsAnimSet = AnimSet'RX_WP_RepairGun.Anims.AS_RepairGun_Arms'

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_RepairGun.Mesh.SK_WP_RepairGun_Back'
		Scale=1.0
	End Object

	AttachmentClass = class'Rx_Attachment_RepairGun'
	
	LeftHandIK_Offset=(X=0,Y=-10,Z=0)
	RightHandIK_Offset=(X=0,Y=0,Z=0)

	ShotCost(0)=0
	ShotCost(1)=0
	FireInterval(0)=+0.3
	FireInterval(1)=+0.3
	
	EquipTime=0.5
//	PutDownTime=0.4
	
	WeaponRange=600.0

	PlayerViewOffset=(X=5,Y=-3,Z=-2.5)

	LockerRotation=(pitch=0,yaw=0,roll=-16384)

	WeaponFireTypes(0)=EWFT_InstantHit
	//WeaponFireTypes(1)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=0
	InstantHitDamage(1)=0
	
	InstantHitMomentum(0)=0
	InstantHitMomentum(1)=0

	Spread(0)=0.0
	Spread(1)=0.0

	HealAmount = 20
	MinHealAmount = 1

	ClipSize = 999
	InitalNumClips = 1
	MaxClips = 1
	bHasInfiniteAmmo = false

	WeaponFireSnd[0]=SoundCue'RX_WP_RepairGun.Sounds.RepairGun_FireCue'
	WeaponFireSnd[1]=SoundCue'RX_WP_RepairGun.Sounds.RepairGun_FireCue'
	WeaponFireAnim[0]="WeaponFireLoop"
	WeaponFireAnim[1]="WeaponFireLoop"
	ArmFireAnim[0]="WeaponFireLoop"	
	ArmFireAnim[1]="WeaponFireLoop"	

	WeaponPutDownSnd=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_Equip'

	PickupSound=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_Equip'

	FireSocket="MuzzleFlashSocket"

	MuzzleFlashSocket="MuzzleFlashSocket"
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_MuzzleFlash_1P'
	MuzzleFlashDuration=3.3667
	MuzzleFlashLightClass=class'Rx_Light_RepairBeam'

	InventoryGroup=2
	InventoryMovieGroup=19

	WeaponIconTexture=Texture2D'RX_WP_RepairGun.UI.T_WeaponIcon_RepairGun'
	
	// AI Hints:
	MaxDesireability=0.7
	AIRating=+0.7
	CurrentRating=+0.3    
	bFastRepeater=true
	bInstantHit=true
	
	BeamTemplate[0]=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_Beam'
	BeamSockets[0]=MuzzleFlashSocket    
	BeamTemplate[1]=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_Beam'
	BeamSockets[1]=MuzzleFlashSocket    
	
	FiringStatesArray(0)=WeaponBeamFiring
	FiringStatesArray(1)=WeaponBeamFiring
	
	EndPointParamName=BeamEnd
	
	StartAltFireSound=SoundCue'RX_WP_RepairGun.Sounds.SC_RepairGun_Fire_Start'
	EndAltFireSound=SoundCue'RX_WP_RepairGun.Sounds.SC_RepairGun_Fire_Stop'

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_RepairGun'

}
