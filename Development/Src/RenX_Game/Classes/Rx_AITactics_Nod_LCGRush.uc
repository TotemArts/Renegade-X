class Rx_AITactics_Nod_LCGRush extends Rx_AITactics;

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

	InfantryToMass[0] = class'Rx_FamilyInfo_Nod_LaserChainGunner'


	MinimumParticipant = 4;

	TacticName = "Laser Rush"
}