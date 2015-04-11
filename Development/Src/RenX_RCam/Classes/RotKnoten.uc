//-----------------------------------------------------------
// used to draw the inpoints of the Camerapath
//-----------------------------------------------------------
class RotKnoten extends Actor;

var bool bForC130;

function PostBeginPlay()
{
}

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EngineResources.StreamingPauseIcon'
		Scale=0.400000
	End Object
	Components.Add(Sprite)
}
