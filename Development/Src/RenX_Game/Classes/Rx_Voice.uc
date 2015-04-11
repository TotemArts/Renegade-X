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

class Rx_Voice extends UTVoice //UTVoice_Robot
	abstract;


var Array<SoundNodeWave> TauntSounds;
var Array<SoundNodeWave> OrbKillSounds;
var Array<SoundNodeWave> ManDownSounds;
var Array<SoundNodeWave> EncouragementSounds;
var Array<SoundNodeWave> UnderAttackSounds;

const TAUNTINDEXSTART = 0;
const ORBKILLINDEXSTART = 500;	
const ENCOURAGEMENTINDEXSTART = 200;
const MANDOWNINDEXSTART = 300;
const UNDERATTACKINDEXSTART = 1800;
	
static function int GetTauntMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype, class<DamageType> DamageType)
{
	local UTBot B;
	local int R, TauntLength;
	TauntLength = default.TauntSounds.Length;
	R = Rand(TauntLength);

	B = UTBot(Sender);
	if ( B == None )
	{
		return R + TAUNTINDEXSTART;
	}
	if ( R == B.LastTauntIndex )
	{
		R = (R+1)%TauntLength;
	}
	B.LastTauntIndex = R;

	return R + TAUNTINDEXSTART;
}
	
static function int GetOrbKillMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype, class<DamageType> DamageType)
{
	if ( (default.OrbKillSounds.Length == 0) || (FRand() < 0.6) )
	{
		return GetTauntMessageIndex(Sender, Recipient, MessageType, DamageType);
	}
	return ORBKILLINDEXSTART + Rand(default.OrbKillSounds.Length);
}	
	
static function int GetEncouragementMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	if ( default.EncouragementSounds.Length == 0)
	{
		return -1;
	}
	return ENCOURAGEMENTINDEXSTART + Rand(default.EncouragementSounds.Length);
}

static function int GetManDownMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype, class<DamageType> DamageType)
{
	if ( default.ManDownSounds.Length == 0)
	{
		return -1;
	}
	return MANDOWNINDEXSTART + Rand(default.ManDownSounds.Length);
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	local UTPickupFactory F;
	local UTGameObjective O;
	local UTCTFFlag Flag;

	
	MessageIndex -= 500;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.TauntSounds.Length )
	{
		return default.TauntSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.AckSounds.Length )
	{
		return default.AckSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.FriendlyFireSounds.Length )
	{
		return default.FriendlyFireSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.GotYourBackSounds.Length )
	{
		return default.GotYourBackSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.NeedOurFlagSounds.Length )
	{
		return default.NeedOurFlagSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.SniperSounds.Length )
	{
		return default.SniperSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < 100 )
	{
		if ( (OptionalObject == None) || (MessageIndex == 10) )
		{
			return default.MidFieldSound;
		}
		O = UTGameObjective(OptionalObject);
		if ( O != None )
		{
			return O.GetLocationSpeechFor(PC, default.LocationSpeechOffset, MessageIndex);
		}
		F = UTPickupFactory(OptionalObject);
		if ( F != None )
		{
			return (default.LocationSpeechOffset < F.LocationSpeech.Length) ? F.LocationSpeech[default.LocationSpeechOffset] : None;
		}
		return default.MidFieldSound;
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.InPositionSounds.Length )
	{
		return default.InPositionSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex == 0 )
	{
		// Enemy sound - "incoming", orb/flag carrier, or vehicle
		return EnemySound(PC, OptionalObject);
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex == 0 )
	{
		return KilledVehicleSound(PC, OptionalObject);
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < 100 )
	{
		// ping enemy flag carrier
		Flag = UTCTFFlag(OptionalObject);

		if ( (Flag != None) && PC.WorldInfo.GRI.OnSameTeam(Flag, PC) )
		{
			Flag.LastLocationPingTime = PC.WorldInfo.TimeSeconds;
		}
		// enemy flag carrier here
		if ( MessageIndex == 2 )
			return default.EnemyFlagCarrierHighSound;
		else if ( MessageIndex == 3)
			return default.EnemyFlagCarrierLowSound;

		return default.EnemyFlagCarrierHereSound;
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < 100 )
	{
		MessageIndex -= 50;
		if ( MessageIndex < 0 )
		{
			return None;
		}
		if ( MessageIndex < default.HaveFlagSounds.Length )
		{
			return default.HaveFlagSounds[MessageIndex];
		}
		return None;
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.AreaSecureSounds.Length )
	{
		return default.AreaSecureSounds[MessageIndex];
	}
	MessageIndex -= 200;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex == 0 )
	{
		return default.GotOurFlagSound;
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.EncouragementSounds.Length )
	{
		return default.EncouragementSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	if ( MessageIndex < default.ManDownSounds.Length )
	{
		return default.ManDownSounds[MessageIndex];
	}
	MessageIndex -= 100;
	if ( MessageIndex < 0 )
	{
		return None;
	}
	return None;
}

