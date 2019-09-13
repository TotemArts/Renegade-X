/*********************************************************
*
* File: Rx_Vehicle_ReconBike_Projectile.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Vehicle_ReconBike_Projectile_Heroic extends Rx_Vehicle_ReconBike_Projectile;

simulated static function float GetRange() //Wasn't working correctly with the acceleration set, so I just set it manually.-Yosh
{
	return 6000 ;	
}

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(1.33f);
}

DefaultProperties
{
	DrawScale            = 0.65f

	AmbientSound=SoundCue'RX_SoundEffects.Missiles.SC_Missile_FlyBy'
	 ProjFlightTemplate= ParticleSystem'RX_FX_Munitions.Missile.P_Missile_TibCore'

}
