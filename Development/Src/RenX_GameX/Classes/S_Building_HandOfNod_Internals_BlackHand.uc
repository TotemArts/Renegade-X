class S_Building_HandOfNod_Internals_BlackHand extends Rx_Building_HandOfNod_Internals;

DefaultProperties
{
	TeamID = TEAM_GDI
	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_HoNDestroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_HoNUnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_HoNRepaired'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_EnemyHoNDestroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_EnemyHoNUnderAttack'

	AttachmentClasses.Remove(Rx_BuildingAttachment_Door_Nod)	
	AttachmentClasses.Add(S_BuildingAttachment_Door_BH)
}
