class S_GFxHUD extends Rx_GFxHud;

exec function InitializeHUDVars() 
{
	UpdateHealthGFx(,,,true);
	UpdateWeaponGFx(false, true);
	UpdateVeterancyGFx(true);


	VoteMC = GetVariableObject("_root.VoteTextBase");

	//Progress Bar
	UpdateLoadingBar();

	HideLoadingBar();
//---------------------------------------------------
	//Radar implementation
	if (Minimap == none)
	{
		MinimapBase = GetVariableObject("_root.minimapBase");
		CompassMC = MinimapBase.GetObject("CompassMC");
		Minimap = Rx_GFxMinimap(GetVariableObject("_root.minimapBase.minimap", class'S_GFxMinimap'));
		Minimap.init(self);
	}

	if (Marker == none) {
		Marker = Rx_GFxMarker(GetVariableObject("_root.MarkerContainer", class'Rx_GFxMarker'));
		Marker.init(self);
	}
}