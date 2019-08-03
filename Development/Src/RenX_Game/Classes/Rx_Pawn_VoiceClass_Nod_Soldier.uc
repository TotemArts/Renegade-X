/*********************************************************
*
* File: RxVoice.uc
* Author: RenegadeX-Team
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/

class Rx_Pawn_VoiceClass_Nod_Soldier extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Kill_Hahaha'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Angry_Hit_DIEINFIDEL'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.NodSoldier_Assist_Talent'

TauntLines(0)="Hahaha!";
TauntLines(1)="Die infidel!";
TauntLines(2)="You've got talent!";


//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Taunts_MaskedVoice_Easy'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Kill_Infidel1'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Kill_ForTheBH'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Kill_TargetElim'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Kill_NextOne'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Taunts_NodSoldier_GottaBeTougher'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Kill_ForTheBH'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Kill_TargetElim'

//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
DeathSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die2'
DeathSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die1'
DeathSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_oog'
DeathSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'

//Take Damage sounds
//TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Angry_Hit_DIEINFIDEL'
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg3'
TakeDamageSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_LookOut'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_WatchOut'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_DIE'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Kill_ForTheBH'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Taunts_NodSoldier_ItsTheTW'
AssistSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Kill_PieceOfCake'

PersonalVolumeModifier=0.40
}





