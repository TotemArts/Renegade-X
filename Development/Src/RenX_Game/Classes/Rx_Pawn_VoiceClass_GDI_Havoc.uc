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

class Rx_Pawn_VoiceClass_GDI_Havoc extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_Dialogue.Havoc.s_kill_havoc_present'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Taunt_CareerChange'
TauntSounds(2)=SoundNodeWave'RX_Dialogue.Mission_05.S_Havoc_HaveAllTheFun'
TauntSounds(3)=SoundNodeWave'RX_Dialogue.Mission_05.S_Havoc_MyToughestChallenge'
TauntSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_VKill_BlowinStuffUp'
TauntSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Taunt_SeeWhatTheyWant'
TauntSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Kill_School'
TauntSounds(7)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Taunt_LoadofMe'

TauntLines(0)="I've got a present";
TauntLines(1)="Time for a career change";
TauntLines(2)="All the fun";
TauntLines(3)="My toughest challenge";
TauntLines(4)="Don't get tired";
TauntLines(5)="Sounds like the enemy";
TauntLines(6)="Pay attention";
TauntLines(7)="Get a load of me";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Taunt_06'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_TargetEliminated_01'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Taunt_07'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Taunt_Havoc_HomeAudience'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.GDI_Taunts_Havoc.Taunt_Havoc_ScoreOne'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Kill_Havoc_Woohoo'
KillConfirmSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Taunt_Havoc_RealTargets'
KillConfirmSounds(7)=SoundNodeWave'RX_Dialogue.Havoc.s_kill_havoc_keepemcoming'
KillConfirmSounds(8)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Taunt_Hobby'
KillConfirmSounds(9)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Kill_TellFriends'
KillConfirmSounds(10)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Taunt_Comedian'
KillConfirmSounds(11)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Kill_GetSome'
KillConfirmSounds(12)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Kill_BadIdea'
KillConfirmSounds(13)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Kill_MissMe'
KillConfirmSounds(14)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Kill_Record'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Taunts_GDISoldier_VehicleDestroyed'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Kill_Havoc_Woohoo'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Kill_Havoc_LightemUp'
DestroyVehicleSounds(3)=SoundNodeWave'RX_Dialogue.Havoc.s_kill_havoc_lovethatsound'
DestroyVehicleSounds(4)=SoundNodeWave'RX_Dialogue.Mission_05.S_Havoc_NowThatsAFire'
DestroyVehicleSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_VAssist_ChalkOne'
DestroyVehicleSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Taunt_LookEasy'
DestroyVehicleSounds(7)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Kill_RemindsMe'

//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Death_2'
DeathSounds(1)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Death_01'
DeathSounds(2)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Death_02'
DeathSounds(3)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Death_03'
DeathSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Death_Oops'

//Take Damage sounds
TakeDamageSounds(0)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Grunt_01'
TakeDamageSounds(1)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Grunt_02'
TakeDamageSounds(2)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Grunt_03'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_UnderFire_01'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Hit_Havoc_Comeon'
TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Hit_huhuhk'
	
BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_VKill_RepairThat'
BuildingDestroyedSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_VKill_DestroyedEnough'
BuildingDestroyedSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Taunt_SavingtheWorld'
BuildingDestroyedSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Kill_GottaHurt'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Taunt_FairFight'
AssistSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Kill_StayOff'
AssistSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_taunts_havoc.Havoc_Assist_NiceWork'
}





