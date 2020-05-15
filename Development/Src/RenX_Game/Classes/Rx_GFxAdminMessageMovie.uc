class Rx_GFxAdminMessageMovie extends GFxMoviePlayer;

var GFxClikWidget AcceptButton;
var GFxObject Root, TextBox;

var array<string> AdminMessageQueue;

function Init(optional LocalPlayer LocPlay)
{
	Start();
	Advance(0.f);

	Root = GetVariableObject("_root");
	TextBox = GetVariableObject("_root.textMessage");
}

function OnAcceptButtonPress(GFxClikWidget.EventData ev)
{
	PopAdminMessage();
}

function SetMessage(string Message)
{
	TextBox.SetString("htmlText", Message);
	Start();
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bWasHandled;

	bWasHandled = false;

	switch (WidgetName)
	{
		case 'AcceptButton':
			if (AcceptButton == none || AcceptButton != Widget)
				AcceptButton = GFxClikWidget(Widget);

			AcceptButton.AddEventListener('CLIK_buttonClick', OnAcceptButtonPress);
			bWasHandled = true;
		break;
	}

	return bWasHandled;
}

// Admin message queue management

function bool HasAdminMessage() {
	return AdminMessageQueue.Length != 0;
}

function UpdateAdminMessage() {
	if (HasAdminMessage()) {
		// There's an admin message in the queue; set it
		SetMessage(AdminMessageQueue[0]);
	}
	else {
		// There is no admin message to display; hide text
		Close(false);
	}
}

function PushAdminMessage(coerce string sMessage) {
	// Push message to queue
	AdminMessageQueue.AddItem(sMessage);

	// Update current message
	UpdateAdminMessage();
}

function PopAdminMessage() {
	if (HasAdminMessage()) {
		// Pop front message from queue
		// TODO: Log message confirmation back to server?
		AdminMessageQueue.Remove(0, 1);

		// Update current message
		UpdateAdminMessage();
	}
}

DefaultProperties
{
	//SoundThemes(0)=(ThemeName=default,Theme=UISoundTheme'renxfrontend.Sounds.SoundTheme')
	bDisplayWithHudOff = false
	MovieInfo = SwfMovie'RenXAdminMessage.RenXAdminMessage'
	TimingMode = TM_Real
	Priority = 999
	bCaptureInput = true
	bIgnoreMouseInput = false
	bShowHardwareMouseCursor = true

	WidgetBindings.Add((WidgetName="AcceptButton",WidgetClass=class'GFxClikWidget'))
}
