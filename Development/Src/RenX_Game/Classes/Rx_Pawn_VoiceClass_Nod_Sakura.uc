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

class Rx_Pawn_VoiceClass_Nod_Sakura extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Taunts_Sakura_Sloppy'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Taunts_Sakura_SkillsPiqued'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Kill_Sting'

TauntLines(0)="Looking sloppy today";
TauntLines(1)="Thought skills had peaked";
TauntLines(2)="This is going to sting.";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Kill_DidThatHurt'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Kill_GetAnyBetter'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Kill_HandToSelf'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Kill_RealMan'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Kill_SayGoodNight'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Kill_Shortlived'
KillConfirmSounds(6)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Kill_Tag'
KillConfirmSounds(7)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Taunt_Gawking'
KillConfirmSounds(8)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Taunts_Sakura_MuchFight'
KillConfirmSounds(9)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Kill_CallAhead'


//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Kill_FlatTire'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Taunts_Sakura_SkillsPiqued'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Kill_Tag'
DestroyVehicleSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Kill_ThatsGood'

//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Death_01'
DeathSounds(1)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Death_02'
DeathSounds(2)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_01'
DeathSounds(3)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_03'

//Take Damage sounds
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Hit_Company'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Hit_CryingOutloud'
TakeDamageSounds(2)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_01'
TakeDamageSounds(3)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_02'
TakeDamageSounds(4)=SoundNodeWave'RX_CharacterSounds.Female.S_Female_Grunt_03'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_BKill_CleanYourRoom'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Sakura_Hit_GetEm'
AssistSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_sakura.Taunts_Sakura_TheySuck'
}





