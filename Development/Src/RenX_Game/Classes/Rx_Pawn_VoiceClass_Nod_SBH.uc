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

class Rx_Pawn_VoiceClass_Nod_SBH extends Rx_Pawn_VoiceClass
	abstract;

	
	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Kill_Die'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Kill_Laugh'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Taunt_Brother'
TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Taunt_Activity'
TauntSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Taunt_Covered'
TauntSounds(5)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Taunt_HardOnYourself'
TauntSounds(6)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Taunt_SafeWithMe'
TauntSounds(7)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Taunt_Silent'
TauntSounds(8)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Taunt_WithYou'

TauntLines(0)="Die!";
TauntLines(1)="Haha!";
TauntLines(2)="Brother";
TauntLines(3)="Activity";
TauntLines(4)="Covered";
TauntLines(5)="Hard on Yourself";
TauntLines(6)="Safe With Me";
TauntLines(7)="Silent";
TauntLines(8)="With You";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Kill_Die'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Kill_Infidel'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Kill_Laugh'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Kill_TakeThat'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Kill_AmIWrong'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Hit_FirePower'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Taunt_Maggot'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Kill_GloryofNod'
DestroyVehicleSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Taunt_TakeEmOut'

//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
DeathSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die2'
DeathSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die1'
DeathSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Hit_Wha'
DeathSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Hit_Wha2'

//Take Damage sounds
//TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Kill_Infidel'
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg3'
TakeDamageSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Hit_Wha2'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_StructureKill_NoBetter'
BuildingDestroyedSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_VKill_Shame'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Assist_Faith'
AssistSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_SBH.SBH_Assist_Proud'
}







