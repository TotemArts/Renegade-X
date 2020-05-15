class Rx_CapturableMCT_MC extends Rx_CapturableMCT
placeable;

simulated function String GetHumanReadableName()
{
	return "Medical Center";
}

function string GetName()
{
   return "Medical Center";
}

defaultproperties
{
   BuildingInternalsClass  = class'Rx_CapturableMCT_MC_Internals'
   TeamID = 255

	IconTexture = Texture2D'RenxHUD.T_Tech_MC'
}