class Rx_GFxPauseMenu_DonateMenu extends Rx_GFxPauseMenu_View;

var Rx_GFxPauseMenu PauseMenu;

var GFxObject CurrentView;
var GFxObject PlayerHeader;

var GFxClikWidget DonateScrollingList;
var GFxClikWidget PlayerCreditsLabel;
var GFxClikWidget DonateTextInput;
var GFxClikWidget DonateToPlayerButton;
var GFxClikWidget DonateToTeamButton;
var GFxClikWidget DonateToTeamAllButton;

/** Configures the view when it is first loaded. */
function OnViewLoaded(Rx_GFxPauseMenu Menu)
{
	PauseMenu = Menu;
	CurrentView = GetObject("currentView");
	//in order to access non clik, we have to access DonateView's currentView. only then we can access the instance.
	PlayerHeader = CurrentView.GetObject("PlayerHeader");
}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName) 
	{
		case 'donateScrollingList':
			if (DonateScrollingList == none || DonateScrollingList != Widget) {
				DonateScrollingList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(DonateScrollingList);
			DonateScrollingList.Setint("selectedIndex", -1);
			//wire events
			//if it selected, what does it do? later when we finish up then we fetch the values.
			break;
		case 'playerCreditsLabel':
			if (PlayerCreditsLabel == none || PlayerCreditsLabel != Widget) {
				PlayerCreditsLabel = GFxClikWidget(Widget);
			}
			GetLastSelection(PlayerCreditsLabel);
			//register with events. use tick as a backup
			//if delegate triggers, then we update the value here
			break;
		case 'donateTextInput':
			if (DonateTextInput == none || DonateTextInput != Widget) {
				DonateTextInput = GFxClikWidget(Widget);
			}
			GetLastSelection(DonateTextInput);
			DonateTextInput.AddEventListener('CLIK_focusIn', OnDonateTextInputFocusIn);
			DonateTextInput.AddEventListener('CLIK_focusOut', OnDonateTextInputFocusOut);
			//DonateTextInput.AddEventListener('CLIK_textChange', OnDonateTextInputTextChange);
			break;
		case 'donateToPlayerButton':
			if (DonateToPlayerButton == none || DonateToPlayerButton != Widget) {
				DonateToPlayerButton = GFxClikWidget(Widget);
			}
			//the initial condition is player have cash.
			GetLastSelection(DonateToPlayerButton);
			//wire events
			DonateToPlayerButton.AddEventListener('CLIK_press', OnDonateToPlayerButtonPress );
			break;
		case 'donateToTeamButton':
			if (DonateToTeamButton == none || DonateToTeamButton != Widget) {
				DonateToTeamButton = GFxClikWidget(Widget);
			}
			//setup disabled until conditions have met
			GetLastSelection(DonateToTeamButton);
			//wire events
			DonateToTeamButton.AddEventListener('CLIK_press', OnDonateToTeamButtonPress );
			break;
		case 'donateToTeamAllButton':
			if (DonateToTeamAllButton == none || DonateToTeamAllButton != Widget) {
				DonateToTeamAllButton = GFxClikWidget(Widget);
			}
			//setup disabled until conditions have met
			GetLastSelection(DonateToTeamAllButton);
			//wire events
			DonateToTeamAllButton.AddEventListener('CLIK_press', OnDonateToTeamAllButton );
			break;
		default:
			break;
	}
	return true;
}

/**Called every update Tick*/
function TickHUD() 
{
	if (!bMovieIsOpen) {
		return;
	}

	if (int(PlayerCreditsLabel.GetString("text")) != int(Rx_PRI(GetPC().Pawn.PlayerReplicationInfo).GetCredits())) {
		PlayerCreditsLabel.SetString("text", "" $ int(Rx_PRI(GetPC().Pawn.PlayerReplicationInfo).GetCredits()) );
	}
}
function SetUpDataProvider(GFxClikWidget Widget)
{
	local byte i;
	local GFxObject DataProvider;
	local GFxObject TempObj;

	
	local array<PlayerReplicationInfo> PRIArray;
	local PlayerReplicationInfo PRI;	
	
	
	DataProvider = CreateArray();

	switch (Widget) 
	{
		case (DonateScrollingList):
			foreach GetPC().WorldInfo.GRI.PRIArray(PRI) {
				if (Rx_PRI(PRI) == none || GetPC().Pawn.PlayerReplicationInfo == PRI || !GetPC().WorldInfo.GRI.OnSameTeam(GetPC().Pawn.PlayerReplicationInfo, PRI)) {
					continue;
				}
				PRIArray.AddItem(PRI);
			}
			
			Widget.SetInt("rowCount", PRIArray.Length);

			for (i=0; i < PRIArray.Length; i++) {
				TempObj = CreateObject("Object");

				TempObj.SetInt("playerNum", i);
				TempObj.SetString("MVPStatus", ""); //TEMP
				TempObj.SetBool("isMVP", false);//TEMP
				TempObj.SetString("playerCredits", "" $ int(Rx_PRI(PRIArray[i]).GetCredits()));
				TempObj.SetString("playerName", "" $ Rx_PRI(PRIArray[i]).PlayerName);

				DataProvider.SetElementObject(i, TempObj);
			}
			break;
		default:
			return;
	}
	Widget.SetObject("dataProvider", DataProvider);
}

