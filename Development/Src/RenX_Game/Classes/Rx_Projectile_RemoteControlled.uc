/**A Projectile class with easy hooks to have its parent weapon
*control where it's going or when it explodes*/

class Rx_Projectile_RemoteControlled extends Rx_Projectile;

simulated function CallRemoteDetonation(Weapon Detonator){
	if(Detonator == GetWeaponInstigator() && DamageRadius > 0.0)
		Explode(location, location);
	
}

simulated function SetHeading(vector NewHeading){
	Acceleration = Speed * AccelRate * Normal(NewHeading - Location);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	super.Explode(HitLocation, HitNormal);
}

DefaultProperties
{    
}
