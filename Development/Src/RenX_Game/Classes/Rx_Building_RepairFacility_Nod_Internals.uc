class Rx_Building_RepairFacility_Nod_Internals extends Rx_Building_RepairFacility_Internals;

defaultproperties
{
   FriendlyBuildingSounds(BuildingDestroyed)		=	SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodRepairFacility_Destroyed'
   FriendlyBuildingSounds(BuildingUnderAttack)		=	SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodRepairFacility_UnderAttack'
   FriendlyBuildingSounds(BuildingRepaired)		=	SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodRepairFacility_Repaired'
   FriendlyBuildingSounds(BuildingDestructionImminent) 	=	SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodRepairFacility_DestructionImminent'
   EnemyBuildingSounds(BuildingDestroyed)		=	SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodRepairFacility_Destroyed'
   EnemyBuildingSounds(BuildingUnderAttack)		=	SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodRepairFacility_UnderAttack'

   TeamID = TEAM_NOD
}
