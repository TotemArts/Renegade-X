class Rx_CommandMenuChoice extends Object ; 

/*Variables*/

var string CommandTitle; 
var localized string MainHelpText ;
var localized array<string> SubHelpText;

var array<string> StepTitle; 

var byte Steps; // Number of Steps to this ability
var byte CurrentStep; // Current step in the process of activating this option.  
var bool bImmediateActivation; // When selected does this choice immediately respond
var bool bExitOnActivation; 
var bool bQCast; // Is this ability casts with Q-spot 
var bool bSelected; // When true, draw in green and also maybe do other things.
var bool bDisplayQEPrompts; // Whether we should draw Q: and E: prompts on the crosshair
var SoundCue Snd_Cast, Snd_Cast2, Snd_Fail, Snd_Select; 

var string ETextStr, QTextStr, QTextHoldStr; 

var Rx_CommanderMenuHandler PrimaryMenu; //Parent Command Menu 
var Rx_Controller Control; 

struct Choices 
{
	var string 	Title; 
	var bool	bChoiceSelected;
	var bool	bInstant; //Activates this ability immediately upon selection
	var class<Rx_CommanderSupport_BeaconInfo> BeaconInfo; //Used exclusively by support powers
	var int		CPCost;  
};

var array<Choices> SubChoices; 

function Init(Rx_CommanderMenuHandler Initiator)
{
	PrimaryMenu = Initiator; 
	
	if(bImmediateActivation && SubChoices.Length == 0)
		ActivateAbility(); 
	else
		SelectAbility(); 
}

function ActivateAbility(optional byte AbilityNumber = 0, optional bool ButtonHeld = false) 
{
	if(!DoStuff(AbilityNumber, ButtonHeld)) 
	{
		Control.ClientPlaySound(Snd_Fail); 
		return; 
	}; 
	//---
	if(!bQCast)
		Control.ClientPlaySound(Snd_Cast);
	else
		Control.ClientPlaySound(Snd_Cast);
	if(bExitOnActivation && SubChoices.Length == 0)
		Control.DestroyOldComMenu(); 

} 

function ActivateSecondaryAbility(optional byte AbilityNumber = 0)
{
	if(!DoSecondaryStuff(AbilityNumber)) 
	{
		Control.ClientPlaySound(Snd_Fail); 
		return; 
	}
	else
		Control.ClientPlaySound(Snd_Cast2); 
	
	if(bExitOnActivation && SubChoices.Length == 0)
		Control.DestroyOldComMenu();	
}

function CancelSelection()
{
	local int i ; 
	
	for(i=0;i<SubChoices.Length;i++)
	{
		if(SubChoices[i].bChoiceSelected) 
		{
			SubChoices[i].bChoiceSelected=false; 
			bDisplayQEPrompts = false;
			Control.ClientPlaySound(Snd_Cast2);
			return; 
		}
	}
	
	bSelected = false; 
	Control.ClientPlaySound(Snd_Cast2);
	PrimaryMenu.MenuTab = None;   
}

function SelectAbility()
{
	
	
	if(!bSelected) 
	{
		bSelected = true;
	}
	else
		bSelected = false;  
}

function ParseInput(byte Input) //Used if this ability is selected 
{
	local int i ;
	if(Input > SubChoices.Length || Input == 0) return; 
	
	for(i=0;i<SubChoices.Length;i++)
	{
		SubChoices[i].bChoiceSelected=false; 
	}
	
	if(!bHaveEnoughCP(SubChoices[Input-1].CPCost))
	{
		Control.ClientPlaySound(Snd_Fail);
		return;
	}
	
	SubChoices[Input-1].bChoiceSelected = true; 

	if(SubChoices[Input-1].bInstant)
		ActivateAbility(Input-1);

	else if(bQCast) {
		bDisplayQEPrompts = true; 
		Control.ClientPlaySound(Snd_Select);
	}
}

function QCast(bool bHeld)
{
	local int i; 
	
	if(bSelected && SubChoices.Length < 1) ActivateAbility(0, bHeld);
		else if(bSelected && SubChoices.Length > 0) 
			{
				for(i=0;i<SubChoices.Length;i++)
				{
					if(SubChoices[i].bChoiceSelected == true) 
					{
						ActivateAbility(i, bHeld);
						return; 
					}
				}
			}
}

function PerformEFunction()
{
	local int i; 
	//`log(bSelected @ SubChoices.Length);
	if(bSelected && SubChoices.Length < 1) ActivateAbility(0);
	else
	if(bSelected && SubChoices.Length > 0) 
		{
			for(i=0;i<SubChoices.Length;i++)
			{
				if(SubChoices[i].bChoiceSelected == true) 
				{
					ActivateSecondaryAbility(i);
					return; 
				}
			}
			CancelSelection(); //If you found nothing, assume it was a call to go back
		}
	
}

function bool DoStuff(optional byte AbilityNumber = 0, optional bool bHeld) //Do whatever the hell you do
{}

function bool DoSecondaryStuff(optional byte AbilityNumber = 0) //Do whatever the hell your other button can do (Generally reserved for Pressing 'E' )
{}

function string GetTitle()
{
	return default.CommandTitle; 
}

function array<string> GetDisplayStrings()
{
local array<string> TempStrings; 
local int i ; 

	for(i=0;i<SubChoices.Length;i++)
	{
		if(!bHaveEnoughCP(SubChoices[i].CPCost)) // Too expensive
			TempStrings.AddItem("-X-"$ i+1 $ "|" $ SubChoices[i].Title);
		else if(SubChoices[i].bChoiceSelected)   // Selected
			TempStrings.AddItem("-S-" $ i+1 $ "|" $ SubChoices[i].Title $ "<<");
		else 									 // Neither
			TempStrings.AddItem(i+1 $ "|" $ SubChoices[i].Title); 
		
	}	
	return TempStrings; 
}

function bool bHaveEnoughCP(int CheckNum)
{
	local int CommandPoints; 
	
	CommandPoints = Rx_TeamInfo(Control.PlayerReplicationInfo.Team).GetCommandPoints();
	
	return CommandPoints >= CheckNum;
}

function string GetHelpText()
{
	local int i;
	
	for(i=0;i<SubChoices.Length;i++)
		{
			if(i >= SubHelpText.Length) continue; 
			else if(SubChoices[i].bChoiceSelected) 
				{
					return SubHelpText[i]; 
				}
		}
		
		return MainHelpText;
}


function bool bSubChoiceSelected()
{
	local int i; 
	
	for(i=0;i<SubChoices.Length;i++)
	{
		if(SubChoices[i].bChoiceSelected) return true;
	}
	
	return false; 
}

DefaultProperties
{
	CommandTitle = "Default Title"
	
	StepTitle(0) = "Default Title"
	
	Steps = 1 //Number of Steps to this ability
	CurrentStep = 1 //Current step in the process of activating this option.  
	bImmediateActivation = false //When selected does this choice immediately respond
	bExitOnActivation = true 
	bQCast = false // Is this ability casts with Q-spot 
	bSelected = false //When true, draw in green and also maybe do other things.
	
	ETextStr = "Remove Waypoint"
	QTextStr = "Set Waypoint"
	QTextHoldStr = ""
	
	bDisplayQEPrompts = false 
	
	Snd_Cast = SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest1_Cue' 
	Snd_Cast2 = SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest4_Cue' //Secondary cast sound (Pressing E)
	Snd_Fail = SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest2_Cue'
	Snd_Select = SoundCue'rx_interfacesound.Wave.SC_Click4'
}