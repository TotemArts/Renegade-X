class Rx_Building_WeaponsFactory_Internals extends Rx_Building_Team_Internals;

DefaultProperties
{
	TeamID = TEAM_GDI
	
	Begin Object Name=BuildingSkeletalMeshComponent
        SkeletalMesh = SkeletalMesh'RX_BU_WeaponsFactory.Mesh.SK_BU_WF_Skeleton'
        PhysicsAsset = PhysicsAsset'RX_BU_WeaponsFactory.Mesh.SK_BU_WF_Skeleton_Physics'
    End Object

	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_WeaponsFactory_Destroyed'
    FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_WeaponsFactory_UnderAttack'
    FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_WeaponsFactory_Repaired'
    FriendlyBuildingSounds(BuildingDestructionImminent) = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_WeaponsFactory_DestructionImminent'
    EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_WeaponsFactory_Destroyed'
    EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_WeaponsFactory_UnderAttack'

	AttachmentClasses.Add(Rx_BuildingAttachment_Door_GDI)
	AttachmentClasses.Add(Rx_BuildingAttachment_GarageDoor)
}
