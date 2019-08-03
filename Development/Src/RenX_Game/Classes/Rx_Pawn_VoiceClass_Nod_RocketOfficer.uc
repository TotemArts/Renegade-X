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

class Rx_Pawn_VoiceClass_Nod_RocketOfficer extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Taunt_SomethingBetterToDo'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Taunts_HeavyVoice_GloriousDay'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.NodOfficer_Taunt_Munchies'
TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Taunts_NodOfficerDeep_FTBros'

TauntLines(0)="Find something better";
TauntLines(1)="Glorious day for Nod";
TauntLines(2)="Anyone got any munchies?";
TauntLines(3)="For the Brotherhood!";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_Challenge'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Taunts_NodOfficer_BetterTargets'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_GloryofNod'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Taunts_NodOfficerDeep_Laugh'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Kill_DownGood'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Taunts_NodOfficerDeep_OneLess'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Taunts_NodOfficerDeep_Laugh'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Taunts_NodOfficer_GloryofNod'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Taunts_NodOfficer_BetterTargets'
//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.Nod_Sniper_Death_1'
DeathSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die2'
DeathSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die1'
DeathSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'


//Take Damage sounds
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Hit_Die'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
TakeDamageSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg3'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Hit_Fireline'
//TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Taunts_NodOfficerDeep_FTBros'
//TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_DIE'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Taunts_NodOfficer_GloryofNod'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officer.Nod_Officer_Assist_GoodJob'
}





