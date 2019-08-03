class Rx_WeaponAbility_Attached extends Rx_WeaponAbility;

/*Class of abilities that are be attached to Rx_Weapons*/
var class	ParentWeaponClass; 

simulated function bool bShouldBeVisible()
{
	return ((Pawn(Owner).Weapon) != none && ((Pawn(Owner).Weapon).class == ParentWeaponClass || (Pawn(Owner).Weapon) == self));
}

simulated function bool bCanBeSelected()
	{
		if(((Pawn(Owner).Weapon) != none) && (Pawn(Owner).Weapon).class == ParentWeaponClass)  
		{
			return (!bCurrentlyRecharging || (bFireWhileRecharging && HasAnyAmmo()))  ; 	
		}
		return false ; 
	}

simulated function PerformEmptySwap(){
	if(WorldInfo.NetMode == NM_DedicatedServer)
		return; 
	
	if(EmptySwapDelay > 0.0) 
		SetTimer(EmptySwapDelay, false, 'SwitchToPreviousWeapon') ;
	else
		Rx_InventoryManager(Instigator.InvManager).SwitchtoLastUsedWeapon();
}

simulated function SwitchToPreviousWeapon(){
	Rx_InventoryManager(Instigator.InvManager).SwitchtoLastUsedWeapon();
}
	
DefaultProperties
{
}
