class Rx_AITactics_Nod_ArtyParty extends Rx_AITactics;

defaultproperties
{
	CreditsNeeded = 450
	Orders=ATTACK
	SkillMinimum = 2

	PreparationTime = 30

	VehicleToMass[0] = class'Rx_Vehicle_Nod_Artillery_PTInfo'


	MinimumParticipant = 3;

	TacticName = "Artillery Party"
}