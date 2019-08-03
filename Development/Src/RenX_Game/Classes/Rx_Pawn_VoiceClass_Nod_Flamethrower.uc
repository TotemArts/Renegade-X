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

class Rx_Pawn_VoiceClass_Nod_Flamethrower extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.Taunts_FlameThrower_Ashes2Ashes'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameThrower_Kill_FTBros'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Angry_Hit_DIEINFIDEL'

TauntLines(0)="Ashes to ashes!";
TauntLines(1)="For the Brotherhood!";
TauntLines(2)="Die infidel!";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameThrower_Kill_Roasted'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Kill_Infidel1'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameThrower_Kill_FTBros'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.Flamethrower_Kill_BURN'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameTrooper_Kill_Hahaha'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameTrooper_Kill_TargetElim'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameThrower_Kill_FTBros'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameTrooper_Kill_Hahaha'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameTrooper_Kill_TargetElim'
//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
DeathSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die2'
DeathSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die1'
DeathSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_oog'
DeathSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'

//Take Damage sounds
//TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Angry_Hit_DIEINFIDEL'
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg3'
TakeDamageSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameThrower_Hit_There'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameTrooper_Hit_ToArms'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameTrooper_Hit_HoldStill'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.Taunts_FlameThrower_Ashes2Ashes'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_FlameTrooper.FlameTrooper_Kill_TooEasy'

PersonalVolumeModifier=0.40
}