static function int GetMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype, class<DamageType> DamageType)
{
    switch (Messagetype)
    {
		case 'TAUNT':
			return GetTauntMessageIndex(Sender, Recipient, MessageType, DamageType);
			//return -1;

		case 'INJURED':
			InitCombatUpdate(Sender, Recipient, MessageType);
			return -1;

		case 'STATUS':
			InitStatusUpdate(Sender, Recipient, MessageType);
			return -1;

		case 'INCOMING':
		case 'INCOMINGVEHICLE':
			SendEnemyStatusUpdate(Sender, Recipient, MessageType);
			return -1;

		case 'LOCATION':
			SendLocationUpdate(Sender, Recipient, MessageType, UTGame(Sender.WorldInfo.Game), Sender.Pawn);
			return -1;

		case 'INPOSITION':
			SendInPositionMessage(Sender, Recipient, MessageType);
			return -1;

		case 'MANDOWN':
			return GetManDownMessageIndex(Sender, Recipient, MessageType, DamageType);
			//return -1;

		case 'FRIENDLYFIRE':
			return GetFriendlyFireMessageIndex(Sender, Recipient, MessageType);

		case 'ENCOURAGEMENT':
			return GetEncouragementMessageIndex(Sender, Recipient, MessageType);
			//return -1;

		case 'FLAGKILL':
			return -1;

		case 'ACK':
			return GetAckMessageIndex(Sender, Recipient, MessageType);

		case 'SNIPER':
			InitSniperUpdate(Sender, Recipient, MessageType);
			return -1;

		case 'GOTYOURBACK':
			return GetGotYourBackMessageIndex(Sender, Recipient, MessageType);

		case 'HOLDINGFLAG':
			SetHoldingFlagUpdate(Sender, Recipient, MessageType);
			return -1;

		case 'GOTOURFLAG':
			return GOTOURFLAGINDEXSTART;

		case 'NEEDOURFLAG':
			return GetNeedOurFlagMessageIndex(Sender, Recipient, MessageType);

		case 'ENEMYFLAGCARRIERHERE':
			SendEnemyFlagCarrierHereUpdate(Sender, Recipient, MessageType);
			return -1;

		case 'VEHICLEKILL':
			SendKilledVehicleMessage(Sender, Recipient, MessageType);
			return -1;
	}
	return -1;
}


static function InitCombatUpdate(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	local int MessageIndex;
	local UTPlayerController PC;

	if ( Sender.Enemy == None )
	{
		if ( default.AreaSecureSounds.Length == 0 )
		{
			return;
		}
		MessageIndex = AREASECUREINDEXSTART + Rand(default.AreaSecureSounds.Length);
	}
	else
	{
		if ( default.UnderAttackSounds.Length == 0 )
		{
			return;
		}
		ForEach Sender.WorldInfo.AllControllers(class'UTPlayerController', PC )
		{
			if ( Sender.WorldInfo.TimeSeconds - PC.LastCombatUpdateTime < 25 )
			{
				return;
			}
			PC.LastCombatUpdateTime = Sender.WorldInfo.TimeSeconds;
			break;
		}
		MessageIndex = UNDERATTACKINDEXSTART + Rand(default.UnderAttackSounds.Length);
	}
	SendLocalizedMessage(Sender, Recipient, MessageType, MessageIndex);
}

	
defaultproperties
{
	LocationSpeechOffset=3
	bShowPortrait=false
	bIsConsoleMessage=false
	AnnouncementDelay=0.75
	AnnouncementPriority=-1
	AnnouncementVolume=0.0
}





