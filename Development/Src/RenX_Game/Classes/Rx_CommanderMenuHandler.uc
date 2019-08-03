class Rx_CommanderMenuHandler extends Object;

/** Define all vote submenus. Code is limited to work with 1-9 choices. */
var array<class<Rx_CommandMenuChoice> > CommandChoiceClasses;

var Rx_CommandMenuChoice MenuTab; 

/** Exit (or go back) string displayed in menu. */
var string ExitString;
var string BackString;

var Rx_Controller PlayerOwner;

var SoundCue Snd_ChangeMenu, Snd_Open;

// called when vote menu is shown
function Enabled(Rx_Controller p)
{
	PlayerOwner = p;
	PlayerOwner.ClientPlaySound(Snd_Open);
}

function CancelSelection()
{
	if(MenuTab != none) 
	{
		MenuTab.CancelSelection() ; 	
		PlayerOwner.ClientPlaySound(Snd_Open);
	}
	else
		Terminate();
	
}

// called from submenu to close handler
function Terminate()
{
	Rx_HUD(PlayerOwner.myHud).HUDMovie.DeathLogMC.SetVisible(true);
	PlayerOwner.DestroyOldComMenu();
	PlayerOwner.ClientPlaySound(Snd_Open);
}

function Display(Rx_HUD H)
{
	local int i, compoints, maxcompoints;
	local array<string> choices;
	local Rx_TeamInfo TeamInfo;

	if (MenuTab != none)
	{
		choices = MenuTab.GetDisplayStrings();
		
		if(MenuTab.bDisplayQEPrompts) DisplayCrosshairPrompt(H.Canvas, H.HUDCanvasScale); 
		
	}
	else
	{
		for (i = 0; i < CommandChoiceClasses.Length; i++)
			choices.AddItem((i+1)$"|"$CommandChoiceClasses[i].default.CommandTitle);
	}
		
	TeamInfo = Rx_TeamInfo(PlayerOwner.WorldInfo.GRI.Teams[PlayerOwner.GetTeamNum()]);

	ComPoints = TeamInfo.GetCommandPoints();
	MaxComPoints = TeamInfo.GetMaxCommandPoints();

	Rx_HUD(PlayerOwner.myHUD).CreateCommanderMenuArray(choices, ComPoints, MaxComPoints);

	if(MenuTab != None)
		if(MenuTab.GetHelpText() != "")
			Rx_HUD(PlayerOwner.MyHUD).CreateHelpMenuArray(MenuTab.GetHelpText());
}

function KeyPress(byte T)
{
	if (MenuTab == none)
	{
		// Move to selected submenu
		
		if (T - 1 >= CommandChoiceClasses.Length) return; // wrong key
		
		MenuTab = new (self) CommandChoiceClasses[T - 1];
		MenuTab.Control = PlayerOwner;
		MenuTab.Init(self);
		PlayerOwner.ClientPlaySound(Snd_ChangeMenu);
	}
	else 
	{
		MenuTab.ParseInput(T); // forward to submenu
		//PlayerOwner.ClientPlaySound(Snd_ChangeMenu);
	}
}

function DisplayCrosshairPrompt(Canvas c, float CanvasScale)
{
	local float XPos, YPos;
	local float XL, YL; 
	local string TempStr; 
	
	
	XPos = (c.SizeX*0.5) - (64*CanvasScale);
	YPos = c.SizeY*0.45;
	
	
	 c.Font = Font'RenXHud.Font.RadioCommand_Medium';
	 c.SetDrawColor(0,255,200,200); 
	
	TempStr = "Q:" @ MenuTab.QTextStr; //Q Text 1st
	c.StrLen(TempStr, XL, YL); 
	c.SetPos(XPos-(XL*CanvasScale),YPos); 
	
	if(MenuTab.QTextStr != "") c.DrawText(TempStr);
	 
	XPos = (c.SizeX*0.5) + (64*CanvasScale) ;
	 
	c.SetPos(XPos,YPos); 
	c.DrawText("E:" @ MenuTab.ETextStr);
	
	if(MenuTab.QTextHoldStr != "" && MenuTab.QTextStr != "") 
	{
		//Draw Q-Hold Text
		XPos = (c.SizeX*0.5) - (64*CanvasScale);
		YPos = c.SizeY*0.45+(YL*2.25);
		c.SetPos(XPos-(XL*CanvasScale),YPos); //Draw Beneath Q
		c.DrawText("Q[Hold]:" @ MenuTab.QTextHoldStr);
	}
	else
	if(MenuTab.QTextHoldStr != "" && MenuTab.QTextStr == "")
	{
		//Draw Q-Hold Text with NO regular Q text
		TempStr = "Q[Hold]:" @ MenuTab.QTextHoldStr; //Q Text 1st
		c.StrLen(TempStr, XL, YL); 
		XPos = (c.SizeX*0.5) - (64*CanvasScale);
		YPos = c.SizeY*0.45;
		c.SetPos(XPos-(XL*CanvasScale),YPos); //Draw Beneath Q
		c.DrawText("Q[Hold]:" @ MenuTab.QTextHoldStr);	
	}
	
}

DefaultProperties
{
	CommandChoiceClasses(0) = class'Rx_CommandMenuChoice_SetWaypoint'
	CommandChoiceClasses(1) = class'Rx_CommandMenuChoice_RemoveMines'
	CommandChoiceClasses(2) = class'Rx_CommandMenuChoice_SupportPowers'
	CommandChoiceClasses(3) = class'Rx_CommandMenuChoice_HarvesterControl'
	CommandChoiceClasses(4) = class'Rx_CommandMenuChoice_Help'
	
	ExitString = "Exit"
	BackString = "Back"
	//SoundCue'rx_interfacesound.Wave.SC_Click6'
	//SoundCue'rx_interfacesound.Wave.SC_Click4'
	Snd_ChangeMenu =   SoundCue'rx_interfacesound.Wave.SC_Click4' //SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest2_Cue'
	Snd_Open = SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest4_Cue' //Open/Close are identical
}
