class Rx_Building_Obelisk_Internals extends Rx_Building_Obelisk_Internals_Base;

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