function GetLastSelection(GFxClikWidget Widget)
{
	local array<PlayerReplicationInfo> PRIArray;
	local PlayerReplicationInfo PRI;	

	if (Widget != none ) {
		switch (Widget) 
		{
			case (PlayerCreditsLabel) :
				Widget.SetText("" $ int(Rx_PRI(GetPC().Pawn.PlayerReplicationInfo).GetCredits()));
				return;
			case (DonateTextInput) :
				Widget.SetText("" $ 0);
				break;
			case (DonateToPlayerButton):
			case (DonateToTeamButton):
			case (DonateToTeamAllButton):

				foreach GetPC().WorldInfo.GRI.PRIArray(PRI) {
					if (Rx_PRI(PRI) == none || GetPC().Pawn.PlayerReplicationInfo == PRI || !GetPC().WorldInfo.GRI.OnSameTeam(GetPC().Pawn.PlayerReplicationInfo, PRI)) {
						continue;
					}
					PRIArray.AddItem(PRI);
				}
				
				if (Rx_PRI(GetPC().Pawn.PlayerReplicationInfo) != none 
					&& Rx_PRI(GetPC().Pawn.PlayerReplicationInfo).GetCredits() > 0 
					&& PRIArray.Length > 1) {
					Widget.SetBool("disabled", false);
				} else {
					Widget.SetBool("disabled", true);
				}
				break;
				/*
				 
			}
				 * */
			default:
				return;
		}
	}
}


function OnDonateTextInputFocusIn(GFxClikWidget.EventData ev)
{
	IgnoreAlphabeticals(ev);

}
function OnDonateTextInputFocusOut(GFxClikWidget.EventData ev)
{
	ClearFocusIgnoreKeys();
}

function OnDonateToPlayerButtonPress(GFxClikWidget.EventData ev) 
{
	local string playerName;
	local int credits;
	local GFxObject dataProvider;
	local int selectedIndex;

	//if the donate list is selected, and we have credits, then we perform the donation
	if (GetPC().WorldInfo.GRI.PRIArray.Length <=1 
		|| DonateScrollingList == none
		|| DonateScrollingList.GetInt("selectedIndex") <= -1
		|| Rx_PRI(GetPC().Pawn.PlayerReplicationInfo).GetCredits() <= 0
		|| DonateTextInput == none
		|| DonateTextInput.GetString("text") == "") {
			`log("Donate fail");
		return;
	}

	dataProvider = DonateScrollingList.GetObject("dataProvider");
	selectedIndex = DonateScrollingList.GetInt("selectedIndex");

	playerName = dataProvider.GetElementMemberString(selectedIndex, "playerName");
	credits = int(DonateTextInput.GetString("text"));

	Rx_Controller(GetPC()).Donate(playerName, credits);
	PauseMenu.ReturnToBackground();
	Rx_HUD(GetPC().myHUD).CompletePauseMenuClose();
}

function OnDonateToTeamButtonPress(GFxClikWidget.EventData ev) 
{
	local int credits;

	if (GetPC().WorldInfo.GRI.PRIArray.Length <=1 
		|| Rx_PRI(GetPC().Pawn.PlayerReplicationInfo).GetCredits() <= 0
		|| DonateTextInput == none
		|| DonateTextInput.GetString("text") == "") {
		`log("Donate fail");
		return;
	}

	credits = int(DonateTextInput.GetString("text"));

	Rx_Controller(GetPC()).TeamDonate(credits);
	PauseMenu.ReturnToBackground();
	Rx_HUD(GetPC().myHUD).CompletePauseMenuClose();
}

function OnDonateToTeamAllButton(GFxClikWidget.EventData ev) 
{
	if (GetPC().WorldInfo.GRI.PRIArray.Length <=1 
		|| Rx_PRI(GetPC().Pawn.PlayerReplicationInfo).GetCredits() <= 0) {
		`log("Donate fail");
		return;
	}

	Rx_Controller(GetPC()).TeamDonate(int(Rx_PRI(GetPC().Pawn.PlayerReplicationInfo).GetCredits()));
	PauseMenu.ReturnToBackground();
	Rx_HUD(GetPC().myHUD).CompletePauseMenuClose();
}

function IgnoreAlphabeticals(GFxClikWidget.EventData ev)
{
	local byte i;
	for (i = 32; i < 128; i ++) {
		if (i == Clamp(i, 48, 57)) {
			continue;
		}
		AddFocusIgnoreKey(name(chr(i)));
	}

	AddFocusIgnoreKey(name("LeftShift"));
	AddFocusIgnoreKey(name("RightShift"));
	AddFocusIgnoreKey(name("Spacebar"));
	AddFocusIgnoreKey(name("Escape"));
}

DefaultProperties
{
	//Donate
	
	SubWidgetBindings.Add((WidgetName="donateScrollingList",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="playerCreditsLabel",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="donateTextInput",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="donateToPlayerButton",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="donateToTeamButton",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="donateToTeamAllButton",WidgetClass=class'GFxClikWidget'))

	//donateScrollingList
	//playerCreditsLabel
	//donteToPlayerButton
	//donteToTeamButton
	//donateToTeamAllButton
	//donateScrollingList

	//test player header -  

	/*
	 * //{label:"SKIRMISH", data:"SkirmishMenu"}
var dataArray:Array = new Array();
for (var i=0; i<32; i++) {
	dataArray.push({playerNum:i+1, MVPStatus:"MVP *10", isMVP:true, playerCredits:"1337", playerName:"player " + (i+1)});
	//dataArray.push("player " + i);
}
donateScrollingList.rowCount = dataArray.length;
//donateScrollingList.autoScrollBar = true;
//donateScrollingList.wrapping = "stick";
donateScrollingList.dataProvider = dataArray;
//donateScrollingList.rowCount = 9;
	 * */
}
