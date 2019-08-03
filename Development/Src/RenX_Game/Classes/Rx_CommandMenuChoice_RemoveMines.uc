class Rx_CommandMenuChoice_RemoveMines extends Rx_CommandMenuChoice;

var bool TeamInfStrucExists, TeamVehStrucExists, TeamPPStrucExists, TeamRefStrucExists, TeamDefStrucExists;
var string BlankString; 

function Init(Rx_CommanderMenuHandler Initiator)
{
	BlankNonexistentStructures() ; /* If the structures don't exist, write them as blank [Keep numbers consistent though]*/
	ParseStructureNames(); /*Get appropriate structure names for the team*/
	super.Init(Initiator); 
	
}

function bool DoStuff(optional byte AbilityNumber, optional bool bHeld)
{
	
	Control.RemoveMinesFromBuilding(AbilityNumber); 
	Control.DestroyOldComMenu(); 
	Rx_HUD(Control.myHUD).HUDMovie.DeathLogMC.SetVisible(true);
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

function BlankNonexistentStructures()
{
	local Rx_Building BLDG;  
	local byte TeamByte;
	
	TeamByte = Control.GetTeamNum();
	
	foreach Control.WorldInfo.AllActors(class'Rx_Building', BLDG)
	{
		if(TeamByte == 0)
		{
			if(Rx_Building_GDI_PowerFactory(BLDG) != none) TeamPPStrucExists = true;
			else
			if(Rx_Building_GDI_MoneyFactory(BLDG) != none) TeamRefStrucExists = true;
			else
			if(Rx_Building_GDI_InfantryFactory(BLDG) != none) TeamInfStrucExists = true;
			else
			if(Rx_Building_GDI_VehicleFactory(BLDG) != none) TeamVehStrucExists = true;
			else
			if(Rx_Building_GDI_Defense(BLDG) != none) TeamDefStrucExists = true; 
		}
		else 
		if(TeamByte == 1)
		{
			if(Rx_Building_Nod_PowerFactory(BLDG) != none) TeamPPStrucExists = true;
			else
			if(Rx_Building_Nod_MoneyFactory(BLDG) != none) TeamRefStrucExists = true;
			else
			if(Rx_Building_Nod_InfantryFactory(BLDG) != none) TeamInfStrucExists = true;
			else
			if(Rx_Building_Nod_VehicleFactory(BLDG) != none) TeamVehStrucExists = true;
			else
			if(Rx_Building_Nod_Defense(BLDG) != none) TeamDefStrucExists = true; 		
		}	
	}
	
	if(!TeamPPStrucExists) SubChoices[0].Title = BlankString		;
	if(!TeamRefStrucExists) SubChoices[1].Title = BlankString		;
	if(!TeamInfStrucExists) SubChoices[2].Title = BlankString;
	if(!TeamVehStrucExists) SubChoices[3].Title = BlankString;
	if(!TeamDefStrucExists) SubChoices[4].Title = BlankString;
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
		if(bQCast) 
			bDisplayQEPrompts = true; 
		
		Control.ClientPlaySound(Snd_Fail);	
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
SubChoices(5) = (Title = "Remove ALL OTHER Mines", bChoiceSelected = false, bInstant = false)

Steps = 1 //Number of Steps to this ability [Possibly Deprecated before it was ever used]
CurrentStep = 1 //Current step in the process of activating this option.  
bImmediateActivation = false //When selected does this choice immediately respond
bExitOnActivation = false 
bQCast = true // Is this ability casts with Q-spot 
bSelected = false //When true, draw in green and also maybe do other things.
ETextStr = "Cancel"
QTextStr = "Confirm Mine Removal"

BlankString = "-----------"
}