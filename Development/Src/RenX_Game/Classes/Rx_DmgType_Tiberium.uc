class Rx_DmgType_Tiberium extends Rx_DmgType_Special;

var ParticleSystem PS_AttachToGib;

var name BoneToAttach;
var ParticleSystem PS_AttachToBody;

static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	local Rx_Emit_TiberiumDmg BF;
	local UTPawn UTP;

	UTP = UTPawn(P);
	if (UTP != None && !UTP.bGibbed) 
	{
		BF = P.Spawn(class'Rx_Emit_TiberiumDmg',P,, P.Location, rotator(Momentum));
		BF.AttachTo(P, BoneName);
		BF.LifeSpan = GetHitEffectDuration(P, Damage);
	}
}

static function float GetHitEffectDuration(Pawn P, float Damage)
{
	return 3.0f;
	//return (P.Health <= 0) ? 3.0 : 3.0 * FClamp(Damage * 0.01, 0.5, 1.0);
}

static function DoCustomDamageEffects(UTPawn ThePawn, class<UTDamageType> TheDamageType, const out TraceHitInfo HitInfo, vector HitLocation)
{
	local Vector BoneLocation;

	if ( class'UTGame'.static.UseLowGore(ThePawn.WorldInfo) )
	{
		return;
	}
	CreateDeathSkeleton( ThePawn, TheDamageType, HitInfo, HitLocation );
	//CreateDeathGoreChunks( ThePawn, TheDamageType, HitInfo, HitLocation );

	// we just want to spawn the bloody core explosion and not the individual gibs
	if( ThePawn.GetFamilyInfo().default.GibExplosionTemplate != None && ThePawn.EffectIsRelevant(ThePawn.Location, false, 7000) )
	{
		ThePawn.WorldInfo.MyEmitterPool.SpawnEmitter(ThePawn.GetFamilyInfo().default.GibExplosionTemplate, ThePawn.Location, ThePawn.Rotation);
	}

	ThePawn.bGibbed=TRUE; // this makes it so you can't then switch to a "gibbing" weapon and get chunks

	BoneLocation = ThePawn.Mesh.GetBoneLocation( default.BoneToAttach );

	ThePawn.WorldInfo.MyEmitterPool.SpawnEmitter( default.PS_AttachToBody, BoneLocation, Rotator(vect(0,0,1)), ThePawn );
}


/** allows special effects when gibs are spawned via DoCustomDamageEffects() instead of the normal way */
simulated static function SpawnExtraGibEffects(UTGib TheGib)
{
	if ( (TheGib.WorldInfo.GetDetailMode() != DM_Low) && !TheGib.WorldInfo.bDropDetail && FRand() < 0.70f )
	{
		TheGib.PSC_GibEffect = new(TheGib) class'UTParticleSystemComponent';
		TheGib.PSC_GibEffect.SetTemplate(default.PS_AttachToGib);
		TheGib.AttachComponent(TheGib.PSC_GibEffect);
	}
}



DefaultProperties
{
	// FIXME:: 
	GibTrail=ParticleSystem'RX_Deco_Tiberium.Effects.P_TiberiumMist_Poison'

	bPiercesArmor=true
	bCausesBleed=true
	BleedType=class'Rx_DmgType_TiberiumBleed'
	BleedDamageFactor=0.5
	BleedCount=12
	
	DamageBodyMatColor=(R=0,G=50)
	DamageOverlayTime=0.3
	DeathOverlayTime=0.6
	bUseTearOffMomentum=false
	bUseDamageBasedDeathEffects=true

	DeathAnim=H_M_Death_CrotchShot
	DeathAnimRate=0.5
	bAnimateHipsForDeathAnim=FALSE
	MotorDecayTime=1.0
	CustomTauntIndex=1
	
	PS_AttachToGib=ParticleSystem'RX_Deco_Tiberium.Effects.P_TiberiumMist_Poison'
	DamageCameraAnim=CameraAnim'Camera_FX.LinkGun.C_WP_Link_Beam_Hit'

	BoneToAttach="b_hip"
	PS_AttachToBody=ParticleSystem'RX_Deco_Tiberium.Effects.P_TiberiumMist_Poison'

	IconTextureName="T_DeathIcon_Tiberium"
}