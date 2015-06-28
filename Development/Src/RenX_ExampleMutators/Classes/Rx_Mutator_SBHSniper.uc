/** 
 *  This is an example of how to modify default player inventory.
 *  This mutator replaces the primary weapon of the StealthBlackHand with a Sniper rifle.
 * */
class Rx_Mutator_SBHSniper extends UTMutator;

function bool CheckReplacement(Actor Other)
{
	if (Other.IsA('Rx_InventoryManager_Nod_StealthBlackHand'))
	{
		Rx_InventoryManager_Nod_StealthBlackHand(Other).PrimaryWeapons[0] = class'Rx_Weapon_SniperRifle_Nod';
	}
	return true;
}