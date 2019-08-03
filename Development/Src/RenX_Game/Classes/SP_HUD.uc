class SP_HUD extends Rx_HUD;

/** Disabled functionality */

exec function SetShowScores(bool bNewValue) {
	// Do nothing
}

function DrawNewScorePanel() {
	// Do nothing
}

function ToggleScoreboard() {
	// Do nothing
}

function ToggleOverviewMap() {
	// Do nothing
}

function OpenOverviewMap() {
	// Do nothing
}

function CloseOverviewMap() {
	// Do nothing
}

defaultproperties
{
	PlayerNamesClass = None;
	HudMovieClass = class'SP_GFxHud'
	RxPauseMenuMovieClass = class'SP_GFxPauseMenu'
}