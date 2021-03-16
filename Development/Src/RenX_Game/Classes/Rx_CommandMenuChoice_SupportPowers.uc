class Rx_CommandMenuChoice_SupportPowers extends Rx_CommandMenuChoice;

/**Probably the most switchy statement-y selection as support powers are fairly different from one another.. EDIT: Or just get smart and throw in support power info on the buttons themselves**/

var array<choices>				GDI_SP, Nod_SP; 
var localized array<string>		SubHelpText_GDI, SubHelpText_Nod; 

function Init(Rx_CommanderMenuHandler Initiator)
{
	super.Init(Initiator); 
	Control.CommanderTargetingReticule = Control.spawn(class'Rx_CommanderSupport_TargetingParticleSystem',,,,,, true);
	Control.CommanderTargetingReticule.ActivatePS();
	Control.CommanderTargetingReticule.InitLink(Control);
	
	if(Control.GetTeamNum() == 0)
	{
		SetPowers(0); 
	}
	else
		SetPowers(1); 
}

function bool DoStuff(optional byte AbilityNumber, optional bool bHeld)
{
	if(bHeld && Control.TrySupportPowerCast(SubChoices[AbilityNumber].BeaconInfo)) 
	{
		Control.DestroyOldComMenu();
		Control.CommanderTargetingReticule.Destroy();
		Control.CommanderTargetingReticule = none;
		Rx_HUD(Control.myHUD).HUDMovie.DeathLogMC.SetVisible(true);
		return true; 	
	}
	else
	return false; 
}

function bool DoSecondaryStuff(optional byte AbilityNumber)
{
	CancelSelection(); 
	
	return true; 
}

function CancelSelection()
{
	if(Control.CommanderTargetingReticule != none && !bSubChoiceSelected())
	{
		Control.CommanderTargetingReticule.Destroy();
		Control.CommanderTargetingReticule = none; 	
	}
	else
	if(bSubChoiceSelected() ) Control.CommanderTargetingReticule.ClearInfo();
	super.CancelSelection();
}

function ParseInput(byte Input) //Used if this ability is selected 
{
	local int i ;
	
	if(Input > SubChoices.Length || Input == 0) return ; 
	
	for(i=0;i<SubChoices.Length;i++)
	{
		SubChoices[i].bChoiceSelected=false; 
	}
	
	if(!bHaveEnoughCP(SubChoices[Input-1].CPCost))
	{
		Control.CTextMessage("You do not have enough CP");
		Control.ClientPlaySound(Snd_Fail);
		return;
	}
	
	if(!SubChoices[Input-1].BeaconInfo.static.bCanFire(Control))
	{
		//bCanFire throws its own CText messages
		Control.ClientPlaySound(Snd_Fail);
		return;
	}
	
	SubChoices[Input-1].bChoiceSelected = true; 

	if(SubChoices[Input-1].bInstant) 
		ActivateAbility(Input-1);
	else
	{
		if(bQCast) 
			bDisplayQEPrompts = true; 
		
		if(Control.CommanderTargetingReticule != none) 
			Control.CommanderTargetingReticule.SetBeaconInfo(SubChoices[Input-1].BeaconInfo);
	
		Control.ClientPlaySound(Snd_Fail);	
	}
	
	
}

function SetPowers(byte TeamByte)
{
	local int i; 
	
	if(TeamByte == 0) 
	{
		for(i=0;i<GDI_SP.Length;i++)
			SubChoices[i] = GDI_SP[i];
	}
	else
	if(TeamByte == 1) 
	{
		for(i=0;i<Nod_SP.Length;i++)
			SubChoices[i] = Nod_SP[i];
	}
}

