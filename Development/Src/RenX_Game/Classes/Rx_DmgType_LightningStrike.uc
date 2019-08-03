class Rx_DmgType_LightningStrike extends Rx_DmgType_Special;

static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	local Rx_Emit_ElectricDmg BF;
	local UTPawn UTP;

	UTP = UTPawn(P);
	if (UTP != None && !UTP.bGibbed) 
	{
		BF = P.Spawn(class'Rx_Emit_ElectricDmg',P,, P.Location, rotator(Momentum));
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
	GibTrail=ParticleSystem'RX_FX_Munitions.Beams.P_CharacterBurn_Electric'

	bPiercesArmor=true
	bCausesBleed=true
	BleedType=class'Rx_DmgType_FireBleed'
	BleedDamageFactor=0.25
	BleedCount=4
	BuildingDamageScaling=2.0
	KDeathUpKick=600
	
	DamageBodyMatColor=(R=0,G=5,B=50)
	DamageOverlayTime=0.5
	DeathOverlayTime=1.0

	bCausesBlood=false
	bLeaveBodyEffect=true
	bUseDamageBasedDeathEffects=true
	
	// TODO: Make Lightning Strike Death Icon
	IconTextureName="T_DeathIcon_IonCannon"
	IconTexture=Texture2D'RX_WP_IonCannon.UI.T_DeathIcon_IonCannon'
}