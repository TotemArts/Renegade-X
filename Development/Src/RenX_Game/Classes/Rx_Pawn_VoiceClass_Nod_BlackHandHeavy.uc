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

class Rx_Pawn_VoiceClass_Nod_BlackHandHeavy extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Kill_GloriousDay'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Kill_PoorlyTrained'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Kill_VictoryWillBeOurs'
TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Taunts_IHearInfidels'
TauntSounds(4)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Taunts_NeedForFaith'
TauntSounds(5)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.LCG_Taunt_Covered'
TauntSounds(6)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHand_Heavy_Taunt_Harder'

TauntLines(0)="This is a glorious day";
TauntLines(1)="All this poorly trained";
TauntLines(2)="Soon victory will be ours!";
TauntLines(3)="I hear infidels brother.";
TauntLines(4)="Need for faith";
TauntLines(5)="I have you covered";
TauntLines(6)="Harder than it has to be";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Taunts_AmmoNotWasted'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Kill_FireCleansed'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Kill_PoorlyTrained'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Kill_InfidelDown'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Kill_TargetEliminated'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHand_Heavy_Kill_NoEffort'
KillConfirmSounds(6)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.LCG_Kill_PanicInacc'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Taunts_AmmoNotWasted'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Kill_TargetEliminated'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Kill_TargetDestroyed'
DestroyVehicleSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.LCG_Kill_NotEvenTrying'
//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
DeathSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die2'
DeathSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Death_Die1'
DeathSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_oog'

//Take Damage sounds
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Hit_DetectInc'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg2'
TakeDamageSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_officerandsoldier.Nod_Soldier_Hit_Uhg3'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Hit_Target'


BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BHS.NodSniper_StructureDown'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHand_Heavy_Assist_Team'
AssistSounds(1)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Assist_MakeItSeemEasy'
AssistSounds(2)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.BlackHandHeavy_Assist_NiceWork'
AssistSounds(3)=SoundNodeWave'RX_CharSnd_Generic.Nod_BlackHand_Heavy.LCG_Assist_DoMyBest'

}





