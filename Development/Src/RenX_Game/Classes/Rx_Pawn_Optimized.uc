/**
 * RxGame
 *
 * */
class Rx_Pawn_Optimized extends Rx_Pawn;


DefaultProperties
{
	//nBab
	/*Begin Object Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=.2
		//setting shadow frustum scale (nBab)
		LightingBoundsScale=0.2
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment*/

	Begin Object Name=ParachuteMeshComponent
		SkeletalMesh = SkeletalMesh'RX_CH_Parachute.Mesh.SK_RamAir'
		AnimTreeTemplate = AnimTree'RX_CH_Parachute.Mesh.SK_RamAir_AnimTree'
		MorphSets.Add(MorphTargetSet'RX_CH_Parachute.Mesh.SK_RamAir_MorphTargetSet')
		HiddenGame = TRUE
		HiddenEditor = TRUE
		BlockRigidBody=false
		bUsePrecomputedShadows=FALSE
		Translation = (X= 0, Y= 0, Z =30)
		AlwaysCheckCollision = false
	End Object

	
	Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'RX_CH_Animations.Anims.AT_Character_Modular'
		AnimSets(0)=AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
		Scale=1.0
		bUpdateSkelWhenNotRendered=false
		//bCastHiddenShadow = true
		//BlockZeroExtent=True				// Uncomment to enable accurate hitboxes (1/3)
		//CollideActors=true;					// Uncomment to enable accurate hitboxes (2/3)
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)

	Begin Object Name=CollisionCylinder
		CollisionRadius=16
		CollisionHeight=50 //60		
		BlockZeroExtent=False				// Uncomment to enable accurate hitboxes (3/3)
	End Object
	CrouchHeight=35
	CrouchRadius=16.0
	
	Begin Object Name=FirstPersonArms
		// PhysicsAsset=None
		FOV=55
		Animations=MeshSequenceA
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=true
		CastShadow=true
		bAllowAmbientOcclusion=true
		bCastDynamicShadow=true
		bSelfShadowOnly=true
	End Object
	ArmsMesh[0]=FirstPersonArms

	Begin Object Name=FirstPersonArms2
		// PhysicsAsset=None
		FOV=55
		Scale3D=(Y=-1.0)
		Animations=MeshSequenceB
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=true
		CastShadow=true
		bSelfShadowOnly=true
		bAllowAmbientOcclusion=true
	End Object
	ArmsMesh[1]=FirstPersonArms2
	

	Begin Object Name=GooDeath
		Template=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_ChemDamage'
		bAutoActivate=false
	End Object
	BioBurnAway=GooDeath
	BioBurnAwayTime=3.5f
	BioEffectName=BioRifleDeathBurnTime
	
	Begin Object Name=InitVoice
		bUseOwnerLocation = true
		bStopWhenOwnerDestroyed = true
		SoundCue = SoundCue'RX_CharSnd_Generic.gdi_male.Pawn_Voice'
	End Object
	
	VoiceComponent=InitVoice
	Components.Add(InitVoice); 
}