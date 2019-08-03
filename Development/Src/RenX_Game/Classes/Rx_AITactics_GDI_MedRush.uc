class Rx_AITactics_GDI_MedRush extends Rx_AITactics;

defaultproperties
{
	CreditsNeeded = 800
	Orders=ATTACK
	SkillMinimum = 3

	PreparationTime = 30

	VehicleToMass[0] = class'Rx_Vehicle_GDI_MediumTank_PTInfo'

	MinimumParticipant = 3;
	TacticName = "Medium Tank Rush"
}