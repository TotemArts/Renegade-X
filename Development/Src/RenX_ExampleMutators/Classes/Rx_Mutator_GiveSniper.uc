/** 
 *  This is an example of how to create a mutator that can be triggered with the mutate command.
 *  This gives the player a sniper rifle when they type "Mutate Sniper" into the commandline.
 * */
class Rx_Mutator_GiveSniper extends UTMutator;

function Mutate(string MutateString, PlayerController Sender)
{
	local Rx_InventoryManager InvManager;
	local class<Rx_Weapon> WeaponClass;

	WeaponClass = class'Rx_Weapon_SniperRifle_Nod';
	InvManager = Rx_InventoryManager(Sender.Pawn.InvManager);

    if (MutateString ~= "sniper" && InvManager != none)
    {
		if (InvManager.PrimaryWeapons.Find(WeaponClass) < 0) // Make sure it isn't in there already.
			InvManager.PrimaryWeapons.AddItem(WeaponClass);

		if(InvManager.FindInventoryType(WeaponClass) != None) 
		{
			InvManager.SetCurrentWeapon(Rx_Weapon(InvManager.FindInventoryType(WeaponClass)));
		}
		else
		{
			InvManager.SetCurrentWeapon(Rx_Weapon(InvManager.CreateInventory(WeaponClass, false)));
		}

		Rx_Pawn(Owner).RefreshBackWeapons();			
    }
       
    Super.Mutate(MutateString, Sender);
}

DefaultProperties
{ 
}