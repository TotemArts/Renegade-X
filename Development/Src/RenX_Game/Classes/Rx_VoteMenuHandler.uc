class Rx_VoteMenuHandler extends Object;

/** Define all vote submenus. Code is limited to work with 1-9 choices. */
var array<class<Rx_VoteMenuChoice> > VoteChoiceClasses;

/** Current vote submenu. */
var Rx_VoteMenuChoice VoteChoice;

/** Exit (or go back) string displayed in menu. */
var string ExitString;
var string BackString;

var Rx_Controller PlayerOwner;

// called when vote menu is shown
function Enabled(Rx_Controller p)
{
	PlayerOwner = p;
}

// called when alt is pressed
function bool Disabled()
{
	if (VoteChoice != none)
	{
		if (VoteChoice.GoBack())
		{
			VoteChoice = none;
		}

		return false; // do not kill vote menu yet
	}
	else return true; // return true to kill vote menu
}

// called from submenu to close handler
function Terminate()
{
	VoteChoice = none;
	PlayerOwner.DisableVoteMenu();
}

function Display(Canvas c, float HUDCanvasScale, float ConsoleMessagePosX, float ConsoleMessagePosY, Color ConsoleColor)
{
	local int i;
	local array<string> choices;

	if (VoteChoice != none)
	{
		choices = VoteChoice.GetDisplayStrings();
		choices.AddItem("ALT/CTRL: " $ BackString);
	}
	else
	{
		for (i = 0; i < VoteChoiceClasses.Length; i++)
			choices.AddItem(string(i + 1) $ ": " $ VoteChoiceClasses[i].default.MenuDisplayString);

		choices.AddItem("ALT/CTRL: " $ ExitString);
	}

	

	DisplayChoices(c, HUDCanvasScale, ConsoleMessagePosX, ConsoleMessagePosY, ConsoleColor, choices);
}

function KeyPress(byte T)
{
	if (VoteChoice == none)
	{
		// select vote submenu first
		
		if (T - 1 >= VoteChoiceClasses.Length) return; // wrong key

		VoteChoice = new (self) VoteChoiceClasses[T - 1];
		VoteChoice.Handler = self;
		VoteChoice.Init();
	}
	else VoteChoice.KeyPress(T); // forward to submenu
}

function DisplayChoices(Canvas c, 
	float HUDCanvasScale, 
	float ConsoleMessagePosX, 
	float ConsoleMessagePosY,
	Color ConsoleColor, 
	array<string> choices)
{
	local int Idx, XPos, YPos;
	local float XL, YL;

	XPos = (ConsoleMessagePosX * HudCanvasScale * c.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * c.SizeX);
    YPos = (ConsoleMessagePosY * HudCanvasScale * c.SizeY) + 20* (((1.0 - HudCanvasScale) / 2.0) * c.SizeY);
    
    c.Font = Font'RenXHud.Font.RadioCommand_Medium';
    c.DrawColor = ConsoleColor;

    c.TextSize("A", XL, YL);
    YPos -= YL * choices.Length;
    YPos -= YL;

    for (Idx = 0; Idx < choices.Length; Idx++)
    {
    	c.StrLen(choices[Idx], XL, YL);
		c.SetPos(XPos, YPos);
		c.DrawText(choices[Idx], false);
		YPos += YL;
    }
}

static function DisplayOngoingVote(Rx_Controller p, Canvas c, float HUDCanvasScale, Color ConsoleColor)
{
	local int XPos, YPos;
	local float XL, YL;
	local string t;

	if (p.VoteTopString == "") return;

	c.Font = Font'RenXHud.Font.RadioCommand_Medium';
    c.DrawColor = ConsoleColor;

	c.TextSize(p.VoteTopString, XL, YL);

	XPos = (c.SizeX / 2) - (XL / 2);
	YPos = 20;

	c.SetPos(XPos, YPos);
	c.DrawText(p.VoteTopString, false);
	YPos += YL;
	c.SetPos(XPos, YPos);
	t = "F1: Yes (" $ string(p.VotesYes) $ ") F2: No (" $ string(p.VotesNo) $ ") - " $ p.YesVotesNeeded $ " Yes votes needed, " $ string(p.VoteTimeLeft) $ " seconds left";
	c.DrawText(t, false);
}

DefaultProperties
{
	VoteChoiceClasses(0) = class'Rx_VoteMenuChoice_RestartMap'
	VoteChoiceClasses(1) = class'Rx_VoteMenuChoice_ChangeMap'
	VoteChoiceClasses(2) = class'Rx_VoteMenuChoice_Surrender'
	VoteChoiceClasses(3) = class'Rx_VoteMenuChoice_AddBots'
	VoteChoiceClasses(4) = class'Rx_VoteMenuChoice_RemoveBots'
	VoteChoiceClasses(5) = class'Rx_VoteMenuChoice_Kick'
	VoteChoiceClasses(6) = class'Rx_VoteMenuChoice_Survey'

	ExitString = "Exit"
	BackString = "Back"
}
