/*********************************************************
*
* File: TS_Vehicle_HoverMRLS_Projectile_Heroic.uc
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
class TS_Vehicle_HoverMRLS_Projectile_Heroic extends TS_Vehicle_HoverMRLS_Projectile;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(1.5f);
}

DefaultProperties
{
	DrawScale            = 1.40f

	ProjFlightTemplate=ParticleSystem'RX_FX_Munitions.Missile.P_Missile_Heroic' //ParticleSystem'TS_VH_HoverMRLS.Effects.P_Missiles'

}