function string GetHelpText() //Override, as support powers are team specific
{
	local int i;
	
	/**if(MainHelpText != "" && bSelected) return MainHelpText; 
	else*/
	if(Control.GetTeamNum() == 0 )
	{
		for(i=0;i<SubChoices.Length;i++)
			{
				if(i >= SubHelpText_GDI.Length) continue; 
				else
				if(SubChoices[i].bChoiceSelected) 
				{
					return SubHelpText_GDI[i]; 
				}
			}	
	}
	else if(Control.GetTeamNum() == 1 )
	{
		for(i=0;i<SubChoices.Length;i++)
			{
				if(i >= SubHelpText_Nod.Length) continue; 
				else
				if(SubChoices[i].bChoiceSelected) 
				{
					return SubHelpText_Nod[i]; 
				}
			}	
	}
	
		
		return MainHelpText;
	
}

function array<string> GetDisplayStrings() //Inject to add in cost
{
local array<string> TempStrings; 
local int i ; 

	for(i=0;i<SubChoices.Length;i++)
	{
		if(!bHaveEnoughCP(SubChoices[i].CPCost) || !SubChoices[i].BeaconInfo.static.bCanFire(Control, false)) TempStrings.AddItem("-X-" $ i+1 $ "|" $ SubChoices[i].Title @ "[" $ SubChoices[i].CPCost $ "CP]"); // Too expensive
		else
		if(SubChoices[i].bChoiceSelected) TempStrings.AddItem("-S-" $ i+1 $ "|" $ SubChoices[i].Title @ "[" $ SubChoices[i].CPCost $ "CP]" $ "<<"); // Selected
		else
		TempStrings.AddItem(i+1 $ "|" $ SubChoices[i].Title @ "[" $ SubChoices[i].CPCost $ "CP]"); // Have enough, but not selected 
		
	}	

	return TempStrings; 
	
}

DefaultProperties 
{
	CommandTitle = "Support Powers"

	//Global Support powers 
	//SubChoices(0) = (Title = "Radar Scan", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_RadarScan', CPCost = 300)
	//SubChoices(1) = (Title = "Smoke Screen", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_SmokeDrop', CPCost = 400) 
	//SubChoices(2) = (Title = "EMP Strike", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_EMPMissile', CPCost = 500) 
	//SubChoices(3) = (Title = "Cruise Missile", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_CruiseMissile', CPCost = 800) 
	//SubChoices(4) = (Title = "Finest Hour", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_HumveeDrop') 

	//TeamSpecific support powers
	GDI_SP(0) = (Title = "Radar Scan", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_RadarScan', CPCost = 150)
	GDI_SP(1) = (Title = "Smoke Screen", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_SmokeDrop', CPCost = 200) 
	GDI_SP(2) = (Title = "EMP Strike", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_EMPMissile', CPCost = 500)
	GDI_SP(3) = (Title = "Cruise Missile", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_CruiseMissile', CPCost = 800)
	GDI_SP(4) = (Title = "Defensive Initiative", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_Buff_GDI_DI', CPCost = 1200)
	GDI_SP(5) = (Title = "Offensive Initiative", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_Buff_GDI_OI', CPCost = 1400)

	Nod_SP(0) = (Title = "Spy Plane", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_Spyplane', CPCost = 150)
	Nod_SP(1) = (Title = "Smoke Screen", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_SmokeDrop', CPCost = 200) 
	Nod_SP(2) = (Title = "EMP Strike", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_EMPMissile', CPCost = 500)
	Nod_SP(3) = (Title = "Cruise Missile", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_CruiseMissile', CPCost = 800)
	Nod_SP(4) = (Title = "Unity Through Peace", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_Buff_Nod_UTP', CPCost = 1200)
	Nod_SP(5) = (Title = "Peace Through Power", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_Buff_Nod_PTP', CPCost = 1400)

	Steps = 1 //Number of Steps to this ability
	CurrentStep = 1 //Current step in the process of activating this option.  
	bImmediateActivation = false //When selected does this choice immediately respond
	bExitOnActivation = false 
	bQCast = true // Is this ability casts with Q-spot 
	bSelected = false //When true, draw in green and also maybe do other things.
	ETextStr = "Cancel"
	QTextStr = ""
	QTextHoldStr = "Cast Ability"
}