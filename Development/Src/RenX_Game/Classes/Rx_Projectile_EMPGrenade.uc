class Rx_Projectile_EMPGrenade extends Rx_Projectile_Grenade;

var float Init_MineDamage ; //Initial damage done to proximity mines when this explodes. 
var float Vet_EMPTimeModifier[4];
var int InitialTeamNum;

function Init(vector Direction)
{
	super.Init(Direction);
	Init_MineDamage*=Vet_DamageIncrease[Vrank];

	InitialTeamNum = Instigator.GetTeamNum();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (WorldInfo.NetMode != NM_Client && InitialTeamNum == MyWeaponInstigator.GetTeamNum())
		Spawn(class'Rx_EMPField',self,,HitLocation,,,);

	super.Explode(HitLocation, HitNormal);
}

/** Override of Projectile::HurtRadius(...) including super call to Actor.
 *  Does Radius check for only vehicles and calls EMP on "hit" vehicles rather than TakeDamage.*/
simulated function bool HurtRadius( float DamageAmount,
								    float InDamageRadius,
				    class<DamageType> DamageType,
									float Momentum,
									vector HurtOrigin,
									optional actor IgnoredActor,
									optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,
									optional bool bDoFullDamage
									)
{
	// Projectile func locals
	local bool bCausedDamage, bResult;
	// Actor func locals
	local Actor Victim;
	local Rx_Building BVictim;

	if ( bHurtEntry )
		return false;

	bCausedDamage = false;
	if (InstigatedByController == None)
	{
		InstigatedByController = InstigatorController;
	}

	if (InstigatedByController != None)
		if (InitialTeamNum != InstigatedByController.GetTeamNum())
			return false;

	// if ImpactedActor is set, we actually want to give it full damage, and then let him be ignored by super.HurtRadius()
	if (ImpactedActor != None && RxIfc_EMPable(ImpactedActor) != None && RxIfc_EMPable(ImpactedActor).IsEffectedByEMP() )
	{
		RxIfc_EMPable(ImpactedActor).EMPHit(InstigatedByController, self, Vet_EMPTimeModifier[VRank]);
		bCausedDamage = ImpactedActor.bProjTarget;
	}


	// SUPER CALL TO ACTOR STARTS HERE
	bHurtEntry = true;
	bResult = false;
	foreach CollidingActors( class'Actor', Victim, DamageRadius, HurtOrigin, true )
	{
		if ( RxIfc_EMPable(Victim) != None && RxIfc_EMPable(Victim).IsEffectedByEMP() && Victim != IgnoredActor && (Victim.bCanBeDamaged || Victim.bProjTarget) )
		{
			if (Rx_Building(Victim) != None)
				continue;
			RxIfc_EMPable(Victim).EMPHit(InstigatedByController, self, Vet_EMPTimeModifier[VRank]);
			bResult = bResult || Victim.bProjTarget;
		}
	}
	// Do Buildings as a bounding box check due to collidingactors not being accurately reliable.
	foreach OverlappingActors(class'Rx_Building', BVictim, DamageRadius)
	{
		if (RxIfc_EMPable(BVictim).IsEffectedByEMP() && BVictim != IgnoredActor )
		{
			RxIfc_EMPable(BVictim).EMPHit(InstigatedByController, self);
			bResult = bResult || BVictim.bProjTarget;
		}
	}
	bHurtEntry = false;
	// SUPER CALL TO ACTOR ENDS HERE

	return ( bResult || bCausedDamage );
}

// Effect is always relavent as the smoke lingers and has a gameplay effect.
simulated function bool EffectIsRelevant(vector SpawnLocation, bool bForceDedicated, optional float VisibleCullDistance=5000.0, optional float HiddenCullDistance=350.0 )
{
	return true;
}

DefaultProperties
{
    ProjFlightTemplate=ParticleSystem'RX_WP_EMPGrenade.Effects.P_EMPGrenade_Frag'

    ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade')

	CustomGravityScaling=1.0
    
    MyDamageType=class'Rx_DmgType_EMPGrenade'
    Init_MineDamage=50 //25%
	
	
	BounceDamping=0.3
	BounceDampingZ=0.4
	ArmTime=3.0//4.0
    TossZ=50
    Speed=1500
    MaxSpeed=1500
    AccelRate=0
    LifeSpan=7.0
    Damage=1
    DamageRadius=550
    MomentumTransfer=10000

    bWaitForEffects=true

	ExplosionLightClass=Class'RenX_Game.Rx_Light_EMPExplosion'

	bLogExplosion=true
	
	Vet_DamageIncrease(0)=1 //Normal (should be 1)
	Vet_DamageIncrease(1)=1.50 //1.20 //Veteran 
	Vet_DamageIncrease(2)=2.0 //1.50 //Elite
	Vet_DamageIncrease(3)=2.5 //2.0 //Heroic

	Vet_SpeedIncrease(0)=1.0 //Normal (should be 1)
	Vet_SpeedIncrease(1)=1.0 //Veteran 
	Vet_SpeedIncrease(2)=1.0 //Elite
	Vet_SpeedIncrease(3)=1.0 //Heroic
	
	//+X Seconds
	Vet_EMPTimeModifier(0) = 0  
	Vet_EMPTimeModifier(1) = 0.5 //1.0
	Vet_EMPTimeModifier(2) = 0.75 //2.0
	Vet_EMPTimeModifier(3) = 1.5 //3.0
}
