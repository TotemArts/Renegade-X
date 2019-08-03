class SP_GFxPauseMenu extends Rx_GFxPauseMenu;

function SetupButtonGroup() {
	Super.SetupButtonGroup();
	ScoreboardButton.SetBool("disabled", true);
}

defaultproperties
{
}