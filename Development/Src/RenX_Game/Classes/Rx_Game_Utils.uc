class Rx_Game_Utils extends Object;

enum STANCE
{
	STANCE_NEUTRAL,
	STANCE_ENEMY,
	STANCE_FRIENDLY
};

var transient Rx_Game Game;

/**
 * Checks the teams of the passed in actors and returns the stance, either Friendly, Enemy, or Neutral.
 */
static function STANCE GetStance(Actor inActorA, Actor inActorB)
{
	// If One actor isn't on GDI or Nod, Team will be neutral.
	if ((inActorA.GetTeamNum() != TEAM_GDI && inActorA.GetTeamNum() != TEAM_NOD) ||
		(inActorB.GetTeamNum() != TEAM_GDI && inActorB.GetTeamNum() != TEAM_NOD)) 
	{
		return STANCE_NEUTRAL;
	} 
	else if (inActorA.GetTeamNum() == inActorB.GetTeamNum())
	{
		return STANCE_FRIENDLY;
	}
	else
	{
		return STANCE_ENEMY;
	}
}

DefaultProperties
{
}
