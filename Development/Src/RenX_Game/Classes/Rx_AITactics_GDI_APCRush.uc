class Rx_AITactics_GDI_APCRush extends Rx_AITactics;

defaultproperties
{
	CreditsNeeded = 900
	Orders=ATTACK
	bIsRush = True
	SkillMinimum = 5

	PreparationTime = 30

	InfantryToMass[0] = class'Rx_FamilyInfo_GDI_McFarland'
	InfantryToMass[1] = class'Rx_FamilyInfo_GDI_Engineer'
	InfantryToMass[2] = class'Rx_FamilyInfo_GDI_Gunner'
	InfantryToMass[3] = class'Rx_FamilyInfo_GDI_Patch'
	InfantryToMass[4] = class'Rx_FamilyInfo_GDI_Mobius'
	VehicleToMass[0] = class'Rx_Vehicle_GDI_APC_PTInfo'


	MinimumParticipant = 3;
	TacticName = "APC Rush"
}