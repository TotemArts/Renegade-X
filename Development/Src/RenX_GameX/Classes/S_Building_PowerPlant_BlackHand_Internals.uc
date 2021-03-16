class S_Building_PowerPlant_BlackHand_Internals extends Rx_Building_PowerPlant_Nod_Internals;

DefaultProperties
{
	TeamID = TEAM_GDI
	 
	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_PPDestroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_PPUnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_PPRepaired'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_EnemyPPDestroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_EnemyPPUnderAttack'

	AttachmentClasses.Remove(Rx_BuildingAttachment_Door_Nod)	
	AttachmentClasses.Add(S_BuildingAttachment_Door_BH)	
}
