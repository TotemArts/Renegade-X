class nBab_PT_Vehicle extends Rx_PT_Vehicle;

var DynamicLightEnvironmentComponent MyLightEnvironment;

simulated function PostBeginPlay()
{
	SetShadowBoundsScale();
	super.PostBeginPlay();
}

function SetMaterial(MaterialInstanceConstant MIC)
{
	local MaterialInstanceConstant Parent;
	local MaterialInstanceConstant Temp;
	Temp = Mesh.CreateAndSetMaterialInstanceConstant(0);
	Parent = MIC;
	Temp.SetParent(Parent);
}

simulated function SetShadowBoundsScale()
{
	MyLightEnvironment = DynamicLightEnvironmentComponent(Mesh.LightEnvironment);
	MyLightEnvironment.LightingBoundsScale = Rx_MapInfo(WorldInfo.GetMapInfo()).GroundVehicleShadowBoundsScale;
	Mesh.SetLightEnvironment(MyLightEnvironment);
}

DefaultProperties
{
	//nBab
    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bSynthesizeSHLight=true
        bUseBooleanEnvironmentShadowing=FALSE
        //setting shadow frustum scale (nBab)
        LightingBoundsScale=1
    End Object
    Components.Add(MyLightEnvironment)

	Begin Object Name=WPawnSkeletalMeshComponent
		LightEnvironment=MyLightEnvironment
		bCacheAnimSequenceNodes=FALSE
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=true
		CastShadow=true
		BlockRigidBody=TRUE
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		Translation=(Z=8.0)
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2
		bChartDistanceFactor=true
		//bSkipAllUpdateWhenPhysicsAsleep=TRUE
		RBDominanceGroup=20
		Scale=1.075
		// Nice lighting for hair
		bUseOnePassLightingOnTranslucency=TRUE
		bPerBoneMotionBlur=true
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)
}