class Rx_Attachment_TiberiumAutoRifle_Blue extends Rx_WeaponAttachment_Varying;

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
		SkeletalMesh=SkeletalMesh'RX_WP_TiberiumAutoRifle.Mesh.SK_TiberiumAutolRifle_3P'
		Materials(0)=MaterialInstanceConstant'RX_WP_TiberiumAutoRifle.Materials.MI_TiberiumAutoRifle_Blue_1P'
		Scale=1.0
	End Object
	
	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Impact_CrystalBlue',Sound=SoundCue'RX_WP_TiberiumAutoRifle.Sounds.SC_BulletImpact_TibBlue')
	DefaultImpactEffect_Heroic=(ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Impact_CrystalRed',Sound=SoundCue'RX_WP_TiberiumAutoRifle.Sounds.SC_BulletImpact_TibBlue')
	//ImpactEffects(0)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_Impact_CrystalBlue',Sound=SoundCue'RX_WP_TiberiumAutoRifle.Sounds.SC_BulletImpact_TibBlue_Metal')
	
	BulletWhip=SoundCue'RX_WP_TiberiumAutoRifle.Sounds.SC_Bullet_WhizBy'
	BeamTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_InstantHit_Tracer_TibBlue'
	
	WeaponClass = class'Rx_Weapon_TiberiumAutoRifle_Blue'
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_MuzzleFlash_3P_Blue'
	MuzzleFlashLightClass=class'Rx_Light_Blue_MuzzleFlash'
	MuzzleFlashDuration=3.0
//	ImpactLightClass=none

	BeamTemplate_Heroic	= ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_InstantHit_Tracer_TibRed'
	MuzzleFlashPSCTemplate_Heroic= ParticleSystem'RX_WP_TiberiumAutoRifle.Effects.P_MuzzleFlash_3P_Red'
	MuzzleFlashLightClass_Heroic=class'Rx_Light_TiberiumFlechetteRifle_MuzzleFlashRed'
	
	ShellEjectPSCTemplate=ParticleSystem'RX_WP_AutoRifle.Effects.P_ShellCasing'
	ShellEjectDuration = 1.0
	ShellEjectSocket = ShellEjectSocket
	
	AimProfileName = TacticalRifle
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_AutoRifle'
}
