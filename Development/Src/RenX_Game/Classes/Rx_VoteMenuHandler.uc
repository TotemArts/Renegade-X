class Rx_VoteMenuHandler extends Object;

/** Define all vote submenus. Code is limited to work with 1-9 choices. */
var array<class<Rx_VoteMenuChoice> > VoteChoiceClasses;

/** Current vote submenu. */
var Rx_VoteMenuChoice VoteChoice;

/** Exit (or go back) string displayed in menu. */
var string ExitString;
var string BackString;

var Rx_Controller PlayerOwner;

var SoundCue Snd_ChangeMenu, Snd_Open;

var byte	 NumPages; 

// called when vote menu is shown
function Enabled(Rx_Controller p)
{
	PlayerOwner = p;
	PlayerOwner.ClientPlaySound(Snd_Open);
}


// called when alt/E is pressed
function bool Disabled()
{
	if (VoteChoice != none)
	{
		if (VoteChoice.GoBack())
		{
			VoteChoice = none;
			PlayerOwner.ClientPlaySound(Snd_ChangeMenu);
		}

		return false; // do not kill vote menu yet
	}
	else 
	{
		PlayerOwner.ClientPlaySound(Snd_Open);
		return true; // return true to kill vote menu
	}
}

// called from submenu to close handler
function Terminate()
{
	Rx_HUD(PlayerOwner.myHud).HUDMovie.DeathLogMC.SetVisible(true);
	VoteChoice = none;
	PlayerOwner.DisableVoteMenu();
}

function Display(Rx_HUD H)
{
	local int i;
	local array<string> choices;
	local byte TempNumPages; 
	local string SelectionNum;
	
	if (VoteChoice != none)
	{
		choices = VoteChoice.GetDisplayStrings();
		//choices.AddItem("ALT/CTRL: " $ BackString);
		TempNumPages = Fceil(choices.Length*1.0*0.1) ;
	}
	else
	{
		TempNumPages = 0;
		
		for (i = 0; i < VoteChoiceClasses.Length; i++)
		{
			SelectionNum = string(i+1); 
			
			if(VoteChoiceClasses[i].static.bIsAvailable(PlayerOwner))
			{
				choices.AddItem(SelectionNum $ "|" $ VoteChoiceClasses[i].default.MenuDisplayString);
			}
			else
				choices.AddItem("-X-" $ SelectionNum $ "|" $ VoteChoiceClasses[i].default.MenuDisplayString); //Grey it out
		}
		//choices.AddItem("ALT/CTRL: " $ ExitString);
	}

	if(NumPages != TempNumPages) NumPages = TempNumPages; 

	if(choices.length < 1)
		return;
	//DisplayChoices(H, choices, NumPages);
	Rx_HUD(PlayerOwner.myHUD).CreateVoteMenuArray(choices);
	return;
}

function KeyPress(byte T)
{
	if (VoteChoice == none)
	{
		// select vote submenu first
		
		if (T - 1 >= VoteChoiceClasses.Length || VoteChoiceClasses[T-1].static.bIsAvailable(PlayerOwner) == false) return; // wrong key
		
		if(T-1 >= 0 && T-1 < 3) 
		{
			if(!PlayerOwner.CanVoteMapChange() )  
			{
				PlayerOwner.CTextMessage("You have entered a ChangeMap/Surrender Vote too recently",'Orange',80);
				return;
			}
		} else if (T-1 >= 0 && T-1 == 3)
		{
			if(!PlayerOwner.CanVoteBots())
			{
				PlayerOwner.CTextMessage("Bot votes are currently disabled",'Orange',80);
				return;
			}
		}
		PlayerOwner.ClientPlaySound(Snd_ChangeMenu);
		VoteChoice = new (self) VoteChoiceClasses[T - 1];
		VoteChoice.Handler = self;
		VoteChoice.Init();
	}
	else 
	{
		PlayerOwner.ClientPlaySound(Snd_ChangeMenu);
		VoteChoice.KeyPress(T); // forward to submenu
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
	VoteChoiceClasses(7) = class'Rx_VoteMenuChoice_MineBan'
	VoteChoiceClasses(8) = class'Rx_VoteMenuChoice_Commander'
	
	ExitString = "Exit"
	BackString = "Back"
	
	Snd_ChangeMenu = SoundCue'rx_interfacesound.Wave.SC_Click4' // SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest2_Cue'
	Snd_Open = SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest4_Cue' //Open/Close are identical
}
