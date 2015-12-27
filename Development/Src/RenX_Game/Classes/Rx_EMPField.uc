class Rx_EMPField extends Rx_ParticleField;

var float InitialDamage; //initial damage done to proximity mines

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if (WorldInfo.NetMode == NM_Client)
		return;

	if (RxIfc_EMPable(Other) != None)
	{
		RxIfc_EMPable(Other).EnteredEMPField(self);
	}	
}

event UnTouch( Actor Other )
{
	if (WorldInfo.NetMode == NM_Client)
		return;

	if (RxIfc_EMPable(Other) != None)
		RxIfc_EMPable(Other).LeftEMPField(self);
}

event Destroyed()
{
	local Actor A;
	foreach TouchingActors(class'Actor', A)
	{
		if (RxIfc_EMPable(A) != None)
			RxIfc_EMPable(A).LeftEMPField(self);
	}
	super.Destroyed();
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=+384.0f
		CollisionHeight=+320.0f
		BlockNonZeroExtent=true // true required for Touch to trigger on SBH. false still triggers on Stank tho...
	End Object

	ParticlesTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPField'

	InitialDamage=68
	
	StopParticlesTime=0.25
	LifeSpan=+12.0
}
