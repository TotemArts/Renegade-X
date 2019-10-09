class Rx_Pawn_SurvivalEnemy extends Rx_Pawn_Scripted;

simulated function float GetSpeedModifier()
{
	return ((SpeedUpgradeMultiplier+GetRxFamilyInfo().default.Vet_SprintSpeedMod[VRank])+GetInventoryWeight());
}