class Rx_AITactics_GDI_GunnerRush extends Rx_AITactics;

defaultproperties
{
	bPrioritizeInfantry = true
	GameTimeRelevancy = 90
	SkillMinimum = 3
	CreditsNeeded = 450
	Orders=ATTACK
	bIsRush = True
	bAdvancedClassOnly = True

	PreparationTime = 30

	InfantryToMass[0] = class'Rx_FamilyInfo_GDI_Gunner'


	MinimumParticipant = 4;

	TacticName = "Gunner Rush"
}