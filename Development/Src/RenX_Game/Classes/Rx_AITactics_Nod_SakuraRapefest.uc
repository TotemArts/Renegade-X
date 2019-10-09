// Wanna be evil? Make the AI do a Sakura rush while enemies doesn't have vehicle factory

class Rx_AITactics_Nod_SakuraRapefest extends Rx_AITactics;

static function bool IsAvailable(Rx_Bot B)
{
	local WorldInfo GameWorld;
	local int EnemyTeam;

	GameWorld = class'WorldInfo'.static.GetWorldInfo();

	if(B.GetTeamNum() == 0)
		EnemyTeam = 1;
	else
		EnemyTeam = 0;

	if(!Rx_Game(GameWorld.Game).GetPurchaseSystem().AreVehiclesDisabled(EnemyTeam,None))
	{
		return false;
	}

	return Super.IsAvailable(B);

}

defaultproperties
{
	bPrioritizeInfantry = true
	GameTimeRelevancy = 120
	SkillMinimum = 5
	CreditsNeeded = 1000
	Orders=ATTACK
	bIsRush = True
	bAdvancedClassOnly =True

	PreparationTime = 50

	InfantryToMass[0] = class'Rx_FamilyInfo_Nod_Sakura'

	MinimumParticipant = 2;

	TacticName = "Sakura Rush"
}