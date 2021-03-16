class S_Building_Obelisk_Internals extends S_Building_Obelisk_Internals_Base;

DefaultProperties
{
	TeamID = TEAM_GDI
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh = SkeletalMesh'RX_BU_Oblisk.Mesh.SK_BU_Oblisk'
		PhysicsAsset = PhysicsAsset'RX_BU_Hand.Mesh.SK_HandofNod_Physics'
	End Object

	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_ObeliskDestroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_ObeliskUnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_ObeliskRepaired'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_EnemyObeliskDestroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_EnemyObeliskUnderAttack'

	AttachmentClasses.Add(S_BuildingAttachment_Door_BH)
}
