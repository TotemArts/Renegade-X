class Rx_Building_MedicalCentre_Internals extends Rx_Building_TechBuilding_Internals
	notplaceable;

var int MaxHealthIncrease, RegenRate;  
  
  
`define GdiUnderAttackForGdiSound FriendlyBuildingSounds[BuildingUnderAttack]
`define GdiUnderAttackForNodSound FriendlyBuildingSounds[BuildingDestructionImminent]
`define NodUnderAttackForGdiSound EnemyBuildingSounds[BuildingUnderAttack]
`define NodUnderAttackForNodSound EnemyBuildingSounds[BuildingDestructionImminent]  
  
simulated function PostBeginPlay() 
{
	super.PostBeginPlay();
	if(ROLE == ROLE_Authority) {
		SetTimer(1.0,true,'HealOwningTeam');
	}
} 

function HealOwningTeam()
{
	local Rx_Pawn PawnToHeal; 
	
	if(GetTeamNum() == TEAM_UNOWNED) {
		return;
	}
	
	foreach AllActors(class'Rx_Pawn', PawnToHeal)
	{
		if(PawnToHeal.GetTeamNum() == GetTeamNum() && PawnToHeal.Health > 0) {
			PawnToHeal.regenerateHealth(RegenRate);
			PawnToHeal.SetMaxHealth(MaxHealthIncrease); 			
		}
	}
}

function IncreaseTeamMaxHealth()
{
	local Rx_Pawn PawnToIncrease ; 
	
	foreach AllActors(class'Rx_Pawn', PawnToIncrease)
	{
		if(PawnToIncrease.GetTeamNum() == GetTeamNum() && PawnToIncrease.Health > 0) {
			PawnToIncrease.SetMaxHealth(MaxHealthIncrease); 
		}
	}
	 
}

function ChangeTeamReplicate(TEAM ToTeam, optional bool bChangeFlag=false)
{
	super.ChangeTeamReplicate(ToTeam,bChangeFlag); 
	IncreaseTeamMaxHealth(); 
}

DefaultProperties
{
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh        		= SkeletalMesh'RX_BU_MedicalCentre.Mesh.SK_BU_Silo'
		AnimSets(0)         		= AnimSet'RX_BU_Silo.Anims.AS_BU_Silo'
		AnimTreeTemplate    		= AnimTree'RX_BU_Silo.Anims.AT_BU_Silo'
		PhysicsAsset     			= PhysicsAsset'RX_BU_Silo.Meshes.SK_BU_Silo_Physics'
		bEnableClothSimulation 	 	= True
		bClothAwakeOnStartup   	 	= True
		ClothWind              	 	= (X=100.000000,Y=-100.000000,Z=20.000000)
	End Object

	
	`GdiUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_GDITech_UnderAttack'
	`GdiUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_GDITech_UnderAttack'

	`NodUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_NodTech_UnderAttack'
	`NodUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_NodTech_UnderAttack'
	
	TeamID          = 255
	
	MaxHealthIncrease = 150
	RegenRate = 2
}
