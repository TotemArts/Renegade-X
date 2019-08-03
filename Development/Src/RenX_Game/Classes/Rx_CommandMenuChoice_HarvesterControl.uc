class Rx_CommandMenuChoice_HarvesterControl extends Rx_CommandMenuChoice;

var bool bHarvesterExists;
var Rx_Vehicle_Harvester MyHarv; 
var string BlankString;

function Init(Rx_CommanderMenuHandler Initiator)
{
	super.Init(Initiator);
}

function bool DoStuff(optional byte AbilityNumber, optional bool bHeld)
{
	Control.CommandHarvester(AbilityNumber); 
	Control.DestroyOldComMenu(); 
	Rx_HUD(Control.myHUD).HUDMovie.DeathLogMC.SetVisible(true);
	return true; 
}

function bool DoSecondaryStuff(optional byte AbilityNumber)
{
	CancelSelection(); 
	
	return true; 
}

function bool GetHarvExists(out Rx_Vehicle_Harvester Harvy)
{
	local Rx_Vehicle_Harvester HarvIterator;  
	local byte TeamByte;
	local Choices ChoiceIterator; 
	
	TeamByte = Control.GetTeamNum();
	
	
			foreach Control.WorldInfo.AllActors(class'Rx_Vehicle_Harvester', HarvIterator)
			{
				if(HarvIterator.GetTeamNum() != TeamByte) 
					continue; 
				
				Harvy = HarvIterator;
				return true; 
			}
	
	foreach SubChoices(ChoiceIterator)
	{
		ChoiceIterator.Title = BlankString; 
	}
} 


function ParseInput(byte Input) //Used if this ability is selected 
{
	local int i ;
	
	if(Input > SubChoices.Length || Input == 0 || SubChoices[Input-1].Title == BlankString) return ; 
	
	for(i=0;i<SubChoices.Length;i++)
	{
		SubChoices[i].bChoiceSelected=false; 
	}
	
	SubChoices[Input-1].bChoiceSelected = true; 

	if(SubChoices[Input-1].bInstant) ActivateAbility(Input-1);
	else
	{
		if(bQCast) bDisplayQEPrompts = true; 
		Control.ClientPlaySound(Snd_Fail);	
	}
	
	
}

function string GetHelpText()
{
	if(GetHarvExists(MyHarv))
	{
		return "Status:" @ MyHarv.GetFriendlyStateName() $ "%";  
	}
	else
	return "Status: DEAD%"; 
	
}

DefaultProperties 
{
CommandTitle = "Harvester Options"

SubChoices(0) = (Title = "Stop/Start", bChoiceSelected = false, bInstant = false)
SubChoices(1) = (Title = "Set Harvester Waypoint", bChoiceSelected = false, bInstant = false) 
SubChoices(2) = (Title = "Remove Harvester Waypoint", bChoiceSelected = false, bInstant = false) 
SubChoices(3) = (Title = "Toggle To Self-Destruct", bChoiceSelected = false, bInstant = false) 

Steps = 1 //Number of Steps to this ability [Possibly Deprecated before it was ever used]
CurrentStep = 1 //Current step in the process of activating this option.  
bImmediateActivation = false //When selected does this choice immediately respond
bExitOnActivation = false 
bQCast = true // Is this ability casts with Q-spot 
bSelected = false //When true, draw in green and also maybe do other things.
ETextStr = "Cancel"
QTextStr = "Confirm Command"

BlankString = "-----------"
}