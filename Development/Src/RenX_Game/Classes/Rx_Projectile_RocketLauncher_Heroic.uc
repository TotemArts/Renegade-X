class Rx_Projectile_RocketLauncher_Heroic extends Rx_Projectile_RocketLauncher;//_Rocket;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(1.2f);
}

DefaultProperties
{

    AmbientSound=SoundCue'RX_SoundEffects.Missiles.SC_Missile_FlyBy'

    ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.Missile.P_Missile_Heroic' //ParticleSystem'RX_FX_Munitions.Missile.P_Missile_RocketLauncher' 
	// ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.Missile.P_Missile_Rockets'		// ParticleSystem'RX_FX_Munitions.Missile.P_Missile_RocketLauncher'

	
    DrawScale= 1.75f

}
