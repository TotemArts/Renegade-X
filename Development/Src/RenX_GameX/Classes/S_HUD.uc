class S_HUD extends Rx_HUD;

/*simulated function PostBeginPlay() 
{
	super.PostBeginPlay();
	
	Scoreboard = new class'S_GFxUIScoreboard';
	Scoreboard.LocalPlayerOwnerIndex = GetLocalPlayerOwnerIndex();
	Scoreboard.SetViewScaleMode(SM_ExactFit);
	Scoreboard.SetTimingMode(TM_Real);
	Scoreboard.ExternalInterface = self;
}*/

function AddTeamJoinMessage(PlayerReplicationInfo Player, UTTeamInfo NewTeam)
{
	HudMovie.AddGameEventMessage("<font color='" $  GetTeamColour(NewTeam.GetTeamNum()) $"'>" $CleanHTMLMessage(Player.PlayerName)$"</font> joined <font color='"$ GetTeamColour(NewTeam.GetTeamNum()) $"'>"$ class'S_Game'.static.GetTeamName(NewTeam.GetTeamNum()) $"</font>");
}

function AddFakedTeamJoinMessage(string PlayerName, int TeamIndex)
{
	LocalPlayer( GetALocalPlayerController().Player).ViewportClient.ViewportConsole.OutputText( PlayerName@class'GameMessage'.Default.NewTeamMessage@ class'S_Game'.static.GetTeamName(TeamIndex)$class'GameMessage'.Default.NewTeamMessageTrailer );
	HudMovie.AddGameEventMessage("<font color='" $  GetTeamColour(TeamIndex) $"'>" $CleanHTMLMessage(PlayerName)$"</font> joined <font color='"$ GetTeamColour(TeamIndex) $"'>"$ class'S_Game'.static.GetTeamName(TeamIndex) $"</font>");
}

function OpenOverviewMap()
{
	bToggleOverviewMap = true;

	//ToggleOverviewMap
	OverviewMapMovie = new class'S_GFxOverviewMap';
	OverviewMapMovie.LocalPlayerOwnerIndex = GetLocalPlayerOwnerIndex();
	if(Canvas != none)
		OverviewMapMovie.SetViewport(0,0,Canvas.ClipX, Canvas.ClipY);
	OverviewMapMovie.SetViewScaleMode(SM_ExactFit);
	OverviewMapMovie.SetTimingMode(TM_Real);
	//OverviewMapMovie.ExternalInterface = self;
	OverviewMapMovie.Start();
	HudMovie.OverviewMapMovie = OverviewMapMovie;


	//Hide our hud
	SetVisible(false);
}

DefaultProperties 
{
	YellowColor=(R=50,G=96,B=255,A=255)
	GDIColor = "#3260FF"
	HudMovieClass = class 'S_GFxHud'
	GIHudMovieClass = class 'S_GFxGameinfoHud'
	ScoreboardClass = class'S_GFxUIScoreboard'
	TargetingBoxClass = class 'S_Hud_TargetingBox'
	PlayerNamesClass = class 'S_Hud_PlayerNames'
	OverviewMapClass = class'S_GfxOverviewMap'
}