class Rx_AITactics_Nod_CommandoDeathball extends Rx_AITactics;

defaultproperties
{
	bPrioritizeInfantry = true
	GameTimeRelevancy = 120
	SkillMinimum = 5
	CreditsNeeded = 1000
	Orders=FREELANCE

	PreparationTime = 50

	InfantryToMass[0] = class'Rx_FamilyInfo_Nod_Sakura'
	InfantryToMass[1] = class'Rx_FamilyInfo_Nod_Raveshaw'

	MinimumParticipant = 2;

	TacticName = "Commando Deathball"
}