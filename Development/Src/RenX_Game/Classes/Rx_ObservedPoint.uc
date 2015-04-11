
class Rx_ObservedPoint extends Actor 
	placeable;
	
var() float Importance; // value between 0.0 and 1.0	

DefaultProperties
{
	bStatic = true
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Pawns"
	End Object
	Components.Add(Sprite)
	
	Importance = 1.0;
} 

