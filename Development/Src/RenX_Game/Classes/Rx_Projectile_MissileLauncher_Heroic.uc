class Rx_Projectile_MissileLauncher_Heroic extends Rx_Projectile_MissileLauncher;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(1.5f);
}

DefaultProperties
{

    ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.Missile.P_Missile_Heroic' //ParticleSystem'RX_FX_Munitions.Missile.P_Missile_RocketLauncher'

    DrawScale= 0.6f

	HomingTrackingStrength=28.0

}
