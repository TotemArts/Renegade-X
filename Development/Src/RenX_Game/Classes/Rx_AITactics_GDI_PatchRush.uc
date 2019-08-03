class Rx_AITactics_GDI_PatchRush extends Rx_AITactics;

defaultproperties
{
	bPrioritizeInfantry = true
	GameTimeRelevancy = 90
	SkillMinimum = 3
	CreditsNeeded = 500
	Orders=ATTACK
	bIsRush = True
	bAdvancedClassOnly = True

	PreparationTime = 30

	InfantryToMass[0] = class'Rx_FamilyInfo_GDI_Patch'


	MinimumParticipant = 3;

	TacticName = "Patch Rush"
}