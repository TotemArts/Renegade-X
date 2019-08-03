class SP_GFxHud extends Rx_GFxHud;

function Initialize() {
	super.Initialize();
	DisableUnusedElements();
}

exec function SetLivingHUDVisible(bool visible) {
	Super.SetLivingHUDVisible(visible);
	DisableUnusedElements();
}

function DisableUnusedElements() {
	Scoreboard.SetVisible(false);
	BottomInfo.SetVisible(false);
	Credits.SetVisible(false);
	MatchTimer.SetVisible(false);
	VehicleCount.SetVisible(false);
	MineCount.SetVisible(false);
}

function AddGameEventMessage(string text) {
	// Do nothing
}

defaultproperties
{
}