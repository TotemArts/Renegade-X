class Rx_PurchaseSystem_Survival extends Rx_PurchaseSystem_Coop;

simulated function bool AreHighTierPayClassesDisabled( byte teamID )
{
	if(TeamID == 0 && Barracks.Length > 0)
	{
		return super(Rx_PurchaseSystem).AreHighTierPayClassesDisabled(teamID);
	}
	else if(TeamID == 1 && HandOfNod.Length > 0)
	{
		return super(Rx_PurchaseSystem).AreHighTierPayClassesDisabled(teamID);	
	}

	return false;
}

DefaultProperties
{
	GDIItemClasses[0]  = class'Rx_Weapon_Airstrike_GDI'
	GDIItemClasses[1]  = class'Rx_Weapon_Blueprint_Defense_GT_GDI'
	GDIItemClasses[2]  = class'Rx_Weapon_RepairTool'
	GDIItemClasses[3]  = class'Rx_Weapon_Blueprint_Defense_Turret_GDI'
	GDIItemClasses[4]  = class'Rx_Weapon_Blueprint_Defense_CeilingTurret'

	NodItemClasses[0]  = class'Rx_Weapon_Airstrike_Nod'
	NodItemClasses[1]  = class'Rx_Weapon_Blueprint_Defense_GT_Nod'
	NodItemClasses[2]  = class'Rx_Weapon_RepairTool'
	NodItemClasses[3]  = class'Rx_Weapon_Blueprint_Defense_Turret_Nod'
	NodItemClasses[4]  = class'Rx_Weapon_Blueprint_Defense_CeilingTurret'

}
