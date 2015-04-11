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

class Rx_Voice_GDI_Male extends Rx_Voice
	abstract;

defaultproperties
{
	
	AckSounds(0)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_Affirmative_01'
	AckSounds(1)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_Affirmative_02'
	AckSounds(2)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_Affirmative_03'
	
	InPositionSounds(0)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_Holding_01'
	
	AreaSecureSounds(0)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_AreaSecured_02'
	
	GotYourBackSounds(0)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_GotYourBack_01'
	GotYourBackSounds(1)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_MovingOut_01'
	GotYourBackSounds(2)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_MoveOut_01'
	
	SniperSounds(0)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_Sniper_01'
	SniperSounds(1)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_Sniper_02'
	
	IncomingSound(0)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_Incoming_03'

	MidFieldSound(0)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_Incoming_03'

	FriendlyFireSounds(0)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_FriendlyFire_01'
	FriendlyFireSounds(1)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_FriendlyFire_02'
	FriendlyFireSounds(2)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_FriendlyFire_03'
	FriendlyFireSounds(3)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_FriendlyFire_04'
	FriendlyFireSounds(4)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_FriendlyFire_05'
	FriendlyFireSounds(5)=SoundNodeWave'RX_CharSnd_Generic.GDI_Male.S_Soldier_GDI_FriendlyFire_06'

	ManDownSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_TakeCover'
	ManDownSounds(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Negative'
	
	EncouragementSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Encourage_01'
	EncouragementSounds(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Encourage_02'
	EncouragementSounds(2)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Encourage_03'
	EncouragementSounds(3)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Encourage_04'
	EncouragementSounds(4)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Encourage_05'
	
	UnderAttackSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_UnderFire_01'
	UnderAttackSounds(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_UnderFire_02'
	
	TauntSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_TargetEliminated_01'
	TauntSounds(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Taunt_01'
	TauntSounds(2)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Taunt_02'
	TauntSounds(3)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Taunt_06'
	TauntSounds(4)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_TimetoRocknRoll'
	TauntSounds(5)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Taunt_09'
	TauntSounds(6)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_GotaPresent_01'
	TauntSounds(7)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Taunt_04'
	TauntSounds(8)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Taunt_08'
	TauntSounds(9)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_TargetEliminated_01'
}





