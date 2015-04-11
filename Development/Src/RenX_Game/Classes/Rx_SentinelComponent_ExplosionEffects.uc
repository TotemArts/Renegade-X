//=============================================================================
// Spawns some explosion effects.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelComponent_ExplosionEffects extends ActorComponent
	within Rx_Sentinel;

/** Effect to spawn when exploding. */
var() ParticleSystem ExplosionTemplate;
/** Light to spawn when exploding */
var() class<UDKExplosionLight> ExplosionLightClass;
/** Sound to play when exploding. */
var() SoundCue ExplosionSound;

/** Decal to project onto ground when exploded. */
var() MaterialInstance ExplosionDecal;
var() InterpCurveFloat DecalMaterialParameterCurve;
var() name DecalDissolveParamName;
var() float DecalWidth;
var() float DecalHeight;

function bool Explode(class<DamageType> KilledByDamageType)
{
	local bool bExploded;

	if(KilledByDamageType != class'DmgType_Suicided')
	{
		if(WorldInfo.NetMode != NM_DedicatedServer)
		{
			SpawnEffects();
		}

		bExploded = true;
	}

	return bExploded;
}

function SpawnEffects()
{
	local ParticleSystemComponent PSC;
	local UDKExplosionLight L;
	local MaterialInstanceTimeVarying Decal;
	local float DecalDissolveStartTime;

	PSC = WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionTemplate, Location, BaseComponent.Rotation);

	if(PSC != none)
	{
		AttachComponent(PSC);

		if(!WorldInfo.bDropDetail)
		{
			L = new(self) ExplosionLightClass;
			AttachComponent(L);
		}
	}

	PlaySound(ExplosionSound, true,,, Location + WeaponComponent.Translation);

	Decal = new(self) class'MaterialInstanceTimeVarying';
	Decal.SetParent(ExplosionDecal);

	WorldInfo.MyDecalManager.SpawnDecal(Decal, BaseComponent.GetPosition(), class'Rx_Sentinel_Utils'.static.RotateRelative(BaseComponent.Rotation, -16384.0, 0, 0), DecalWidth, DecalHeight, 32.0, false);
	Decal.SetScalarCurveParameterValue(DecalDissolveParamName, DecalMaterialParameterCurve);
	//Start fading out just soon enough to finish fading when the decal's lifespan runs out.
	DecalDissolveStartTime = WorldInfo.MyDecalManager.DecalLifeSpan;
	DecalDissolveStartTime -= DecalMaterialParameterCurve.Points[DecalMaterialParameterCurve.Points.length - 1].InVal;
	DecalDissolveStartTime = FMax(DecalDissolveStartTime, 0.0);
	Decal.SetScalarStartTime(DecalDissolveParamName, DecalDissolveStartTime);
}

defaultproperties
{
	ExplosionTemplate=ParticleSystem'FX_VehicleExplosions.Effects.P_FX_VehicleDeathExplosion'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'
	ExplosionSound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium'

	ExplosionDecal=MaterialInstanceTimeVarying'WP_FlakCannon.Decals.MITV_WP_FlakCannon_Impact_Decal01'
	DecalMaterialParameterCurve=(Points=((InVal=0.0,OutVal=0.0),(InVal=4.0,OutVal=1.0)))
	DecalDissolveParamName=DissolveAmount
	DecalWidth=256.0
	DecalHeight=256.0
}