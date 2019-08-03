class Rx_Attachment_HeavyPistol extends Rx_WeaponAttachment_Varying;

var class<UDKExplosionLight> ImpactLightClass;

var int CurrentPath;

simulated function SpawnBeam(vector Start, vector End, bool bFirstPerson)
{
	local ParticleSystemComponent E;
	local actor HitActor;
	local vector HitNormal, HitLocation;

	if ( End == Vect(0,0,0) )
	{
		if ( !bFirstPerson || (Instigator.Controller == None) )
		{
	    	return;
		}
		// guess using current viewrotation;
		End = Start + vector(Instigator.Controller.Rotation) * WeaponClass.default.WeaponRange;
		HitActor = Instigator.Trace(HitLocation, HitNormal, End, Start, TRUE, vect(0,0,0),, TRACEFLAG_Bullet);
		if ( HitActor != None )
		{
			End = HitLocation;
		}
	}

	E = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, Start);
	E.SetVectorParameter('BeamEnd', End);
	if (bFirstPerson && !class'Engine'.static.IsSplitScreen())
	{
		E.SetDepthPriorityGroup(SDPG_Foreground);
	}
	else
	{
		E.SetDepthPriorityGroup(SDPG_World);
	}
}

simulated function FirstPersonFireEffects(Weapon PawnWeapon, vector HitLocation)
{
	local vector EffectLocation;

	Super.FirstPersonFireEffects(PawnWeapon, HitLocation);

	if (Instigator.FiringMode == 0 || Instigator.FiringMode == 3)
	{
		EffectLocation = UTWeapon(PawnWeapon).GetEffectLocation();
		SpawnBeam(EffectLocation, HitLocation, true);

		if (!WorldInfo.bDropDetail && Instigator.Controller != None && ImpactLightClass != None)
		{
			UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight(ImpactLightClass, HitLocation);
		}
	}
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{

	Super.ThirdPersonFireEffects(HitLocation);

	if ((Instigator.FiringMode == 0 || Instigator.FiringMode == 3))
	{
		SpawnBeam(GetEffectLocation(), HitLocation, false);
	}
}

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_WP_Pistol.Mesh.SK_HeavyPistol_3P'		
	End Object
	
	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	DefaultImpactEffect_Heroic=(ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Incendiary_Small',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	
	//ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Dirt_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
    //ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	//ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Stone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
    //ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Metal_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Metal')
    //ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Glass_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
    //ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Wood_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Wood')
    //ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
    //ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Water',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Water')
	//ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'RX_FX_Munitions.Impact_Bullet.P_Bullet_Impact_Flesh',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh')
	//ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumGround_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	//ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumCrystal_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	//ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumGround_Blue_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	//ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_TiberiumCrystal_Blue_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Glass')
	//ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Mud_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Mud')
	//ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_WhiteSand_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	//ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_YellowSand_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Dirt')
	//ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Grass_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Grass')
	//ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_YellowStone_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')
	//ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Snow_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Snow')
	//ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'RX_FX_Munitions2.Particles.bullets.P_Bullet_Impact_Snow_Heavy',Sound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Stone')

	BulletWhip=SoundCue'RX_SoundEffects.Bullet_WhizBy.SC_Bullet_WhizBy'
	BeamTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_Heavy'
	BeamTemplate_Heroic=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_Heavy_Heroic'

	WeaponClass = class'Rx_Weapon_HeavyPistol'
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_AutoRifle.Effects.MuzzleFlash'
	MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'
	MuzzleFlashDuration=2.5	
	
	ShellEjectPSCTemplate=ParticleSystem'RX_WP_Pistol.Effects.P_ShellCasing'
	ShellEjectDuration = 1.0
	ShellEjectSocket = ShellEjectSocket
	
	AimProfileName = Pistol
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Pistol'
}
