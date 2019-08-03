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

class Rx_Pawn_VoiceClass_GDI_HotWire extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Taunts_PresentForYa'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Kill_Hotwire_KillCount'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Kill_FeelFree'
TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Hit_Support'

TauntLines(0)="I've got this for you";
TauntLines(1)="Increase killcount";
TauntLines(2)="Feel free to join in";
TauntLines(3)="Support is always good!";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Kill_TooEasy'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Kill_SayHi'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.HotWire_Kill_DontRun'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.HotWire_Kill_Later'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Kill_Hotwire_ItsMySpecialty'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Taunt_2MuchNoise'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.HotWire_Kill_Toomuch'

//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Death_01'
DeathSounds(1)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Death_02'
DeathSounds(2)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_01'
DeathSounds(3)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_03'

//Take Damage sounds
//TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Hit_Activity'
TakeDamageSounds(0)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_01'
TakeDamageSounds(1)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_02'
TakeDamageSounds(2)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_03'
//TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Hit_LastDay'
//TakeDamageSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Hit_Support'
//TakeDamageSounds(7)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Hit_Activity'
//TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Hit_LastDay'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Kill_PresentForYou'
AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_hotwire.Hotwire_Kill_BetterThings'

}





