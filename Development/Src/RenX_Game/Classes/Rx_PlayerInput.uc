/*********************************************************
*
* File: Rx_PlayerInput.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
*
*********************************************************
*  
*********************************************************/
class Rx_PlayerInput extends UTPlayerInput config(Input);

//Our Rx_Pawn
var Rx_Pawn rxp;
var float aBaseYTemp;
var() config bool UseADSSens;
var() config bool UseDevFlag;
var() config bool bThreadedVehReverseSteeringInverted;
var() config bool bClickToGoOutOfADS;
var() config bool bToggleCrouch;
var() config bool bToggleSprint;
var() config bool bActivateAuthentication;
var() config bool bNoGarbageCollectionOnOpeningPT;
var() config bool bDrawTargettingBox;

var bool bRadio0Pressed;
var bool bRadio1Pressed;

/** one1: added */
var bool AirstrikeLock;

var array<string> BannedCommands;

/** one1: added for airstrike support.
 *  capture mouse X and Y movements so we can adjust decal
 *  and airstrike orientation */
function PostProcessInput(float DeltaTime)
{
	local Rx_Controller pc;

	super.PostProcessInput(DeltaTime);

	pc = Rx_Controller(Player.Actor);
	if (AirstrikeLock)
	{
		if (aMouseX != 0.f || aMouseY != 0.f)
		{
			//`log("aMouseX=" $ aMouseX $ " aMouseY=" $ aMouseY);
			pc.AdjustAirstrikeRotation(aMouseX, aMouseY);
		}
	}
}

/**
 * Overloaded event PlayerInput.PlayerInput() to set Rx_Pawn movement direction variables before calling parent class's event.
 * 
 *  @param	DeltaTime   (description)
 *  @since              2011-10-13
 *  @author             triggerhippy
 */
event PlayerInput( float DeltaTime )
{

	rxp = Rx_Pawn(Pawn);
	
	if (rxp != none) 
	{ 
		if (bWasLeft)
			rxp.setMoveDirection(MD_Left);
		else if (bWasRight)
			rxp.setMoveDirection(MD_Right);			
		else if (bWasBack)
			rxp.setMoveDirection(MD_Backward);
		else if(bWasForward)
			rxp.setMoveDirection(MD_Forward);

		if(self.aBaseX == 0 && self.aBaseY == 0)
			rxp.setMoveDirection(MD_Stationary);
	}
	aBaseYTemp = aBaseY;
	
	super.PlayerInput(DeltaTime);
}

function AdjustMouseSensitivity(float FOVScale)
{
	super.AdjustMouseSensitivity(FOVScale);
	if(Rx_Pawn(Player.Actor.pawn) != None 
		&& Rx_Weapon(Player.Actor.pawn.weapon) != None 
		&& Rx_Weapon(Player.Actor.pawn.weapon).IsIronsightActivated()
		&& UseADSSens)
	{
		aMouseX *= Rx_Weapon(Player.Actor.pawn.weapon).GetIronsightMouseSensitivityModifier();
		aMouseY *= Rx_Weapon(Player.Actor.pawn.weapon).GetIronsightMouseSensitivityModifier();
	}

	assureMinimalMouseMovement();
}

// The engine doesent seem to translate movement thats between -1.0 and 1.0, so set any movement not in those range to 1.0/-1.0
function assureMinimalMouseMovement()
{
	if(aMouseX < 1.0 && aMouseX > 0.0)
	{
		aMouseX = 1.0;	
	}
	
	if(aMouseX > -1.0 && aMouseX < 0.0)
	{
		aMouseX = -1.0;	
	}

	if(aMouseY < 1.0 && aMouseY > 0.0)
	{
		aMouseY = 1.0;	
	}
	
	if(aMouseY > -1.0 && aMouseY < 0.0)
	{
		aMouseY = -1.0;	
	}	
}

function ToggleADSSens()
{
	UseADSSens = !UseADSSens;
	SaveConfig();
}

function ToggleDevFlag()
{
	UseDevFlag = !UseDevFlag;
	SaveConfig();
}

function TriggerRadioCommand(int KeyIndex) {
	local array<int> RadioCommandIndexes;
	local Rx_Hud RxHud;

	// Get appropriate key page from Rx_HUD
	RxHud = Rx_HUD(Player.Actor.myHUD);
	if (bRadio0Pressed && bRadio1Pressed) {
		// Ctrl + Alt
		RadioCommandIndexes = RxHud.RadioCommandsCtrlAlt;
	}
	else if (bRadio1Pressed) {
		// Alt
		RadioCommandIndexes = RxHud.RadioCommandsAlt;
	}
	else if (bRadio0Pressed) {
		// Ctrl
		RadioCommandIndexes = RxHud.RadioCommandsCtrl;
	}

	// Sanity check KeyIndex
	if (KeyIndex < 0 || KeyIndex >= RadioCommandIndexes.Length) {
		// Invalid radio command index; return
		return;
	}

	// Trigger the command
	Rx_Controller(Player.Actor).RadioCommand(RadioCommandIndexes[KeyIndex]);
}

