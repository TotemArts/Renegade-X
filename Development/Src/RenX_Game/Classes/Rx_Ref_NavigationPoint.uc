
class Rx_Ref_NavigationPoint extends NavigationPoint
   placeable;

var() byte TeamNum;
var() RxIfc_Refinery ConnectedRefinery;


function PostBeginPlay()
{
	local Rx_Building Ref, BestRef;
	local float BestDist,CurrentDist;

	if(ConnectedRefinery == None)
	{
		foreach AllActors(class'Rx_Building', Ref,class'RxIfc_Refinery')
		{
			if(Ref.GetTeamNum() == GetTeamNum())
			{
				CurrentDist = VSizeSq(Ref.Location - Location);
				if(BestRef == None || BestDist > CurrentDist)
				{
					BestRef = Ref;
					BestDist = CurrentDist;
				}
			}
		}

		if(BestRef != None)
		{
			ConnectedRefinery = BestRef;
			ConnectedRefinery.SetRefNavPoint(Self);
		}
	}
}

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
