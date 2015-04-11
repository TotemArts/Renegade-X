
class Rx_Ref_NavigationPoint extends NavigationPoint
   placeable;

var() byte TeamNum;


simulated event byte ScriptGetTeamNum ( ) 
{
   return TeamNum;
}

simulated function byte GetTeamNum() {
	return TeamNum;
}


defaultproperties
{
   /**
   Begin Object Class=SpriteComponent Name=SpriteX ObjName=SpriteX
      Sprite=Texture2D'EnvyEditorResources.DefensePoint'
   End Object
   
   Components(0)=SpriteX
  */
   
}
