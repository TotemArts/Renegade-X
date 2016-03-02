class Rx_Building_CommCentre_Internals extends Rx_Building_TechBuilding_Internals
	notplaceable;

	
	
var private name IdleAnimName;
var Rx_Building_CommCentre_Internals CommCentreInternals;
var repnotify bool PlayIdleAnim;
	
	
	
`define GdiUnderAttackForGdiSound FriendlyBuildingSounds[BuildingUnderAttack]
`define GdiUnderAttackForNodSound FriendlyBuildingSounds[BuildingDestructionImminent]
`define NodUnderAttackForGdiSound EnemyBuildingSounds[BuildingUnderAttack]
`define NodUnderAttackForNodSound EnemyBuildingSounds[BuildingDestructionImminent]  



replication
{
	if (bNetDirty && Role == ROLE_Authority)
		PlayIdleAnim;
}

simulated event ReplicatedEvent( name VarName )
{
	if (VarName == 'PlayIdleAnim')
	{
		ToggleIdleAnimation();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

// Initialize the building and set the visual section of the building
simulated function Init(Rx_Building Visuals, bool isDebug )
{
	super.Init(Visuals, isDebug);
	if(WorldInfo.Netmode != NM_Client) {
		PlayIdleAnim = True;
		ToggleIdleAnimation();
	}
}

simulated function ToggleIdleAnimation()
{
	if(PlayIdleAnim)
	{
		BuildingSkeleton.PlayAnim(IdleAnimName,,True);
	}
	else
	{
		BuildingSkeleton.StopAnim();
	}
}


DefaultProperties
{
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh        		= SkeletalMesh'RX_BU_CommCentre.Meshes.SK_BU_CommCentre'
		AnimSets(0)         		= AnimSet'RX_BU_CommCentre.Anims.AS_BU_CommCentre'
		AnimTreeTemplate    		= AnimTree'RX_BU_CommCentre.Anims.AT_BU_CommCentre'
		PhysicsAsset     			= PhysicsAsset'RX_BU_CommCentre.Meshes.SK_BU_CommCentre_Physics'
		bEnableClothSimulation 	 	= True
		bClothAwakeOnStartup   	 	= True
		ClothWind              	 	= (X=100.000000,Y=100.000000,Z=20.000000)
	End Object

	`GdiUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDISilo_UnderAttack'
	`GdiUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDISilo_UnderAttack'

	`NodUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodSilo_UnderAttack'
	`NodUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodSilo_UnderAttack'
	
	TeamID          = 255
	IdleAnimName    = "Radar_Spin"
}
