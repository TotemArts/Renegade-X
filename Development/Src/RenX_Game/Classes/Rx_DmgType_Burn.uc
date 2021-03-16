class Rx_DmgType_Burn extends Rx_DmgType_Special;

static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	local Rx_Emit_FireDmg BF;
	local UTPawn UTP;

	UTP = UTPawn(P);
	if (UTP != None && !UTP.bGibbed) 
	{
		BF = P.Spawn(class'Rx_Emit_FireDmg',P,, P.Location, rotator(Momentum));
		BF.AttachTo(P, BoneName);
		BF.LifeSpan = GetHitEffectDuration(P, Damage);
	}
}

static function float GetHitEffectDuration(Pawn P, float Damage)
{
	return 3.0f;
	//return (P.Health <= 0) ? 3.0 : 3.0 * FClamp(Damage * 0.01, 0.5, 1.0);
}

DefaultProperties
{
	// FIXME:: 
	GibTrail=ParticleSystem'RX_WP_FlameThrower.Effects.FX_Flame_Explode'

	bPiercesArmor=false
	bCausesBleed=true
	BleedType=class'Rx_DmgType_FireBleed'
	BleedDamageFactor=0.25
	BleedCount=4
	
	DamageBodyMatColor=(R=100,G=50)
	DamageOverlayTime=0.3
	DeathOverlayTime=0.6
	bUseTearOffMomentum=false
	bUseDamageBasedDeathEffects=true

	DeathAnim=H_M_Death_CrotchShot
	DeathAnimRate=0.5
	bAnimateHipsForDeathAnim=FALSE
	MotorDecayTime=1.0
	bUnsourcedDamage=true
	
	HitColour = (R = 0.9, G = 0.6, B = 0.0, A = 1.0)
}