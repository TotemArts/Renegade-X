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

class Rx_Pawn_VoiceClass_Nod_BlackHandSniper extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.NodSniper_Taunt_EasyTimeLong'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.NodSniper_Taunt_GDIAbominationLong'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_DIE'
TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.BHS_Kill_Weaklings'

TauntLines(0)="Easy a time";
TauntLines(1)="GDI abomination";
TauntLines(2)="Die!";
TauntLines(3)="Tired of weaklings";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.NodSniper_Kill_Gotchya'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.Nod_Sniper_Kill_Tracking'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.NodSniper_Kill_Heh'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.NodSniper_Kill_StayThere'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Taunts_AmmoNotWasted'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.NodSniper_Kill_Gotchya'

//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.Nod_Sniper_Death_1'
DeathSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die2'
DeathSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die1'
DeathSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'


//Take Damage sounds
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.NodSniper_Hit_TakingFire'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
TakeDamageSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.NodSniper_Hit_Hit1'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.NodSniper_Hit_Hit2'
//TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_DIE'


BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.NodSniper_StructureDown'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.NodSniper_Kill_Heh'

}





