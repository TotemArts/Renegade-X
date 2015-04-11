class VaultActor extends Actor 
	placeable;

var() const editconst DynamicLightEnvironmentComponent LightEnvironment;

var() int Height;
var() int PushDistance;

// Vault type
var() enum EType
{
        Tall,
        Medium,
        Small
}Type;

//Vault direction
var() enum EDirection
{
	Left,
	Right,
	Forward,
	Back

}Direction;


defaultproperties
{

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=TRUE
    End Object
    LightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)

    Begin Object class=StaticMeshComponent Name=BaseMesh
        StaticMesh=StaticMesh'RX_CH_Animations.Mesh.SM_VaultShape_Box'
        LightEnvironment=MyLightEnvironment
        CollideActors=true		
    End Object
    Components.Add(BaseMesh)

    Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	CollisionComponent=BaseMesh
	bCollideActors=True
	bBlockActors=True
	
	bHidden=True

	Height = 400
	PushDistance = 200
	Type = Medium
	

}