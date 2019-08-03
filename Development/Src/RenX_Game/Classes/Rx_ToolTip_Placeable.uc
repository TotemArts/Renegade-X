class Rx_ToolTip_Placeable extends Actor implements (Rx_ObjectTooltipInterface) 
	placeable;

/** Base cylinder component for collision */
// var() editconst const CylinderComponent	CylinderComponent;
var() CylinderComponent       CollisionCylinder;

var() bool bEnabled;
var() bool bAimToDisplay;
var() float AimToDisplayAngleDotProduct;
var() string tooltip;
var() string keybindToLookUp;
var() string ReadName;


simulated function string GetTooltip(Rx_Controller PC)
{
	local vector cameraLoc;
	local rotator cameraRot;

	if (PC.Pawn != None)
			{
				PC.GetPlayerViewPoint(cameraLoc, cameraRot);

				if ( bEnabled && (!bAimToDisplay  || Normal(Location - cameraLoc) dot Normal(vector(cameraRot)) > AimToDisplayAngleDotProduct) )
					{
						// Replace {placeholder} substring with keybind:
						return Repl(tooltip, "{GBA_ThisKeyBind}", Caps(UDKPlayerInput(PC.PlayerInput).GetUDKBindNameFromCommand(keybindToLookUp)), true);
					}
			}
	return "";
}

simulated function bool IsTouchingOnly()
{
	return true;
}

simulated function bool IsBasicOnly()
{
	return false;
}


simulated function string GetHumanReadableName()
{
	return ReadName;
}



simulated function OnToggle(SeqAct_Toggle Action)
{
	/** 
	InputLinks(0)=(LinkDesc="Turn On")
	InputLinks(1)=(LinkDesc="Turn Off")
	InputLinks(2)=(LinkDesc="Toggle")
	**/

	if(Action.InputLinks[0].bHasImpulse)
	{ 
		bEnabled = True;
	}
	if(Action.InputLinks[1].bHasImpulse)
	{ 
		bEnabled = False;
	}
	if(Action.InputLinks[2].bHasImpulse)
	{ 
		bEnabled = !bEnabled;
	}
}



defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Trigger'
		HiddenGame=False
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Triggers"
	End Object
	Components.Add(Sprite)

	Begin Object Class=CylinderComponent Name=CollisionCmp
		CollisionRadius     = 75.0f
		CollisionHeight     = 50.0f
		bAlwaysRenderIfSelected=true
		BlockNonZeroExtent  = True
		BlockZeroExtent     = false
		bDrawNonColliding   = True
		bDrawBoundingBox    = False
		BlockActors         = False
		CollideActors       = True
	End Object
	CollisionComponent = CollisionCmp
	CollisionCylinder  = CollisionCmp
	Components.Add(CollisionCmp)

	bHidden=true
	CollisionType       = COLLIDE_TouchAllButWeapons
	bCollideActors=true

	tooltip = "Press <font color='#ff0000' size='20'>[ {GBA_ThisKeyBind} ]</font> to interact";
	keybindToLookUp = "GBA_Use" ;
	ReadName = "Tool Tip";

	bEnabled = True;
	bAimToDisplay = False;
	AimToDisplayAngleDotProduct = 0.9;

}



