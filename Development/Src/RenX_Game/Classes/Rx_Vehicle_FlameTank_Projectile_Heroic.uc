/*********************************************************
*
* File: Rx_Vehicle_FlameTank_Projectile.uc
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
class Rx_Vehicle_FlameTank_Projectile_Heroic extends Rx_Vehicle_FlameTank_Projectile;


DefaultProperties
{
//    AmbientSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Travel_Cue'
//    ExplosionSound=none
 
//    ProjExplosionTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue'
    ProjFlightTemplate=ParticleSystem'RX_VH_FlameTank.Effects.P_FireBall_Blue'
 
	
	ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	/**
	ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_WP_FlameThrower.Effects.P_Flame_Explode_Blue',Sound=none)
	*/

	DrawScale= 1.75f
	
	Begin Object Name=CollisionCylinder
		CollisionRadius=45
		CollisionHeight=45
	End Object

    
}
