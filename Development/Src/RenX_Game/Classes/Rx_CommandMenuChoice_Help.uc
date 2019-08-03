class Rx_CommandMenuChoice_Help extends Rx_CommandMenuChoice;


function bool DoStuff(optional byte AbilityNumber, optional bool bHeld)
{
	return true; 
	
}

function bool DoSecondaryStuff(optional byte AbilityNumber)

{
	return true; 
}

DefaultProperties 
{
CommandTitle = "Commander Help"

SubChoices(0) = (Title = "Commander: Chat", bChoiceSelected = false, bInstant = false)
SubChoices(1) = (Title = "Commander: Targeting", bChoiceSelected = false, bInstant = false)  
SubChoices(2) = (Title = "Waypoint Help", bChoiceSelected = false, bInstant = false)
SubChoices(3) = (Title = "Remove Mines Help", bChoiceSelected = false, bInstant = false) 
SubChoices(4) = (Title = "Harvester Control Help", bChoiceSelected = false, bInstant = false) 
SubChoices(5) = (Title = "Support Powers Help", bChoiceSelected = false, bInstant = false) 


bImmediateActivation = false //When selected does this choice immediately respond
bExitOnActivation = false 
bQCast = false // Is this ability casts with Q-spot 
bSelected = false //When true, draw in green and also maybe do other things.


ETextStr = ""
QTextStr = ""
QTextHoldStr = ""
}