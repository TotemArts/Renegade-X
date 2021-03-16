class Rx_CapturableMCT_Fort extends Rx_CapturableMCT
placeable;


var(PurchaseTerminal) Array<class<Rx_Vehicle_PTInfo> > CustomGDIVehicleList,CustomNodVehicleList;

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

	CustomGDIVehicleList.Add(class'RenX_Game.Rx_Vehicle_GDI_Humvee_PTInfo')
	CustomGDIVehicleList.Add(class'RenX_Game.Rx_Vehicle_GDI_APC_PTInfo')
	CustomGDIVehicleList.Add(class'RenX_Game.Rx_Vehicle_GDI_MRLS_PTInfo')
	CustomGDIVehicleList.Add(class'RenX_Game.Rx_Vehicle_GDI_MediumTank_PTInfo')
	CustomGDIVehicleList.Add(class'RenX_Game.Rx_Vehicle_GDI_MammothTank_PTInfo')
	CustomGDIVehicleList.Add(class'RenX_Game.TS_Vehicle_GDI_Wolverine_PTInfo')
   	CustomGDIVehicleList.Add(class'RenX_Game.TS_Vehicle_GDI_HMRLS_PTInfo')
   	CustomGDIVehicleList.Add(class'RenX_Game.TS_Vehicle_GDI_Titan_PTInfo')

	CustomNodVehicleList.Add(class'RenX_Game.Rx_Vehicle_Nod_Buggy_PTInfo')
	CustomNodVehicleList.Add(class'RenX_Game.Rx_Vehicle_Nod_APC_PTInfo')
	CustomNodVehicleList.Add(class'RenX_Game.Rx_Vehicle_Nod_Artillery_PTInfo')
	CustomNodVehicleList.Add(class'RenX_Game.Rx_Vehicle_Nod_FlameTank_PTInfo')
	CustomNodVehicleList.Add(class'RenX_Game.Rx_Vehicle_Nod_LightTank_PTInfo')
	CustomNodVehicleList.Add(class'RenX_Game.Rx_Vehicle_Nod_StealthTank_PTInfo')
 	CustomNodVehicleList.Add(class'RenX_Game.TS_Vehicle_Nod_Buggy_PTInfo')
 	CustomNodVehicleList.Add(class'RenX_Game.TS_Vehicle_Nod_ReconBike_PTInfo')
 	CustomNodVehicleList.Add(class'RenX_Game.TS_Vehicle_Nod_TickTank_PTInfo')

	IconTexture = Texture2D'RenxHUD.T_Tech_Fort'
}