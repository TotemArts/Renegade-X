/*********************************************************
*
* File: Rx_Vehicle_Orca_Missile.uc
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
class Rx_Vehicle_Orca_Missile_Heroic extends Rx_Vehicle_Orca_Missile;


simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(1.0f);
}

DefaultProperties
{
   DrawScale            = 2.0 //1.5f
   
   ProjFlightTemplate= ParticleSystem'RX_FX_Munitions.Missile.P_Missile_Heroic' //ParticleSystem'RX_FX_Munitions.Missile.P_Missile_RocketLauncher'
}
