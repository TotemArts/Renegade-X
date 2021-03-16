class S_Building_RepairFacility_BH_Internals extends Rx_Building_RepairFacility_Internals;

defaultproperties
{
	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_RepFacilityDestroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_RepFacilityUnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_RepFacilityRepaired'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_EnemyRepFacilityDestroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_EnemyRepFacilityUnderAttack'

   TeamID = TEAM_GDI
}
