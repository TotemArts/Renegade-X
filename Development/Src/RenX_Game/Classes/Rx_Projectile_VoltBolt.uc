class Rx_Projectile_VoltBolt extends Rx_Projectile;

var repnotify float OverCharge;

var float BaseDrawScale;
var float BonusDrawScale;
var float BonusDamage;  // amount of extra damage a fully charged shot does.
var float BonusDamageRadius;    // amount of extra damage radius a fully charged shot has.

replication
{
    if (bNetInitial)
        OverCharge;
}

simulated event ReplicatedEvent(name VarName)
{
    if (VarName == 'OverCharge')
        SetChargeStrength(OverCharge);
    else
        Super.ReplicatedEvent(VarName);
}

function InitCharge(Rx_Weapon_VoltAutoRifle FiringWeapon, float ChargeStrength)
{
    OverCharge = ChargeStrength;
    SetChargeStrength(ChargeStrength);
}

simulated function SetChargeStrength( float OverChargePercentage )
{
    Damage = default.Damage + BonusDamage*OverChargePercentage;
    DamageRadius = default.DamageRadius + BonusDamageRadius*OverChargePercentage;
    if (WorldInfo.NetMode != NM_DedicatedServer)
        ProjEffects.SetScale(BaseDrawScale + BonusDrawScale*OverChargePercentage);
}

simulated function CallServerALHit(Actor Target, vector HitLocation, TraceHitInfo ProjHitInfo, bool mctDamage)
{
    if (Rx_Weapon_VoltAutoRifle(Instigator.Weapon) != None) 
        Rx_Weapon_VoltAutoRifle(Instigator.Weapon).ServerALHitCharged(Target,HitLocation,ProjHitInfo,mctDamage,OverCharge);
    else 
        super.CallServerALHit(Target, HitLocation, ProjHitInfo, mctDamage);
}

simulated static function float GetChargePercentFromDamage(float BaseDamage)
{
    return (BaseDamage - default.Damage) / default.BonusDamage;
}

DefaultProperties
{

    ProjFlightTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Blue'
    
    ProjExplosionTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion'
	
	AmbientSound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Ambient'
  
    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(17)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(18)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Explosion',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
   
    MyDamageType=class'Rx_DmgType_VoltRifle_Alt'

    DrawScale= 1.0f
    BaseDrawScale=0.4
    BonusDrawScale=0.6

    bCollideComplex=true
    Speed=2000
    MaxSpeed=2000
    AccelRate=0
    LifeSpan=2.5
    Damage=100.0
    DamageRadius=100
	HeadShotDamageMult=2.0
    MomentumTransfer=100000

    BonusDamage=125 //175//200
    BonusDamageRadius=100

/*	
	Begin Object Name=CollisionCylinder
		CollisionRadius=35
		CollisionHeight=35
	End Object
*/
    bWaitForEffects=true
    bWaitForEffectsAtEndOfLifetime=true
    bAttachExplosionToVehicles=false
//	bCheckProjectileLight=true
    bSuppressExplosionFX=True // Do not spawn hit effect in mid air
    
    ProjectileLightClass=none
    ExplosionLightClass=none
}
