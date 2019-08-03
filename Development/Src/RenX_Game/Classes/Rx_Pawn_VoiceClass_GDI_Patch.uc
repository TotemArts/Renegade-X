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

class Rx_Pawn_VoiceClass_GDI_Patch extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Taunt_GettingTooOd'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_PresentForYou'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_DontResist'
TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Taunt_CallMe'
//TauntSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Taunt_GettingTooOd'

TauntLines(0)="Getting too old";
TauntLines(1)="Got a present for ya";
TauntLines(2)="Don't resist";
TauntLines(3)="Call me Patch.";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_NotThatBad'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_HereAllWeek'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_OldMemories'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_ProblemSolved'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Taunts_Apologies'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_ForGDI'
KillConfirmSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Taunts_Patch_WasteOfTime'
KillConfirmSounds(7)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_Aim2Please'
KillConfirmSounds(8)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_TooMuch'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_EnjoyWork'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Hit_LoveThis'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_VKill_Exposions'
DestroyVehicleSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Vkill_PaintJob'
DestroyVehicleSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_Excellent'
DestroyVehicleSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_TooGood4'

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
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Hit_YourMine'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Hit_HaveTargets'
TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Hit_HateGettingShot'
TakeDamageSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit4'
TakeDamageSounds(7)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit5'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_VKill_Exposions'
AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_patch.Patch_Kill_ProblemSolved'


}





