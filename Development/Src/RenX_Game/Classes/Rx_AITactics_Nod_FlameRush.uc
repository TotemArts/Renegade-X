	class Rx_AITactics_Nod_FlameRush extends Rx_AITactics;

defaultproperties
{
	CreditsNeeded = 800
	Orders=ATTACK
	bIsRush = True
	SkillMinimum = 4

	PreparationTime = 45

	VehicleToMass[0] = class'Rx_Vehicle_Nod_FlameTank_PTInfo'

	MinimumParticipant = 2;

	TacticName = "Flame Tank Rush"
}