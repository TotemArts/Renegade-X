class Rx_SpottingArea extends Actor
	placeable
	implements(RxIfc_SpotMarker);

var() String NameOfArea;

simulated function bool IsEligibleSpottingMarker()
{
	return true;
}

simulated function String GetSpotName(){
	return NameOfArea;
}

simulated function String GetNonHTMLSpotName()
{
	return NameOfArea;
}

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
}
