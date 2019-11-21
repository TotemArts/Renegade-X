class Rx_BlueprintModel extends Actor;

var SkeletalMeshComponent Visual;
var Rx_Weapon_Blueprint BoundWeapon;
var MaterialInterface CorrectMat, IncorrectMat;
var bool bWasValid;

event Tick(float DeltaTime)
{
	if(BoundWeapon != None && Visual.SkeletalMesh != None)
	{
		if(NeedsValidationUpdate())
		{
			RevalidateMat();
		}
	}
}

function bool NeedsValidationUpdate()
{
	return bWasValid != BoundWeapon.bValidPlacement;
	//return (bWasValid && !BoundWeapon.bValidPlacement) || (!bWasValid && BoundWeapon.bValidPlacement);
}

function RevalidateMat()
{
	local int i;

	for(i=0; i<Visual.SkeletalMesh.Materials.Length; i++)
	{
		if(BoundWeapon.bValidPlacement)
			Visual.SetMaterial(i,CorrectMat);

		else
			Visual.SetMaterial(i,IncorrectMat);
	}	

	bWasValid = BoundWeapon.bValidPlacement;
}

DefaultProperties
{
	RemoteRole=ROLE_None

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
		TickGroup=TG_DuringAsyncWork
		// Using a skylight for secondary lighting by default to be cheap
		// Characters and other important skeletal meshes should set bSynthesizeSHLight=true
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		bUpdateSkelWhenNotRendered=FALSE
		CollideActors=False
		BlockActors=FALSE
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		BlockRigidBody=FALSE
		LightEnvironment=MyLightEnvironment
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
	End Object
	CollisionComponent=SkeletalMeshComponent0
	Visual=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0)

	CorrectMat = Material'RX_WP_Blueprint.Materials.M_Blueprint_ObjectWireframe'
	IncorrectMat = MaterialInstanceConstant'RX_WP_Blueprint.Materials.M_Blueprint_ObjectWireframe_Error'
}