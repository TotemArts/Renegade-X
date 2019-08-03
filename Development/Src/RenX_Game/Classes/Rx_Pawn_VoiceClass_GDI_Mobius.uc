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

class Rx_Pawn_VoiceClass_GDI_Mobius extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Taunts_Mobius_BetterUse'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Taunt_Distracted'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Taunt_OnlyMe'
TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Taunt_LeaveMEHere'
TauntSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Taunt_TiredBones'
TauntSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_CranialCap'
TauntSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Taunt_Waitrighthere'
TauntSounds(7)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Assist_FascinatingToWatch'


TauntLines(0)="Fascinating";
TauntLines(1)="Let's move, shall we?";
TauntLines(2)="It's only me";
TauntLines(3)="Don't leave me here!";
TauntLines(4)="My tired bones are aching.";
TauntLines(5)="Cranial capacity";
TauntLines(6)="I'll just... wait right here.";
TauntLines(7)="Fascinating to watch";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Hit_Apologies'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_Intense'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_LetsDoIt'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_Shaking'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_ItAppears'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_Tryshooting'
KillConfirmSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_Howmuchlonger'
KillConfirmSounds(7)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_Immoral'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_Destructive'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_VKill_Velocity'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_MarvelofScienceShort'
DestroyVehicleSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_GettingWorkedUp'
DestroyVehicleSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_Atmosphere'

//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Death_2'
DeathSounds(1)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Death_01'
DeathSounds(2)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Death_02'
DeathSounds(3)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Death_03'
DeathSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Death_Death3'

//Take Damage sounds
TakeDamageSounds(0)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Grunt_01'
TakeDamageSounds(1)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Grunt_02'
TakeDamageSounds(2)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Grunt_03'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Hit_BeenShot'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Hit_Aggressive'
TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit4'
TakeDamageSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit5'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_BKill_WrongBuilding'
BuildingDestroyedSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_VKill_StructuralIntegrity'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_TooMuch'
AssistSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_mobius.Mobius_Kill_Shaking'
}





