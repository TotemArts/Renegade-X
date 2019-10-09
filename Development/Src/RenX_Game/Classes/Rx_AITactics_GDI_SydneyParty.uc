class Rx_AITactics_GDI_SydneyParty extends Rx_AITactics;

defaultproperties
{
	bPrioritizeInfantry = true
	GameTimeRelevancy = 120
	SkillMinimum = 4
	CreditsNeeded = 1000
	Orders=ATTACK
	bIsRush = True
	bAdvancedClassOnly =True

	PreparationTime = 50

	InfantryToMass[0] = class'Rx_FamilyInfo_GDI_Sydney'

	MinimumParticipant = 2;

	TacticName = "Sydney Party"
}