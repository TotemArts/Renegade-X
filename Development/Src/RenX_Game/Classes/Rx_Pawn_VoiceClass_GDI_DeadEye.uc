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

class Rx_Pawn_VoiceClass_GDI_DeadEye extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Taunt_Incompetence'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Taunt_NotSatisfied'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Taunt_Shutit'
TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Taunt_StopTalking'
TauntSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Taunt_HandsBloody'
TauntSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Taunt_GuyBar'
TauntSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.Deadeye_Hit_Victims'

TauntLines(0)="Where do they train?"
TauntLines(1)="That's it?"
TauntLines(2)="Care to shut it?"
TauntLines(3)="Stop talking"
TauntLines(4)="Time to get my hands"
TauntLines(5)="A guy walks into a bar"
TauntLines(6)="Not now"

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Taunt_Opinion'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Kill_Stings'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Kill_Scum'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Kill_TargetDown'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.Deadeye_Kill_NotAllIHave'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Kill_Memories'
KillConfirmSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Kill_HopeForMore'
KillConfirmSounds(7)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.Deadeye_Kill_FilthyCre'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Kill_MoreFP'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Kill_AllWorkedUp'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Kill_Easier'

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
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Hit_Inc'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Hit_Hit1'
TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit4'
TakeDamageSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit5'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Kill_PresentForYa'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_deadeye.DeadEye_Kill_Idiots'
}





