class Rx_Weapon_RepairGunAdvanced extends Rx_Weapon_RepairGun;

DefaultProperties
{
    HealAmount = 40;
	MineDamageModifier=2.0;
	WeaponRange=900.0
	
	InventoryMovieGroup=20
	
	/*******************/
	/*Veterancy*/
	/******************/
	
	Vet_DamageModifier(0)=1  //Applied to instant-hits only
	Vet_DamageModifier(1)=1.05 //42
	Vet_DamageModifier(2)=1.10 //44
	Vet_DamageModifier(3)=1.15 //46
	
	/**********************/

	WeaponIconTexture=Texture2D'RX_WP_RepairGun.UI.T_WeaponIcon_RepairGunAdvanced'
}
