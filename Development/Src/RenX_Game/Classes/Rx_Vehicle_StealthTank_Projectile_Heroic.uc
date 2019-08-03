/*********************************************************
*
* File: Rx_Vehicle_StealthTank_Projectile.uc
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
class Rx_Vehicle_StealthTank_Projectile_Heroic extends Rx_Vehicle_StealthTank_Projectile;


simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(1.5f);
}

DefaultProperties
{
   DrawScale            = 0.65f

   ProjFlightTemplate= ParticleSystem'RX_FX_Munitions.Missile.P_Missile_TibCore' //ParticleSystem'RX_FX_Munitions.Missile.P_Missile_Heroic'

  
}
