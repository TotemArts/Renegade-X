class Rx_ScriptedBotPRI extends PlayerReplicationInfo;

simulated static function String LogNameOf(PlayerReplicationInfo PRI)
{
	return class'Rx_Game'.static.GetTeamName(PRI.GetTeamNum())$","$"ScriptedBot";
}

simulated function bool ShouldBroadCastWelcomeMessage(optional bool bExiting)
{
	return false;
}