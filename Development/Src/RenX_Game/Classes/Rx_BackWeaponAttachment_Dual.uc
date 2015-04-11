class Rx_BackWeaponAttachment_Dual extends Rx_BackWeaponAttachment
	abstract;

var class<Rx_Weapon> WeaponClass;

static function int GetSocketIndex(Rx_InventoryManager mngr) 
{
	local int i;

	// check if this is secondary weapon
	for (i = 0; i < mngr.SecondaryWeapons.Length; i++)
		if (mngr.SecondaryWeapons[i] == default.WeaponClass) return 1;

	// return as being primary
	return 0;
}

static function int GetDefaultSocketIndex(class<Rx_InventoryManager> mngr) 
{ 
	local int i;

	for (i = 0; i < mngr.default.SecondaryWeapons.Length; i++)
		if (mngr.default.SecondaryWeapons[i] == default.WeaponClass) return 1;

	return 0;
}

DefaultProperties
{
}
