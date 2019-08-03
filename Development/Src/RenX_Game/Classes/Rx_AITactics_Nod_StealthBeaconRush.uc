class Rx_AITactics_Nod_StealthBeaconRush extends Rx_AITactics;

defaultproperties
{
	bPrioritizeInfantry = true
	GameTimeRelevancy = 90
	SkillMinimum = 4
	CreditsNeeded = 1500
	Orders=ATTACK
	bIsRush = True
	bIsBeaconRush = True
	bAdvancedClassOnly = True

	PreparationTime = 30

	InfantryToMass[0] = class'Rx_FamilyInfo_Nod_StealthBlackHand'


	MinimumParticipant = 2;

	TacticName = "Stealth Beacon Rush"
}