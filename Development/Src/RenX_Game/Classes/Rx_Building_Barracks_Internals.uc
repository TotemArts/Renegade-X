class Rx_Building_Barracks_Internals extends Rx_Building_Team_Internals;

DefaultProperties
{
	TeamID = TEAM_GDI
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh            = SkeletalMesh'RX_BU_Barracks.Mesh.SK_BU_GDI_BAR'
		PhysicsAsset            = PhysicsAsset'RX_BU_Barracks.Mesh.SK_BU_GDI_BAR_Physics'
		bEnableClothSimulation  = True
		bClothAwakeOnStartup    = True
		ClothWind               = (X=-10.000000,Y=50.000000,Z=5.000000)
	End Object

	AttachmentClasses.Add(Rx_BuildingAttachment_Door_GDI)

	
	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Barracks_Destroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Barracks_UnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Barracks_Repaired'
	FriendlyBuildingSounds(BuildingDestructionImminent) = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Barracks_DestructionImminent'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_Barracks_Destroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_Barracks_UnderAttack'
}
