class Rx_DefencePRI extends PlayerReplicationInfo;

simulated function bool ShouldBroadCastWelcomeMessage(optional bool bExiting)
{
	return false;
}

simulated static function String LogNameOf(PlayerReplicationInfo PRI)
{
	return class'Rx_Game'.static.GetTeamName(PRI.GetTeamNum())$",ai,"$PRI.PlayerName;
}

DefaultProperties
{
}
