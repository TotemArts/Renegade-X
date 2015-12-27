class Rx_Weapon_TimedC4_Multiple extends Rx_Weapon_TimedC4;

simulated function WeaponEmpty()
{
	super(UTWeapon).WeaponEmpty();
}

DefaultProperties
{
	//AmmoCount=2
	//MaxAmmoCount=2
	
	ClipSize = 1
	InitalNumClips = 2
	MaxClips = 2
}
