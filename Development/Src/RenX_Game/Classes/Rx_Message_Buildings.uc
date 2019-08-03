class Rx_Message_Buildings extends UTLocalMessage;

var localized array<string> BuildingBroadcastMessages;

static function ClientReceive( PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
								optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);

	if(Switch == 2 || Switch == 3 || Switch == 4 || Switch == 5 )
	{
		if (P.GetTeamNum() == RelatedPRI_1.GetTeamNum() )
		{
			UTPlayerController(P).PlayAnnouncement(default.Class,Switch,RelatedPRI_1,OptionalObject);
		}
	}
	else
	{
		UTPlayerController(P).PlayAnnouncement(default.Class,Switch,RelatedPRI_1,OptionalObject);
	}
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( Rx_Building_Internals(OptionalObject) != None )
		return Rx_Building_Internals(OptionalObject).static.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
	return "";
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	if ( MessageIndex == 0 || MessageIndex == 1)
	{
		return Rx_Building_Team_Internals(OptionalObject).GetAnnouncment(MessageIndex, PC.GetTeamNum());
	}
	else if( MessageIndex == 2 || MessageIndex == 3 || MessageIndex == 4 || MessageIndex == 5 || MessageIndex == 6 || MessageIndex == 7) // Destruction Imminent(2), Buiding Healed(3), Building Captured (4) or Building Lost (5)  only go to teams
	{
		return Rx_Building_Team_Internals(OptionalObject).GetAnnouncment(MessageIndex, Rx_Building_Team_Internals(OptionalObject).GetTeamNum());
	}
	
			
	return none;
}

static function byte AnnouncementLevel(byte MessageIndex)
{
	return 1;
}

DefaultProperties
{
	AnnouncementVolume=5.0
}
