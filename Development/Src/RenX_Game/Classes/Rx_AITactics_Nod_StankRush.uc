class Rx_AITactics_Nod_StankRush extends Rx_AITactics;

defaultproperties
{
	CreditsNeeded = 900
	Orders=ATTACK
	SkillMinimum = 5

	PreparationTime = 50

	VehicleToMass[0] = class'Rx_Vehicle_Nod_StealthTank_PTInfo'

	MinimumParticipant = 2;

	TacticName = "Stealth Tank Rush"
}