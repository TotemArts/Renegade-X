class Rx_SupportVehicle_DropOffChinook_Mask extends Rx_BasicPawn 
implements(RxIfc_SeekableTarget) ; 

var Rx_SupportVehicle_DropOffChinook ParentV;

 
function Init(Rx_SupportVehicle_DropOffChinook Par)
{
	ParentV = Par; 
}


function ToDestroy()
{
	Health=0; 
	super.ToDestroy();
}


/*********RxIfc_SeekableTarget**********/
function float GetAimAheadModifier()
{
	return 50.0;
}
function float GetAccelrateModifier()
{
	return 100.0;
}


simulated function vector GetAdjustedLocation()
{
	return location; 
}

/*********RxIfc_SeekableTarget**********/
//Collision / location mask for the Chinook's animation until a proper vehicle is made for it. 
DefaultProperties
{
	bDrawLocation 	= true 
	ActorName		= "Chinook"
	
	bShowHealth=false
	bAttractAA = true ; /*EDIT: I ... randomly considered it worth it one day----Getting this big ass animation to work with SAMs just isn't worth it. Just let them target the payload*/
	
	AntiAirAttentionPulseTime = 2.0
	
	Begin Object class=SkeletalMeshComponent Name=WSkeletalMesh	
		SkeletalMesh=SkeletalMesh'RX_VH_Chinook.Mesh.SK_VH_Chinook'		
		AlwaysLoadOnServer=true
		CastShadow=false
		AlwaysLoadOnClient=true
		BlockNonZeroExtent   = true  
		BlockZeroExtent      = true
		BlockActors=false
		CollideActors=true
		HiddenGame = true; 
		bIgnoreOwnerHidden = TRUE 
		bUpdateSkelWhenNotRendered=false
		bCastDynamicShadow=false
	End Object
	Mesh=WSkeletalMesh
	Components.Add(WSkeletalMesh)
	bHidden=false
	bAlwaysRelevant=true
	LifeSpan=38.4f
	
}
