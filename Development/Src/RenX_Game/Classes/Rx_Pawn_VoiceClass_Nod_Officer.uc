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

class Rx_Pawn_VoiceClass_Nod_Officer extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Taunt_SomethingBetterToDo'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Taunt_KillThemAll'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Sloppy'

TauntLines(0)="Find something better";
TauntLines(1)="Kill them all.";
TauntLines(2)="Pretty sloppy";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_Challenge'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Taunts_NodOfficer_BetterTargets'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_AddTargetElim'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_OneForKane'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_TargetEliminated'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_TargetDown'
KillConfirmSounds(6)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_AllThatEasy'


//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_TargetEliminated'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_OneForKane'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_AddTargetElim'
//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.Nod_Sniper_Death_1'
DeathSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die2'
DeathSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die1'
DeathSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'


//Take Damage sounds
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Angry_Hit_DIEINFIDEL'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
TakeDamageSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg3'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Hit_GotInc'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_oog'
TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_DIE'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_DownGood'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.NodOfficer_Assist_WithoutYa'
AssistSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Assist_NiceWork'
AssistSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Assist_Talents'
}





