class Rx_GFxPauseMenu_ChatMenu extends Rx_GFxPauseMenu_View;

/*
TODO LIST
1. Cleanup clientmessage
2. Clear input text after enter
3. Enter means send to public
4. private text need to handle.
*/


var Rx_GFxPauseMenu PauseMenu;

var GFxClikWidget privateChatTextArea;
var GFxClikWidget privateChatScrollBar;
var GFxClikWidget playerScrollingList;
var GFxClikWidget playerListScrollBar;
var GFxClikWidget privateChatTextInput;
var GFxClikWidget ChatPrivateActionBar;
var GFxClikWidget publicChatTextArea;
var GFxClikWidget publicChatScrollBar;
var GFxClikWidget ChatPublicActionBar;
var GFxClikWidget publicChatTextInput;

var Rx_PRI PrivateSelectedPlayer;
/*
 * ChatView
 * ChatBar
 * 
 * privateChatTextArea
 * privateChatScrollBar
 * playerScrollingList
 * playerListScrollBar
 * privateChatTextInput
 * ChatPrivateActionBar
 * 
 * publicChatTextArea
 * publicChatScrollBar
 * ChatPublicActionBar
 * publicChatTextInput
 * */

var string lastPlayerName;

/** Configures the view when it is first loaded. */
function OnViewLoaded(Rx_GFxPauseMenu Menu)
{
	PauseMenu = Menu;

	//GetPC().ClientMessage("" $ self $ "loaded");
}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName) 
	{
		 case 'privateChatTextArea':
			if (privateChatTextArea == none || privateChatTextArea != Widget) {
				privateChatTextArea = GFxClikWidget(Widget);
			}
			GetLastSelection(privateChatTextArea);
			break;
		 case 'privateChatScrollBar':
			if (privateChatScrollBar == none || privateChatScrollBar != Widget) {
				privateChatScrollBar = GFxClikWidget(Widget);
			}
			break;
		 case 'playerScrollingList':
			if (playerScrollingList == none || playerScrollingList != Widget) {
				playerScrollingList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(playerScrollingList);
			//addeventlistener
			break;
		 case 'playerListScrollBar':
			if (playerListScrollBar == none || playerListScrollBar != Widget) {
				playerListScrollBar = GFxClikWidget(Widget);
			}
			break;
		 case 'privateChatTextInput':
			if (privateChatTextInput == none || privateChatTextInput != Widget) {
				privateChatTextInput = GFxClikWidget(Widget);
			}
			GetLastSelection(privateChatTextInput);
			break;
		 case 'ChatPrivateActionBar':
			if (ChatPrivateActionBar == none || ChatPrivateActionBar != Widget) {
				ChatPrivateActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(ChatPrivateActionBar);
			ChatPrivateActionBar.AddEventListener('CLIK_itemClick', OnChatPrivateActionBarItemClick);
			break;
		 case 'publicChatTextArea':
			if (publicChatTextArea == none || publicChatTextArea != Widget) {
				publicChatTextArea = GFxClikWidget(Widget);
			}
			GetLastSelection(publicChatTextArea);
			break;
		 case 'publicChatScrollBar':
			if (publicChatScrollBar == none || publicChatScrollBar != Widget) {
				publicChatScrollBar = GFxClikWidget(Widget);
			}
			break;
		 case 'ChatPublicActionBar':
			if (ChatPublicActionBar == none || ChatPublicActionBar != Widget) {
				ChatPublicActionBar = GFxClikWidget(Widget);
			}
			SetUpDataProvider(ChatPublicActionBar);
			ChatPublicActionBar.AddEventListener('CLIK_itemClick', OnChatPublicActionBarItemClick);
			//addeventlistener
			break;
		 case 'publicChatTextInput':
			if (publicChatTextInput == none || publicChatTextInput != Widget) {
				publicChatTextInput = GFxClikWidget(Widget);
			}
			GetLastSelection(publicChatTextInput);
			break;
		default:
			break;
	}
	return true;
}

function SetUpDataProvider(GFxClikWidget Widget)
{
	local byte i;
	local GFxObject DataProvider;

	local array<PlayerReplicationInfo> PRIArray;
	local PlayerReplicationInfo PRI;	

	DataProvider = CreateArray();

	switch (Widget)
	{
		case (playerScrollingList):
			foreach GetPC().WorldInfo.GRI.PRIArray(PRI) {
				if (Rx_PRI(PRI) == none || GetPC().Pawn.PlayerReplicationInfo == PRI || Rx_PRI(PRI).bBot) {
					continue;
				}
				PRIArray.AddItem(PRI);
			}
			
			if (PRIArray.Length > 22) {
				Widget.SetInt("rowCount", 22);
			} else {
				Widget.SetInt("rowCount", PRIArray.Length);
			}

			for (i=0; i < PRIArray.Length; i++) {
				DataProvider.SetElementString(i, "" $ PRIArray[i].PlayerName);
			}
			break;
		case (ChatPrivateActionBar):
			DataProvider.SetElementString(0, "SEND");
			//use privateMessage than private say
			break;
		case (ChatPublicActionBar):
			DataProvider.SetElementString(0, "ALL");
			DataProvider.SetElementString(1, "TEAM");
			break;
		default:
			return;
	}
	Widget.SetObject("dataProvider", DataProvider);
}
function bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	local string playerName;
	local Rx_PRI SelectedPlayer;
	local PlayerReplicationInfo PRI;	
	switch (ButtonName) 
	{
		case 'Enter':
			if (InputEvent == EInputEvent.IE_Pressed) {
				if (publicChatTextInput != none && publicChatTextInput.GetBool("visible") && publicChatTextInput.GetString("text") != "") {
					GetPC().Say(publicChatTextInput.GetString("text"));
					PlaySoundFromTheme('click', 'default');
					publicChatTextInput.SetString("text", "");
				} else if (privateChatTextInput != none && privateChatTextInput.GetBool("visible") && privateChatTextInput.GetString("text") != "") {
					if (playerScrollingList == none) {
						return false;
					}
					playerName = playerScrollingList.GetObject("dataProvider").GetElementString(playerScrollingList.GetInt("selectedIndex"));

					foreach GetPC().WorldInfo.GRI.PRIArray(PRI) {
						if (Rx_PRI(PRI) == none || GetPC().Pawn.PlayerReplicationInfo == PRI || Rx_PRI(PRI).bBot || Rx_PRI(PRI).PlayerName != playerName) {
							continue;
						}
						SelectedPlayer = Rx_PRI(PRI);
					}
					//temp for testing
					if (SelectedPlayer == none) {
						return false;
						//SelectedPlayer = Rx_PRI(GetPC().PlayerReplicationInfo);
					}

					PlaySoundFromTheme('click', 'default');
					Rx_Controller(GetPC()).PrivateMessage(SelectedPlayer.PlayerID, privateChatTextInput.GetString("text"));
					privateChatTextInput.SetString("text", "" );
				}
			}
			return true;
		default:
			return false;
	}
	
}
function GetLastSelection(GFxClikWidget Widget)
{
	if (Widget != none) {
		switch (Widget)
		{
			case (privateChatTextInput):
				Widget.SetString("text", "");
				break;
			case (publicChatTextInput):
				Widget.SetString("text", "");
				break;
			case (publicChatTextArea):
				Widget.SetString("htmlText", Rx_HUD(GetPC().myHUD).PublicChatMessageLog);
				Widget.SetFloat("position", Widget.GetFloat("maxscroll"));
				break;
			case (privateChatTextArea):
				Widget.SetString("htmlText", Rx_HUD(GetPC().myHUD).PrivateChatMessageLog);
				Widget.SetFloat("position", Widget.GetFloat("maxscroll"));
				break;
			default:
				return;
		}
	}
}

