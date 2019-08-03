//=============================================================================
// Handles hit effects for different materials.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelWeaponComponent_HitEffects extends Component;

/** impact effects by material type */
var() array<MaterialImpactEffect> ImpactEffects;
/** default impact effect to use if a material specific one isn't found */
var() MaterialImpactEffect DefaultImpactEffect;
/** Distance from viewer beyond which effects will not be spawned. */
var() float MaxImpactEffectDistance;
/** Controls decal fade out. */
var() InterpCurveFloat DecalMaterialParameterCurve;

//Mostly copied from UTWeaponAttachment.uc
function MaterialImpactEffect GetImpactEffect(PhysicalMaterial HitMaterial, optional name MaterialType)
{
	local int i;
	local UTPhysicalMaterialProperty PhysicalProperty;

	if(HitMaterial != none)
	{
		PhysicalProperty = UTPhysicalMaterialProperty(HitMaterial.GetPhysicalMaterialProperty(class'UTPhysicalMaterialProperty'));

		if(PhysicalProperty != none)
		{
			MaterialType = PhysicalProperty.MaterialType;
		}
	}

	if(MaterialType != 'None')
	{
		i = ImpactEffects.Find('MaterialType', MaterialType);

		if(i != INDEX_NONE)
		{
			return ImpactEffects[i];
		}
	}

	return DefaultImpactEffect;
}

//Mostly copied from UTWeaponAttachment.uc
function PlayImpactEffects(Vector FireLocation, Vector HitLocation, Actor Impactor)
{
	local WorldInfo WI;
	local Vector NewHitLoc, HitNormal, WaterHitNormal;
	local Actor HitActor;
	local PhysicsVolume HitVolume;
	local TraceHitInfo HitInfo;
	local MaterialImpactEffect ImpactEffect;
	local Pawn P;
	local Vehicle V;

	WI = Impactor.WorldInfo;

	HitNormal = Normal(FireLocation - HitLocation);

	if(Impactor.EffectIsRelevant(HitLocation, false, MaxImpactEffectDistance))
	{
		if(!WI.bDropDetail)
		{
			HitVolume = PhysicsVolume(Impactor.Trace(NewHitLoc, WaterHitNormal, HitLocation, FireLocation, true,, HitInfo, Impactor.TRACEFLAG_PhysicsVolumes | Impactor.TRACEFLAG_Bullet));

			if(HitVolume != none && HitVolume.bWaterVolume)
			{
				ImpactEffect = GetImpactEffect(none, 'Water');
				
				if(ImpactEffect != DefaultImpactEffect)
				{
					if(ImpactEffect.Sound != none)
					{
						Impactor.PlaySound(ImpactEffect.Sound, true,,, NewHitLoc);
					}

					if(ImpactEffect.ParticleTemplate != none)
					{
						WI.MyEmitterPool.SpawnEmitter(ImpactEffect.ParticleTemplate, NewHitLoc, Rotator(WaterHitNormal));
					}
				}
			}
		}

		HitActor = Impactor.Trace(NewHitLoc, HitNormal, (HitLocation - (HitNormal * 32)), HitLocation + (HitNormal * 32), true,, HitInfo, Impactor.TRACEFLAG_Bullet);
		if(HitActor != none && PortalTeleporter(HitActor) == none)
		{
			P = Pawn(HitActor);

			if(P != none)
			{
				Impactor.CheckHitInfo(HitInfo, P.Mesh, -HitNormal, NewHitLoc);

				V = Vehicle(HitActor);
			}

			ImpactEffect = GetImpactEffect(HitInfo.PhysMaterial);

			if(ImpactEffect.Sound != none)
			{
				Impactor.PlaySound(ImpactEffect.Sound, true,,, HitLocation);
			}

			//Pawns handle their own hit effects
			if(P == none || V != none)
			{
				if(!WI.bDropDetail && (P == none) && (WI.GetDetailMode() != DM_Low))
				{
					
					SpawnImpactDecal(ImpactEffect, HitLocation, HitNormal, HitInfo, WI);
				}

				if(ImpactEffect.ParticleTemplate != none)
				{
					WI.MyEmitterPool.SpawnEmitter(ImpactEffect.ParticleTemplate, HitLocation, Rotator(HitNormal), HitActor);
				}
			}
		}
	}
}

function SpawnImpactDecal(MaterialImpactEffect ImpactEffect, Vector HitLocation, Vector HitNormal, TraceHitInfo HitInfo, WorldInfo WI)
{
	local int DecalMaterialsLength;
	local MaterialInterface MI;
	local MaterialInstanceTimeVarying MITV_Decal;
	local float DecalDissolveStartTime;

	DecalMaterialsLength = ImpactEffect.DecalMaterials.length;

	if(DecalMaterialsLength > 0)
	{
		MI = ImpactEffect.DecalMaterials[Rand(DecalMaterialsLength)];

		if(MI != none)
		{
			MITV_Decal = new(Outer) class'MaterialInstanceTimeVarying';
			MITV_Decal.SetParent(MI);

			WI.MyDecalManager.SpawnDecal(MITV_Decal, HitLocation, Rotator(-HitNormal), ImpactEffect.DecalWidth,
				ImpactEffect.DecalHeight, 10.0, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex);

			MITV_Decal.SetScalarCurveParameterValue(ImpactEffect.DecalDissolveParamName, DecalMaterialParameterCurve);
			//Start fading out just soon enough to finish fading when the decal's lifespan runs out.
			DecalDissolveStartTime = WI.MyDecalManager.DecalLifeSpan;
			DecalDissolveStartTime -= DecalMaterialParameterCurve.Points[DecalMaterialParameterCurve.Points.length - 1].InVal;
			DecalDissolveStartTime = FMax(DecalDissolveStartTime, 0.0);
			MITV_Decal.SetScalarStartTime(ImpactEffect.DecalDissolveParamName, DecalDissolveStartTime);
		}
	}
}

defaultproperties
{
	
	
	
	ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Dirt_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Dirt'),DecalWidth=20.0,DecalHeight=20.0)
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Stone'),DecalWidth=8.0,DecalHeight=8.0)
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Concrete'),DecalWidth=6.0,DecalHeight=6.0)
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Metal_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Metal',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Metal'),DecalWidth=6.0,DecalHeight=6.0)
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Glass',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass',DecalMaterials=(DecalMaterial'RX_FX_Munitions.Bullet_Decals.MDecal_Bullet_Glass'),DecalWidth=20.0,DecalHeight=20.0)
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Wood',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Wood',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Wood_01'),DecalWidth=6.0,DecalHeight=6.0)
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Flesh',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumGround',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumCrystal',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumGround_Blue',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumCrystal_Blue',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Mud',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Mud')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_WhiteSand_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Dirt'),DecalWidth=20.0,DecalHeight=20.0)
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_YellowSand_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Dirt'),DecalWidth=20.0,DecalHeight=20.0)
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Grass',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Grass')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_YellowStone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')

	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone',DecalMaterials=(DecalMaterial'RX_FX_Munitions.bullet_decals.MDecal_Bullet_Stone'),DecalWidth=8.0,DecalHeight=8.0)

	MaxImpactEffectDistance=4000.0

	DecalMaterialParameterCurve=(Points=((InVal=0.0,OutVal=0.0),(InVal=4.0,OutVal=1.0)))
}