class Rx_Building_TeamSilo_GDI_Internals extends Rx_Building_TeamSilo_Internals;

defaultproperties
{
   FriendlyBuildingSounds(0)=SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDISilo_Destroyed'
   FriendlyBuildingSounds(1)=SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDISilo_UnderAttack'
   EnemyBuildingSounds(0)=SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDISilo_Destroyed'
   EnemyBuildingSounds(1)=SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDISilo_UnderAttack'

   BuildingSkeleton=BuildingSkeletalMeshComponent
   TeamID = TEAM_GDI
}
