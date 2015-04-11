class Rx_Building_PowerPlant_GDI_Internals extends Rx_Building_PowerPlant_Internals;

DefaultProperties
{
	TeamID = TEAM_GDI
	 
	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDIPowerPlant_Destroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDIPowerPlant_UnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDIPowerPlant_Repaired'
	FriendlyBuildingSounds(BuildingDestructionImminent) = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDIPowerPlant_DestsructionImminent'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDIPowerPlant_Destroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDIPowerPlant_UnderAttack'
	

	AttachmentClasses.Add(Rx_BuildingAttachment_Door_GDI)
}