function AddChatMessage(string html, string raw, bool bIsPM)
{
	if (bIsPM)
		AddPrivateChatMessage(html, raw);
	else
		AddPublicChatMessage(html, raw);
}

function AddPrivateChatMessage(string html, string raw)
{
	if (privateChatTextArea != none) {
		privateChatTextArea.SetString("htmlText", Rx_HUD(GetPC().myHUD).PrivateChatMessageLog);
		privateChatTextArea.SetFloat("position", privateChatTextArea.GetFloat("maxscroll"));
	}

}
function AddPublicChatMessage(string html, string raw)
{
	if (publicChatTextArea != none) {
		publicChatTextArea.SetString("htmlText", Rx_HUD(GetPC().myHUD).PublicChatMessageLog);
		publicChatTextArea.SetString("rawMsg", raw);
		publicChatTextArea.SetFloat("position", publicChatTextArea.GetFloat("maxscroll"));
	}

}

function OnChatPublicActionBarItemClick(GFxClikWidget.EventData ev)
{
	if (publicChatTextInput == none || publicChatTextInput.GetString("text") == "") {
		return;
	}
	switch (ev.index)
	{
	  case 0: GetPC().Say(publicChatTextInput.GetString("text")); break;
	  case 1: GetPC().TeamSay(publicChatTextInput.GetString("text")); break;
	  default: break;
	}
	publicChatTextInput.SetString("text", "");
}


function OnChatPrivateActionBarItemClick(GFxClikWidget.EventData ev)
{
	local PlayerReplicationInfo PRI;	
	local Rx_PRI SelectedPlayer;

	local GFxObject dataProvider;
	local int selectedIndex;
	local string playerName;

	if (privateChatTextInput == none || privateChatTextInput.GetString("text") == "") {
		return;
	}
	if (playerScrollingList == none) {
		return;
	}

	dataProvider = playerScrollingList.GetObject("dataProvider");
	selectedIndex = playerScrollingList.GetInt("selectedIndex");

	playerName = dataProvider.GetElementString(selectedIndex);

	foreach GetPC().WorldInfo.GRI.PRIArray(PRI) {


		if (Rx_PRI(PRI) == none || GetPC().Pawn.PlayerReplicationInfo == PRI || Rx_PRI(PRI).bBot || Rx_PRI(PRI).PlayerName != playerName) {
			continue;
		}
		/*PRIArray.AddItem(PRI);*/
		SelectedPlayer = Rx_PRI(PRI);
	}
	if (SelectedPlayer == none) {
		return;
		//SelectedPlayer = Rx_PRI(GetPC().PlayerReplicationInfo);
	}
	switch (ev.index)
	{
	  //case 0: Rx_Controller(GetPC()).PrivateSay() break;
	  default: 
		Rx_Controller(GetPC()).PrivateMessage(SelectedPlayer.PlayerID, privateChatTextInput.GetString("text"));
		privateChatTextInput.SetString("text", "");
		break;
	}
}

DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="privateChatTextArea",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="privateChatScrollBar",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="playerScrollingList",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="playerListScrollBar",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="privateChatTextInput",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ChatPrivateActionBar",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="publicChatTextArea",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="publicChatScrollBar",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="ChatPublicActionBar",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="publicChatTextInput",WidgetClass=class'GFxClikWidget'))
}
