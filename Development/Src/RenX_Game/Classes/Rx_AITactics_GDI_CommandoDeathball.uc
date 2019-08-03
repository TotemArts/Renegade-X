class Rx_AITactics_GDI_CommandoDeathball extends Rx_AITactics;

defaultproperties
{
	bPrioritizeInfantry = true
	GameTimeRelevancy = 120
	SkillMinimum = 5
	CreditsNeeded = 1000
	Orders=FREELANCE
	bAdvancedClassOnly=True

	PreparationTime = 50

	InfantryToMass[0] = class'Rx_FamilyInfo_GDI_Havoc'
	InfantryToMass[1] = class'Rx_FamilyInfo_GDI_Sydney'

	MinimumParticipant = 2;

	TacticName = "Commando Deathball"
}