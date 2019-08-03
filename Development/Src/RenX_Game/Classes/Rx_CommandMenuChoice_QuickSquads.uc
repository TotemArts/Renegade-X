class Rx_CommandMenuChoice_QuickSquads extends Rx_CommandMenuChoice;

/*TODO: ALL OF THIS IS JUST REMOVEMINES*/

function Init(Rx_CommanderMenuHandler Initiator)
{
	ParseStructureNames(); //Get appropriate structure names for the team
	super.Init(Initiator); 
	
}

function bool DoStuff(optional byte AbilityNumber, optional bool bHeld)
{
	
	Control.RemoveMinesFromBuilding(AbilityNumber); 
	Control.DestroyOldComMenu(); 
	return true; 
}

function bool DoSecondaryStuff(optional byte AbilityNumber)
{
	CancelSelection(); 
	
	return true; 
}

function ParseStructureNames()
{
	local int TeamByte, i; 

	TeamByte = Control.GetTeamNum();
	
	for(i=0;i<SubChoices.Length;i++)
	{
		if(TeamByte == 0 ) 
		{ 
		SubChoices[i].Title = Repl(SubChoices[i].Title, "InfStruc", "Barracks");
		SubChoices[i].Title = Repl(SubChoices[i].Title, "VehStruc", "Weapons Factory"); 
		SubChoices[i].Title = Repl(SubChoices[i].Title, "DefStruc", "AGT"); 
		}
		else
		{
		SubChoices[i].Title = Repl(SubChoices[i].Title, "InfStruc", "Hand of Nod");
		SubChoices[i].Title = Repl(SubChoices[i].Title, "VehStruc", "AirStrip"); 
		SubChoices[i].Title = Repl(SubChoices[i].Title, "DefStruc", "Obelisk"); 
		}
	}
} 

DefaultProperties 
{
CommandTitle = "Remove Mines"

SubChoices(0) = (Title = "Remove Powerplant Mines", bChoiceSelected = false, bInstant = false)
SubChoices(1) = (Title = "Remove Refinery Mines", bChoiceSelected = false, bInstant = false) 
SubChoices(2) = (Title = "Remove InfStruc Mines", bChoiceSelected = false, bInstant = false) 
SubChoices(3) = (Title = "Remove VehStruc Mines", bChoiceSelected = false, bInstant = false) 
SubChoices(4) = (Title = "Remove DefStruc Mines", bChoiceSelected = false, bInstant = false) 

Steps = 1 //Number of Steps to this ability
CurrentStep = 1 //Current step in the process of activating this option.  
bImmediateActivation = false //When selected does this choice immediately respond
bExitOnActivation = false 
bQCast = true // Is this ability casts with Q-spot 
bSelected = false //When true, draw in green and also maybe do other things.
ETextStr = "Cancel"
QTextStr = "Confirm Mine Removal"
}