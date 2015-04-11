class Rx_Building_Refinery_Nod_Internals extends Rx_Building_Refinery_Internals;

DefaultProperties
{
	TeamID = TEAM_NOD
	
	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodRefinery_Destroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodRefinery_UnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodRefinery_Repaired'
	FriendlyBuildingSounds(BuildingDestructionImminent) = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodRefinery_DestructionImminent'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodRefinery_Destroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodRefinery_UnderAttack'
	
	AttachmentClasses.Add(Rx_BuildingAttachment_Door_Nod)
}
