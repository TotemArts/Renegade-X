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

class Rx_Pawn_VoiceClass_Nod_ChemicalTrooper extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Kill_TooEasy'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Kill_Laugh'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Kill_TakeVitamins'

TauntLines(0)="All too easy!";
TauntLines(1)="Hahahahaha";
tauntLines(2)="Take your vitamins.";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Kill_OneLess'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Kill_TakeThat'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Kill_Melted'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemSoldier_Kill_DeepBreath'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Kill_Gotcha'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Kill_Disentegrated'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Kill_Laugh'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Kill_Gotcha'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Kill_Burn'

//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Death_DieHard2'
DeathSounds(1)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Death_DieHard'
DeathSounds(2)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Death_DieVeryHard'
DeathSounds(3)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Death_Die1'

//Take Damage sounds
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Hit_SprayEm'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Hit_GotMe'
TakeDamageSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg3'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Hit_Prepare'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Hit_AttackBreh'
TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Hit_HoldStill'
TakeDamageSounds(6)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Hit_Prep4Death'
TakeDamageSounds(7)=SoundNodeWave'RX_CharSnd_Generic.ChemTrooper.ChemTrooper_Hit_HaveyouNow'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.Taunts_FlameThrower_Ashes2Ashes'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameTrooper_Kill_TooEasy'
}





