class Rx_DmgType_Headshot extends Rx_DmgType
	abstract;

static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	local UTPawn UTP;
	local name HeadBone;
	local UTEmit_HitEffect HitEffect;

	UTP = UTPawn(P);
	if (UTP != None && UTP.Mesh != None)
	{
		HeadBone = UTP.HeadBone;
	}
	HitEffect = P.Spawn(class'Rx_Emit_HeadShotBloodSpray',,, HitLocation, rotator(-Momentum));
	if (HitEffect != None)
	{
		HitEffect.AttachTo(P, HeadBone);
	}
}

DefaultProperties
{
	KillStatsName=KILLS_HEADSHOT
	DeathStatsName=DEATHS_HEADSHOT
	SuicideStatsName=SUICIDES_HEADSHOT
	DamageWeaponFireMode=0
	bSeversHead=true
	bHeadGibCamera=false
	bNeverGibs=true
	VehicleDamageScaling=0.4
	NodeDamageScaling=0.4
	CustomTauntIndex=3
	bCausesBloodSplatterDecals=false
	
	DeathAnim=H_M_Death_Headshot
	
	KDamageImpulse=100
	KDeathUpKick=50
}