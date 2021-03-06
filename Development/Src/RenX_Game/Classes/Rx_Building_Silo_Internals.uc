class Rx_Building_Silo_Internals extends Rx_Building_TechBuilding_Internals
	notplaceable;

var float CreditsGain;  
  
  
`define GdiUnderAttackForGdiSound FriendlyBuildingSounds[BuildingUnderAttack]
`define GdiUnderAttackForNodSound FriendlyBuildingSounds[BuildingDestructionImminent]
`define NodUnderAttackForGdiSound EnemyBuildingSounds[BuildingUnderAttack]
`define NodUnderAttackForNodSound EnemyBuildingSounds[BuildingDestructionImminent]  
  
simulated function PostBeginPlay() 
{
	super.PostBeginPlay();
	if(ROLE == ROLE_Authority) {
		SetTimer(1.0,true,'AddCreditsToOwningTeamTimer');
	}
} 

function AddCreditsToOwningTeamTimer()
{
	local PlayerReplicationInfo PRI;
	
	if(GetTeamNum() == TEAM_UNOWNED) {
		return;
	}
	
	foreach WorldInfo.GRI.PRIArray(pri)
	{
		if(Rx_PRI(pri) != None && pri.GetTeamNum() == GetTeamNum()) {
			Rx_PRI(pri).AddCredits(CreditsGain);
		}
	}
}

DefaultProperties
{
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh        		= SkeletalMesh'RX_BU_Silo.Meshes.SK_BU_Silo'
		AnimSets(0)         		= AnimSet'RX_BU_Silo.Anims.AS_BU_Silo'
		AnimTreeTemplate    		= AnimTree'RX_BU_Silo.Anims.AT_BU_Silo'
		PhysicsAsset     			= PhysicsAsset'RX_BU_Silo.Meshes.SK_BU_Silo_Physics'
		bEnableClothSimulation 	 	= True
		bClothAwakeOnStartup   	 	= True
		ClothWind              	 	= (X=100.000000,Y=-100.000000,Z=20.000000)
	End Object

	`GdiUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDISilo_UnderAttack'
	`GdiUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDISilo_UnderAttack'

	`NodUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodSilo_UnderAttack'
	`NodUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodSilo_UnderAttack'
	
	TeamID          = 255
	CreditsGain 	= 0.5
}
