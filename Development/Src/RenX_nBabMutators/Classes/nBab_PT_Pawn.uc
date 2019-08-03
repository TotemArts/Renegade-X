class nBab_PT_Pawn extends Rx_PT_Pawn;

simulated function PostBeginPlay()
{
	SetShadowBoundsScale();
	super.PostBeginPlay();
}

simulated function SetShadowBoundsScale()
{
	MyLightEnvironment = DynamicLightEnvironmentComponent(Mesh.LightEnvironment);
	MyLightEnvironment.LightingBoundsScale = Rx_MapInfo(WorldInfo.GetMapInfo()).CharacterShadowBoundsScale;
	MyLightEnvironment.bSynthesizeSHLight=true;
    MyLightEnvironment.bUseBooleanEnvironmentShadowing=False;
	Mesh.SetLightEnvironment(MyLightEnvironment);
}

DefaultProperties
{
	Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'RX_CH_Animations.Anims.AT_Character_PTScene'
		LightEnvironment=MyLightEnvironment
	End Object

	bIsPtPawn=true

	RemoteRole=ROLE_None
}