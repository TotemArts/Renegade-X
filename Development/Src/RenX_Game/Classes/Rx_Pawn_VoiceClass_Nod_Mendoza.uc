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

class Rx_Pawn_VoiceClass_Nod_Mendoza extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Kill_Paid'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Hit_GetitOn'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Taunt_ShowMe'
TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Taunt_KillMeIfYouCan'
TauntSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Hit_Number'

TauntLines(0)="Not getting paid";
TauntLines(1)="Let's get it on!";
TauntLines(2)="Show me what you've got!";
TauntLines(3)="Kill me if you can!";
TauntLines(4)="I've got your number.";

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Kill_Easy'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Kill_LetDown'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Kill_LineEmUp'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Kill_MyPleasure'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Hit_Maggot'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Hit_Fool'
KillConfirmSounds(6)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Kill_MissedVitals'
KillConfirmSounds(7)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Kill_Training'

//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Kill_Easy'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Kill_PaidExtra'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Taunt_Coward'
DestroyVehicleSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Hit_FightLikeAMan'
DestroyVehicleSounds(4)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Kill_Waste'

//Death Sounds
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Death_2'
DeathSounds(1)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Death_01'
DeathSounds(2)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Death_02'
DeathSounds(3)=SoundNodeWave'RX_CharacterSounds.Male.S_Male_Death_03'
DeathSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Death_Death3'

//Take Damage sounds
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Hit_FightingTime'
TakeDamageSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Hit_Ag'
TakeDamageSounds(2)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Hit_Infidel'
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Hit_BrintItOn'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.Hit_oof'
TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit4'
TakeDamageSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit5'
TakeDamageSounds(7)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Hit_Lesson'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Kill_AllWorkedUp'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.nod_taunts_mendoza.Mendoza_Taunt_Sheep'

}





