class Rx_GameObjective extends UTGameObjective;

/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(UTBot B)
{
	return UTSquadAI(B.Squad).FindPathToObjective(B,self);
}

DefaultProperties
{
}
