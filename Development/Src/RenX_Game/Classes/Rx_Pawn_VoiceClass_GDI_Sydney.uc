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

class Rx_Pawn_VoiceClass_GDI_Sydney extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
	//Taunts
	TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Taunt_Hey'
	TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Kill_NeedADrink'
	TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Taunt_HandleThis'
	TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Taunt_StandOverHere'
	TauntSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Hit_LookOut'
	TauntSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Taunt_NotMuchTraining'

	TauntLines(0)="Hey.";
	TauntLines(1)="I could sure use a drink.";
	TauntLines(2)="Think you can handle this?";
	TauntLines(3)="I'll just... stand over here.";
	TauntLines(4)="Look out!";
	TauntLines(5)="Don't have much training";

	//Kill sounds
	KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Kill_SeeYa'
	KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Hit_HandsToSelf'
	KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Kill_WonderWhy'
	KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Taunts_Sydney_WasteofAmmo'
	KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Kill_GimmeAMinute'
	KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Kill_CoastClear'
	KillConfirmSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Kill_NowWhat'
	KillConfirmSounds(7)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Kill_WhatAmI'


	//Destroy Vehicle Sounds
	DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Kill_WonderWhy'
	DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Kill_YEAH'
	DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Taunts_Sydney_Gratifying'
	DestroyVehicleSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Kill_NoYouDont'
	DestroyVehicleSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Kill_HowOften'

	//Death Sounds
	DeathSounds(0)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Death_01'
	DeathSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Death_Death1'
	DeathSounds(2)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_01'
	//DeathSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Death_DeathLong'

	//Take Damage sounds
	TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Hit_MedicWhenYouNeedOne'
	TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Hit_ImHit'
	TakeDamageSounds(2)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_01'
	TakeDamageSounds(3)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_02'
	TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Hit_Grunt1'
	TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Hit_Ow'
	//TakeDamageSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Hit_LookOut'

	BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Taunts_Sydney_Gratifying'
	AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_sydney.Sydney_Kill_YEAH'

}





