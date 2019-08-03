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

class Rx_Pawn_VoiceClass_Nod_Technician extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_technician.Technician_Taunt_NowhereToHide'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_technician.Technician_Hit_IllFight'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_technician.Technician_Taunt_Wrench'

TauntLines(0)="There's no where to hide!";
TauntLines(1)="I'll fight you.";
TauntLines(2)="Where's my wrench?";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_technician.Technician_Kill_FieldTest'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_technician.Technician_Kill_Whoops'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_technician.Technician_Kill_Hurt'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_technician.Technician_Kill_NoRest'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_technician.Technician_Kill_UhOh'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_technician.Technician_Kill_FieldTest'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_technician.Technician_Kill_Transfer'

//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
DeathSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die2'
DeathSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die1'
DeathSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_oog'

//Take Damage sounds
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_technician.Technician_Hit_Help'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
TakeDamageSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg3'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_oog'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Kill_ForTheBH'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_technician.Technician_Assist_NiceOne'

PersonalVolumeModifier=0.60
}





