
class Rx_PTPlayerSpot extends Actor placeable;

var() byte TeamNum;

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Pawns"
	End Object
	Components.Add(Sprite)	
	
	RemoteRole=ROLE_None
	NetUpdateFrequency=1.f
	bNoDelete=TRUE	
}