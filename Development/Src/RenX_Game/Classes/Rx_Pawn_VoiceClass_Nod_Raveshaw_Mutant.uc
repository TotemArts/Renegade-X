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

class Rx_Pawn_VoiceClass_Nod_Raveshaw_Mutant extends Rx_Pawn_VoiceClass
	abstract;

// extend off raveshaw until we get sounds for mutant

defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_AReallyDumbLaugh'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Kill_IDontEvenKnow'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Taunt_Move'
TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Taunt_NotAmused'

TauntLines(0)="Laugh";
TauntLines(1)="Hungry or something???";
TauntLines(2)="Move";
TauntLines(3)="Not Amused";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Kill_Bad'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Kill_FireGood'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Kill_Haaah'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Kill_HahaHa'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Kill_ThinkFunny'


//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Taunt_Ponder'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Taunt_Sigh'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_VKill_DestDest'
DestroyVehicleSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_VKill_EEDestroyed'

//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Taunt_Sigh'
DeathSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_HitHeavy1'
DeathSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_HeavyHit2'

//Take Damage sounds
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_HeavyHit2'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Hit1'
TakeDamageSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_HitHeavy1'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Hit2'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_BuildingKill_StrBuilDestr'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_MutantRaveshaw.MutantRav_Assist_Mine'
}





