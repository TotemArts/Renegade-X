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

class Rx_Pawn_VoiceClass_Nod_Raveshaw extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Hit_DoMeAFavor'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Taunt_EasyTargets'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Hit_TorchThem'
TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Taunt_NoSenseOfStyle'

TauntLines(0)="Do me a favor";
TauntLines(1)="The infidels are easy targets.";
TauntLines(2)="Torch them.";
TauntLines(3)="No sense of style";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Kill_More'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Kill_TheSmell'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Hit_Unnecessary'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Taunt_WalkingInfront'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Kill_AtrociousSight'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Kill_SomethingOnYou'


//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Kill_TargetEliminated'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Taunt_WalkingInfront'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Kill_EasyTarget'

//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Death_2'
DeathSounds(1)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Death_01'
DeathSounds(2)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Death_02'
DeathSounds(3)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Death_03'
DeathSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Death_Death3'

//Take Damage sounds
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Hit_Fightme'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Hit_SpottedMove'
TakeDamageSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Hit_oof'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Hit_Ag'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit4'
TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit5'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Kill_KanePleased'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_raveshaw.Raveshaw_Hit_KillHim'
}





