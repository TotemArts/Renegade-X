class Rx_Building_Refinery_GDI_Internals extends Rx_Building_Refinery_Internals;

DefaultProperties
{
	TeamID = TEAM_GDI
		
	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDIRefinery_Destroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDIRefinery_UnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDIRefinery_Repaired'
	FriendlyBuildingSounds(BuildingDestructionImminent) = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDIRefinery_DestructionImminent'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDIRefinery_Destroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDIRefinery_UnderAttack'

	AttachmentClasses.Add(Rx_BuildingAttachment_Door_GDI)
}
