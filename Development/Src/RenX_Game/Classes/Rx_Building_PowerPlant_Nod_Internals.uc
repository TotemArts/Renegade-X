class Rx_Building_PowerPlant_Nod_Internals extends Rx_Building_PowerPlant_Internals;

DefaultProperties
{
	TeamID = TEAM_NOD

	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodPowerPlant_Destroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodPowerPlant_UnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodPowerPlant_Repaired'
	FriendlyBuildingSounds(BuildingDestructionImminent) = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodPowerPlant_DestructionImminent'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodPowerPlant_Destroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodPowerPlant_UnderAttack'

	AttachmentClasses.Add(Rx_BuildingAttachment_Door_Nod)
}
