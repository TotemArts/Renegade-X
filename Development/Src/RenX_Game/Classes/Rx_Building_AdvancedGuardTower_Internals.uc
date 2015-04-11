class Rx_Building_AdvancedGuardTower_Internals extends Rx_Building_Team_Internals;

var Rx_Sentinel_AGT_MG_Base turrets[4];
var Rx_Sentinel_AGT_Rockets_Base rocketTurret;

var const name MissileBone;
var const name MGBones[4];

simulated function Init( Rx_Building Visuals, bool isDebug )
{
	super.Init(Visuals,isDebug);
	if((WorldInfo.Netmode != NM_Client || WorldInfo.IsPlayingDemo()) && !Rx_Building_AdvancedGuardTower(Visuals).bWeaponsDisabled) {
	//if((WorldInfo.Netmode != NM_Client) && !Rx_Building_AdvancedGuardTower(Visuals).bWeaponsDisabled) {
		SetupDefences();
	}
}

function SetupDefences() 
{
	local Vector v;
	local int i;
	//WorldInfo.Rotation
	
	turrets[0]          = Spawn(class'Rx_Sentinel_AGT_MG_Base',Self,,v,rot( 0,0,0 ),,true);
	turrets[1]          = Spawn(class'Rx_Sentinel_AGT_MG_Base',Self,,v,rot( 0,0,0 ),,true);
	turrets[2]          = Spawn(class'Rx_Sentinel_AGT_MG_Base',Self,,v,rot( 0,0,0 ),,true);
	turrets[3]          = Spawn(class'Rx_Sentinel_AGT_MG_Base',Self,,v,rot( 0,0,0 ),,true); 
	rocketTurret        = Spawn(class'Rx_Sentinel_AGT_Rockets_Base',,,v,rot( 0,0,0 ),,true);
	rocketTurret.AgtLocation = self.Location;

	v = BuildingSkeleton.GetBoneLocation(MissileBone);
	v.Z += 150;
	rocketTurret.SetLocation(v);
	rocketTurret.Initialize();
	rocketTurret.Team = TeamID;
	rocketTurret.bCollideWorld = false;
	rocketTurret.SController.bSeeFriendly=false;
	Rx_Building_AdvancedGuardTower(BuildingVisuals).SentinelLocation = rocketTurret.location;

	for(i = 0; i < 4; i++) 
	{
		turrets[i].bCollideWorld = false;
		turrets[i].SetPhysics(PHYS_None);
		turrets[i].SController.bSeeFriendly=false;
		turrets[i].AgtLocation = self.location;
		turrets[i].Team = TeamID;

		v = BuildingSkeleton.GetBoneLocation(MGBones[i]);
		v.Z -= 30;
		turrets[i].setlocation(v);
		turrets[i].Initialize();
		turrets[i].SController.TargetWaitTime = 6;
	}
}

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) {
	local int i;
	
	if(bDestroyed)
		return;
	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	if(rocketTurret != None)
		rocketTurret.SController.NotifyTakeHit(EventInstigator,HitLocation,DamageAmount,DamageType,Momentum);
	if(bDestroyed) {
		rocketTurret.Destroy();
	}
	for(i = 0; i < 4; i++) {
		if(turrets[i] == None)
			continue;
		turrets[i].SController.NotifyTakeHit(EventInstigator,HitLocation,DamageAmount,DamageType,Momentum);
		if(bDestroyed) {
			turrets[i].SController.Cannon.Destroy();
			turrets[i].Destroy();			
		}
	}
}

function PowerLost()
{
	local int i;
	super.PowerLost();
	for(i = 0; i < 4; i++)
	{
		turrets[i].SController.Cannon.Destroy();
		turrets[i].Destroy();
	}
	rocketTurret.SController.Cannon.Destroy();
	rocketTurret.Destroy();
}

DefaultProperties
{
	MissileBone     = MissileTurret
	MGBones[0]      = MG_01
	MGBones[1]      = MG_02
	MGBones[2]      = MG_03
	MGBones[3]      = MG_04
	TeamID          = TEAM_GDI

	
	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_AGT_Destroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_AGT_UnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_AGT_Repaired'
	FriendlyBuildingSounds(BuildingDestructionImminent) = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_AGT_DestructionImminent'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_AGT_Destroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_AGT_UnderAttack'

	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'RX_BU_AGT.Mesh.SK_BU_AGT'
		PhysicsAsset=PhysicsAsset'RX_BU_AGT.Mesh.SK_BU_AGT_Physics'
	End Object

	AttachmentClasses.Add(Rx_BuildingAttachment_Door_GDI)
}
