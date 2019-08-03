class Rx_AITactics_Opening extends Rx_AITactics;

defaultproperties
{
	bPrioritizeInfantry = true
	CreditsNeeded = 0
	bIsRush = true;
	Orders=ATTACK
	SkillMinimum = 3

	PreparationTime = 20

	bPersistentUntilTimelimit = true
	TacticsTimeLimit = 120

	bTimeLimited = true
	bCanExpire = true

	TimeUntilRelevancyExpires = 150

	TacticName = "Opening Rush"
	MinimumParticipant = 3;
}