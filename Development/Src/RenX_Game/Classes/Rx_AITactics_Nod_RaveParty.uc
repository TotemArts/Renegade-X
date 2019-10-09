class Rx_AITactics_Nod_RaveParty extends Rx_AITactics;

defaultproperties
{
	bPrioritizeInfantry = true
	GameTimeRelevancy = 120
	SkillMinimum = 4
	CreditsNeeded = 1000
	Orders=ATTACK
	bIsRush = True
	bAdvancedClassOnly = True

	PreparationTime = 50

	InfantryToMass[0] = class'Rx_FamilyInfo_Nod_Raveshaw'


	MinimumParticipant = 2;

	TacticName = "Rave Party"
}