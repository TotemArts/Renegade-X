/*********************************************************
*
* File: Rx_Vehicle_Artillery_Projectile_Arc.uc
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
class Rx_Vehicle_Artillery_Projectile_Arc_Heroic extends Rx_Vehicle_Artillery_Projectile_Arc;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(1.5f);
}
 
DefaultProperties
{
	   ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.shells.P_Shell_Incendiary_Heroic' //ParticleSystem'RX_FX_Munitions.shells.P_Shell_Incendiary'	// ParticleSystem'RX_FX_Munitions.Shells.P_Shell_Basic'

}
