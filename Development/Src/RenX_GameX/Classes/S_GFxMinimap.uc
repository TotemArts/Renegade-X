class S_GFxMinimap extends Rx_GFxMinimap;

function array<GFxObject> GenGDIIcons(int IconCount, optional bool bSquad)
{
	local ASColorTransform ColorTransform;
   	local array<GFxObject> Icons;
   	local GFxObject IconMC;
    local int i;
	for (i = 0; i < IconCount; i++)
    {
        IconMC = icons_Friendly.AttachMovie("FriendlyBlips", "GDI_Player"$IconsFriendlyCount++);
		//@roxez: Debugging blips
        //IconMC = icons_Friendly.AttachMovie("DebugBlips", "GDI_Player"$IconsFriendlyCount++);
        ColorTransform.multiply.R = 0.25;
		ColorTransform.multiply.G = 0.25;
		ColorTransform.multiply.B = 0.25;
		ColorTransform.add.R = 0.0;
		ColorTransform.add.G = 0.0;
		ColorTransform.add.B = 0.75;
		IconMC.SetColorTransform(ColorTransform);
        Icons[i] = IconMC;
    }
    return Icons;
}

function array<GFxObject> GenGDIVehicleIcons(int IconCount, optional bool bSquad)
{
	local ASColorTransform ColorTransform;
   	local array<GFxObject> Icons;
   	local GFxObject IconMC;
    local int i;
	for (i = 0; i < IconCount; i++)
    {
        IconMC = icons_Friendly.AttachMovie("VehicleMarker", "GDI_Vehicle"$IconsVehicleFriendlyCount++);
		ColorTransform.multiply.R = 0.25;
		ColorTransform.multiply.G = 0.25;
		ColorTransform.multiply.B = 0.25;
		ColorTransform.add.R = 0;
		ColorTransform.add.G = 0;
		ColorTransform.add.B = 0.75;
		IconMC.SetColorTransform(ColorTransform);
        Icons[i] = IconMC;
    }
    return Icons;
}