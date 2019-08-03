class Rx_WeaponAbility_TiberiumGrenade extends Rx_WeaponAbility_Grenade;

// EMP Grenades are non-refillable, players must purchase more. EDIT: Rechargeable Grenades are also non-refillable. 

DefaultProperties
{
	FlashMovieIconNumber	=5

    WeaponProjectiles(0)=class'Rx_Projectile_TiberiumGrenade'
    WeaponProjectiles(1)=class'Rx_Projectile_TiberiumGrenade'

}
