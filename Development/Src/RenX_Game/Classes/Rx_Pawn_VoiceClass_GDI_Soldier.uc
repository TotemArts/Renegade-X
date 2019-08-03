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

class Rx_Pawn_VoiceClass_GDI_Soldier extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.S_Soldier_GDI_MoveOut_01'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Taunts_GDISoldier_TERRORIST'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Taunts_GDISoldier_Payback'

TauntLines(0)="Go go go!";
TauntLines(1)="Terrorist!";
TauntLines(2)="Payback time!";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Taunts_GDISoldier_TargetWasted'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Taunts_GDISoldier_TargetDown'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Kill_IGotOne'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Kill_Heh'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Kill_TakeThat'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Kill_AnotherDown'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Taunts_GDISoldier_VehicleDestroyed'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDI_Soldier_Kill_VDestroyed'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Taunts_GDISoldier_WasteofAmmo'
DestroyVehicleSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDI_Soldier_VKill_ToomuchAmmo'

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
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Hit_OpenFire'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Hit_WatchIt'
TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Hit_oof'
TakeDamageSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Hit_Medic'
TakeDamageSounds(7)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit4'
TakeDamageSounds(8)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit5'


BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDI_Soldier_BKill_Destroyed'
AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Kill_Heh'


}





