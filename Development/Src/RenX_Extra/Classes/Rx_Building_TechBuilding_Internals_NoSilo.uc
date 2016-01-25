class Rx_Building_TechBuilding_Internals_NoSilo extends Rx_Building_Team_Internals
	notplaceable;

`define GdiCapSound	FriendlyBuildingSounds[BuildingRepaired]
`define GdiLostSound	FriendlyBuildingSounds[BuildingDestroyed]
`define NodCapSound	EnemyBuildingSounds[BuildingRepaired]
`define NodLostSound	EnemyBuildingSounds[BuildingDestroyed]
`define GdiUnderAttackForGdiSound FriendlyBuildingSounds[BuildingUnderAttack]
`define GdiUnderAttackForNodSound FriendlyBuildingSounds[BuildingDestructionImminent]
`define NodUnderAttackForGdiSound EnemyBuildingSounds[BuildingUnderAttack]
`define NodUnderAttackForNodSound EnemyBuildingSounds[BuildingDestructionImminent]

DefaultProperties
{
	
	`GdiCapSound	= SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_TechBuilding_Captured'
	`GdiLostSound	= SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_TechBuilding_Lost'

	`NodCapSound	= SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_TechBuilding_Captured'
	`NodLostSound	= SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_TechBuilding_Lost'
	
	`GdiUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_GDITech_UnderAttack'
	`GdiUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_GDITech_UnderAttack'

	`NodUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_NodTech_UnderAttack'
	`NodUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_NodTech_UnderAttack'

}