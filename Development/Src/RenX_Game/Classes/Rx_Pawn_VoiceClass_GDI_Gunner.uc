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

class Rx_Pawn_VoiceClass_GDI_Gunner extends Rx_Pawn_VoiceClass
	abstract;

	
defaultproperties
{
//Taunts
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Taunts_NoAmmo'
TauntSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Taunt_OneLiners'
TauntSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Taunt_Relax'
TauntSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Taunt_SnappyLines'
TauntSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Taunt_Training'

TauntLines(0)="Don't have ammuntion"
TauntLines(1)="Enough with the one liners"
TauntLines(2)="Never relax"
TauntLines(3)="You'll need snappy lines"
TauntLines(4)="4 week training"

//Kill sounds
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_Apologies'
KillConfirmSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_Fleeing'
KillConfirmSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_NotThatFunny'
KillConfirmSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_Sorted'
KillConfirmSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_Toasty'
KillConfirmSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_Plenty4All'
KillConfirmSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_Doubt'


//Destroy Vehicle Sounds
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_ABitMuch'
DestroyVehicleSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_WarmsMeHeart'
DestroyVehicleSounds(2)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_VKill_NoWonder'
DestroyVehicleSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_PlentyToBlast'
DestroyVehicleSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_GoodTimes'

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
TakeDamageSounds(3)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Hit_GoingDown'
TakeDamageSounds(4)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Hit_HereWeGo'
TakeDamageSounds(5)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Hit_ImHit'
TakeDamageSounds(6)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit4'
TakeDamageSounds(7)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.GDISoldier_Hit_Hit5'
TakeDamageSounds(8)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Taunt_AllYouHave'
TakeDamageSounds(9)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Hit_TakeSomeOfThis'

BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_VKill_Destructive'
BuildingDestroyedSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_Wonders'

AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Assist_NotBad'
AssistSounds(1)=SoundNodeWave'RX_CharSnd_Generic.gdi_gunner.Gunner_Kill_GoodEnough'
}















