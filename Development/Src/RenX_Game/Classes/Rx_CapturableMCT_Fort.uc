class Rx_CapturableMCT_Fort extends Rx_CapturableMCT
placeable;

simulated function String GetHumanReadableName()
{
	return "Fort";
}

function string GetName()
{
    return "Fort";
}

defaultproperties
{
   BuildingInternalsClass  = class'Rx_CapturableMCT_Fort_Internals'
   TeamID = 255
}