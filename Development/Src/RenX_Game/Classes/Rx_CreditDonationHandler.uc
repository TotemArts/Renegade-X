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


function Display(Rx_HUD H)
{
	local array<string> choices;

	choices = VoteChoice.GetDisplayStrings();

	Rx_HUD(PlayerOwner.myHUD).CreateDonateMenuArray(choices);
}

function KeyPress(byte T)
{
}

DefaultProperties
{
}
