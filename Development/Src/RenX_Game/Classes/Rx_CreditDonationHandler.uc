class Rx_CreditDonationHandler extends Rx_VoteMenuHandler;

function Enabled(Rx_Controller p)
{
	super.Enabled(p);

	VoteChoice = new (self) class'Rx_VoteMenuChoice_Donate';
	VoteChoice.Handler = self;
	VoteChoice.Init();
}

// called when alt is pressed
function bool Disabled()
{
	if (VoteChoice == none) return true;

	if (VoteChoice.GoBack())
	{
		VoteChoice = none;
		return true;
	}
	else return false;
}


function Display(Canvas c, float HUDCanvasScale, float ConsoleMessagePosX, float ConsoleMessagePosY, Color ConsoleColor)
{
	local array<string> choices;

	choices = VoteChoice.GetDisplayStrings();
	choices.AddItem("ALT/CTRL: " $ BackString);

	DisplayChoices(c, HUDCanvasScale, ConsoleMessagePosX, ConsoleMessagePosY, ConsoleColor, choices);
}

function KeyPress(byte T)
{
}

DefaultProperties
{
}
