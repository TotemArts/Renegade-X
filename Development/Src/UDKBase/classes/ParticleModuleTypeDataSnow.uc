/*=============================================================================
	ParticleModuleTypeDataPhysX.uc: PhysX Emitter Source.
	Copyright 2007-2008 AGEIA Technologies.
=============================================================================*/

class ParticleModuleTypeDataSnow extends ParticleModuleTypeDataBase
	native
	editinlinenew
	collapsecategories
	hidecategories(Object);

var(Spawn) rawdistributionvector StartSize;
var(Spawn) rawdistributionvector StartVelocity;
var(Spawn) rawdistributionvector StartLocation;
var(Lifetime) rawdistributionvector ColorOverLife;
var(Lifetime) rawdistributionfloat	AlphaOverLife;
var(Lifetime) rawdistributionfloat	Lifetime;
var(Lifetime) float KillHeight;

/** Distance from player to bounds at which the particles will start to fade out */
var(Rendering) float FadeStart;

/** Distance from player to bounds at which the particles will be totally faded out. SHOULD MATCH MAXDRAWDISTANCE OF THE EMITTER ACTOR! */
var(Rendering) float FadeStop;

cpptext
{
	virtual FParticleEmitterInstance *CreateInstance(UParticleEmitter *InEmitterParent, UParticleSystemComponent *InComponent);
	virtual void Spawn(FParticleEmitterInstance* Owner, INT Offset, FLOAT SpawnTime);
}

defaultproperties
{
	Begin Object Class=DistributionVectorUniform Name=DistributionStartSize
		Min=(X=1,Y=1,Z=1)
		Max=(X=1,Y=1,Z=1)
	End Object
	StartSize=(Distribution=DistributionStartSize)

	Begin Object Class=DistributionVectorUniform Name=DistributionStartLocation
	End Object
	StartLocation=(Distribution=DistributionStartLocation)

	Begin Object Class=DistributionVectorUniform Name=DistributionStartVelocity
	End Object
	StartVelocity=(Distribution=DistributionStartVelocity)

	Begin Object Class=DistributionVectorConstantCurve Name=DistributionColorOverLife
	End Object
	ColorOverLife=(Distribution=DistributionColorOverLife)

	Begin Object Class=DistributionFloatConstant Name=DistributionAlphaOverLife
		Constant=1.0f;
	End Object
	AlphaOverLife=(Distribution=DistributionAlphaOverLife)

	Begin Object Class=DistributionFloatUniform Name=DistributionLifetime
	End Object
	Lifetime=(Distribution=DistributionLifetime)
}
