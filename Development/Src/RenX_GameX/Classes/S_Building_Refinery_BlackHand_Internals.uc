class S_Building_Refinery_BlackHand_Internals extends Rx_Building_Refinery_Nod_Internals;

DefaultProperties
{	
	TeamID = TEAM_GDI

	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_TibRefDestroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_TibRefUnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_TibRefRepaired'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_EnemyTibRefDestroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_EnemyTibRefUnderAttack'

	AttachmentClasses.Remove(Rx_BuildingAttachment_Door_Nod)	
	AttachmentClasses.Add(S_BuildingAttachment_Door_BH)
}
