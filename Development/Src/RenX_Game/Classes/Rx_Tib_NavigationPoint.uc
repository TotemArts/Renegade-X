
class Rx_Tib_NavigationPoint extends NavigationPoint
   placeable;

var() byte TeamNum;


simulated event byte ScriptGetTeamNum () 
{
   return TeamNum;
}

simulated function byte GetTeamNum() {
	return TeamNum;
}


defaultproperties
{
   /**
   Begin Object Class=SpriteComponent Name=SpriteY ObjName=SpriteY
      Sprite=Texture2D'EngineResources.S_Pickup'
   End Object
   
   Components(0)=SpriteY
   */
   
}
