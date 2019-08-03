class Rx_Message_TechBuilding extends Rx_Message_Buildings;

static function ClientReceive( PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
								optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	super(UTLocalMessage).ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);

	UTPlayerController(P).PlayAnnouncement(default.Class,Switch,RelatedPRI_1,OptionalObject);
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return Rx_Building_Team_Internals(OptionalObject).GetAnnouncment(MessageIndex, PC.GetTeamNum());
}

DefaultProperties
{
	AnnouncementVolume=5.0
}
