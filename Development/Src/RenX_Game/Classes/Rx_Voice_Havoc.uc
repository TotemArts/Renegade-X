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

class Rx_Voice_Havoc extends Rx_Voice //UTVoice_Robot
	abstract;

	
defaultproperties
{

//	LocationSpeechOffset=3

// Orders
	
	AckSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Affirmative_01'
	AckSounds(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Affirmative_02'
	InPositionSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_InPosition_01'
	AreaSecureSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_AreaSecure_01'
	GotYourBackSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_StickClose'
	GotYourBackSounds(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_ReportingIn'
	GotYourBackSounds(2)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_MovingToPosition'

	
// Battle field responces
	
//	ManDownSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_TakeCover'
//	ManDownSounds(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Negative'
//	UnderAttackSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_UnderFire_01'
//	UnderAttackSounds(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_UnderFire_02'
	SniperSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_UnderFire_01'
	IncomingSound(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Incoming_01'
//	IncomingSound(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Incoming_02'
//	IncomingSound(2)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Incoming_03'
//	IncomingSound(3)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Incoming_04'
	MidFieldSound(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Backup_01'
//	MidFieldSound(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Backup_02'
	FriendlyFireSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_FriendlyFire_01'
	FriendlyFireSounds(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_FriendlyFire_02'
	FriendlyFireSounds(2)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_FriendlyFire_03'
	FriendlyFireSounds(3)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_FriendlyFire_04'
	FriendlyFireSounds(4)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_FriendlyFire_05'


// Taunts
/*	
	EncouragementSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Encourage_01'
	EncouragementSounds(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Encourage_02'
	EncouragementSounds(2)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Encourage_03'
	EncouragementSounds(3)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Encourage_04'
	EncouragementSounds(4)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Encourage_05'
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
	WeaponTauntSounds(0)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Taunt_06'
	WeaponTauntSounds(1)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Taunt_07'
	WeaponTauntSounds(2)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Taunt_10'
	WeaponTauntSounds(3)=SoundNodeWave'RX_CharSnd_Havoc.Wave.S_Havoc_Taunt_11'
*/	
}





