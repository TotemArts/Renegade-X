/*********************************************************
*
* File: Rx_Vehicle_Apache_Missile.uc
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
class Rx_Vehicle_Apache_Missile_Heroic extends Rx_Vehicle_Apache_Missile;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(1.8f); //(1.25f);
}

DefaultProperties
{
	DrawScale            = 1.0f//0.8f
	ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.Missile.P_Missile_TibCore'  //ParticleSystem'RX_FX_Munitions.Missile.P_Missile_Rockets'
}
