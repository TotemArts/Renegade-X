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

class Rx_Pawn_VoiceClass_GDI_McFarland extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)= SoundNodeWave'RX_CharSnd_Generic.gdi_mcfarland.McFarland_Taunt_GasMask' 
TauntSounds(1)= SoundNodeWave'RX_CharSnd_Generic.gdi_mcfarland.McFarland_Taunt_Laugh'
TauntSounds(2)=SoundNodeWave'RX_Dialogue.Mission_04.McFarland.S_McFarland_CoveOverHere'

TauntLines(0)="Gas mask";
TauntLines(1)="Hahaha";
TauntLines(2)="Tear you a new one";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_mcfarland.McFarland_Kill_GreatTrophy'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_mcfarland.McFarland_Kill_CleanUpDuty'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_mcfarland.McFarland_Kill_RememberMe'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_mcfarland.McFarland_Taunt_Laugh'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_mcfarland.McFarland_Kill_SeeThatComing'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_mcfarland.McFarland_VKill_Scared'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_mcfarland.McFarland_Kill_Roasted'
DestroyVehicleSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_mcfarland.McFarland_Taunt_Laugh'


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
TakeDamageSounds(7)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit4'
TakeDamageSounds(8)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit5'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_mcfarland.McFarland_Kill_SeeThatComing'
AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_mcfarland.McFarland_Taunt_Laugh'
}