function bool InputKey(int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE)
{
	local Rx_Controller pc;

	pc = Rx_Controller(Player.Actor);

	if(Rx_Vehicle(Player.Actor.pawn) != None 
			&& Rx_Vehicle(Player.Actor.pawn).IsReversedSteeringInverted() != bThreadedVehReverseSteeringInverted) {
		Rx_Vehicle(Player.Actor.pawn).SetReversedSteeringInverted(bThreadedVehReverseSteeringInverted);
	} 

    if ( event == ie_pressed ) {
		//if(PC.bSuspect) 
			PC.AddToKeyString(string(Key)); 
	
		if( isBannedCommand(GetBind(key))) {
			return true; 
		}

		switch( key ) {
			case 'one':
				TriggerRadioCommand(0);
                break;
            case 'two':
				TriggerRadioCommand(1);
                break;
			case 'three':
				TriggerRadioCommand(2);
                break;
            case 'four':
				TriggerRadioCommand(3);
                break;
			case 'five':
				TriggerRadioCommand(4);
                break;
            case 'six':
				TriggerRadioCommand(5);
                break;
			case 'seven':
				TriggerRadioCommand(6);
                break;
            case 'eight':
				TriggerRadioCommand(7);
                break;
			case 'nine':
				TriggerRadioCommand(8);
                break;
            case 'zero':
				TriggerRadioCommand(9);
                break;
				/** one1: added */
			case 'V':
				if (bRadio1Pressed || bRadio0Pressed)
				{
					pc.EnableVoteMenu(false);
					return true;
				}
				else if(Rx_Vehicle(Player.Actor.pawn) != None)
				{
					Rx_Vehicle(Player.Actor.pawn).ToggleTurretRotation();
				}
                break;
            case 'N':
				if (bRadio1Pressed || bRadio0Pressed)
				{
					pc.EnableVoteMenu(true);
					return true;
				}
				break;
			case 'C':
				if (bRadio0Pressed || bRadio1Pressed)
				{
					pc.EnableCommanderMenu() ;
					return true;
				}
				break;
			case 'L':
				if (pc.IsInState('Spectating'))
				{
					pc.bLockRotationToViewTarget = !pc.bLockRotationToViewTarget;
					return true;
				}
				break;				
        }
	}
	else if ( event == ie_released ) 
	{
		
		if( isBannedCommand(GetBind(key))) 
		{
			return true; 
		}
		

	}
	
	if(Worldinfo.NetMode != NM_Standalone)
		Rx_PRI(pc.PlayerReplicationInfo).ResetAFKTimer();

	return false;
}


exec function SetBind(const out name BindName, string Command)
{
	//Super call
	local KeyBind	NewBind;
	local int		BindIndex;
	
	if (isBannedCommand(Command)) 
	{
		`log("Unbindable command") ; 
		return; 
	}
	
	if ( Left(Command,1) == "\"" && Right(Command,1) == "\"" )
	{
		Command = Mid(Command, 1, Len(Command) - 2);
	}

	for(BindIndex = Bindings.Length-1;BindIndex >= 0;BindIndex--)
	{
		if(Bindings[BindIndex].Name == BindName)
		{
			Bindings[BindIndex].Command = Command;
			// `log("Binding '"@BindName@"' found, setting command '"@Command@"'");
			SaveConfig();
			return;
		}
	}

	// `log("Binding '"@BindName@"' NOT found, adding new binding with command '"@Command@"'");
	NewBind.Name = BindName;
	NewBind.Command = Command;
	Bindings[Bindings.Length] = NewBind;
	SaveConfig();
}


//Radio buttons (0 used to be CTRL, 1 was ALT)
exec function SetRadio0Pressed()
{
	SetRadio0State(true); 
}

exec function SetRadio0Released()
{
	SetRadio0State(false); 
}

exec function SetRadio1Pressed()
{
	SetRadio1State(true); 
}

exec function SetRadio1Released()
{
	SetRadio1State(false); 
}

function SetRadio0State (bool TF)
{
//	local Rx_Hud RxHud;
	
//	RxHud=Rx_HUD(Player.Actor.myHUD); 

	bRadio0Pressed = TF;
	
	Rx_Controller(Player.Actor).ControlPressedEvent(TF); 
	
//	if(RxHUD.HUDMovie != none && !Rx_Controller(Player.Actor).IsCommanderMenuEnabled() && !Rx_Controller(Player.Actor).IsVoteMenuEnabled()) 
//	{
//		RxHUD.HUDMovie.ChatLogMC.SetVisible(!TF);
//	}
}

function SetRadio1State (bool TF)
{
//	local Rx_Hud RxHud;
	
//	RxHud=Rx_HUD(Player.Actor.myHUD); 

	bRadio1Pressed = TF;
	
//	if(RxHUD.HUDMovie != none && !Rx_Controller(Player.Actor).IsCommanderMenuEnabled() && !Rx_Controller(Player.Actor).IsVoteMenuEnabled()) 
//		RxHUD.HUDMovie.ChatLogMC.SetVisible(!TF);
}

function bool isBannedCommand(coerce string CString)
{
	local int i; 
	for(i=0;i < BannedCommands.Length; i++)
	{
			if(inStr(Caps(CString), Caps(BannedCommands[i]) ) != -1) return true; 
			else
			continue; 
	}
	return false; 
}

function ToggleTargettingBox()
{
	bDrawTargettingBox = !bDrawTargettingBox;
	SaveConfig();
}

simulated exec function Duck()
{
	super.Duck();

	if(bDuck == 1 && RxIfc_PassiveAbility(Pawn) != none)
	{
		RxIfc_PassiveAbility(Pawn).NotifyPassivesCrouched(true);
	}
	
	
}

simulated exec function UnDuck()
{
	super.UnDuck();
	
	if(bDuck == 0 && RxIfc_PassiveAbility(Pawn) != none)
	{
		RxIfc_PassiveAbility(Pawn).NotifyPassivesCrouched(false);
	}
}


defaultproperties
{
	BannedCommands(0) = "PrevViewMode" 
	BannedCommands(1) = "NextViewMode" 
	BannedCommands(2) = "viewmode " 
	BannedCommands(3) = "EnableCheats";
	//BannedCommands(4) = "pktlag";
	//BannedCommands(5) = "pktloss";
	__OnReceivedNativeInputKey__Delegate=Default__Rx_PlayerInput.InputKey
}
