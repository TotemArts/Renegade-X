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

class Rx_Pawn_VoiceClass_GDI_RocketSoldier extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)= SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDI_BlackGuy_Taunt_ShouldntDoThis'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDIBlackGuy_Kill_UnderControl'

TauntLines(0)="I shouldn't be doing this!";
TauntLines(1)="Situation under control";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDI_BlackGuy_Kill_TargetEliminated'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDI_BlackGuy_Kill_SoEasy'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Taunt_BlackGuy_StayDown'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDIBlackGuy_Kill_TakeThatE'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDI_Black_Guy_Kill_TargetDestroyed'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDI_BlackGuy_Kill_SoEasy'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDI_BlackGuy_Kill_Extinguisher'

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
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDIBlackGuy_Hit_TakingFire'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Hit_oof'
TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit4'
TakeDamageSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit5'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDIBlackGuy_Kill_UnderControl'
AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDI_BlackGuy_Kill_SoEasy'
}





