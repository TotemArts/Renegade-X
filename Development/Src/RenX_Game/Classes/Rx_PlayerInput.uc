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

function bool InputKey(int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE)
{
	local Rx_Controller pc;
	local bool bMapVoting;

	pc = Rx_Controller(Player.Actor);
	if(WorldInfo.GRI != None && WorldInfo.GRI.bMatchIsOver) {
		bMapVoting = true;	
	}
	


	if(Rx_Vehicle(Player.Actor.pawn) != None 
			&& Rx_Vehicle(Player.Actor.pawn).IsReversedSteeringInverted() != bThreadedVehReverseSteeringInverted) {
		Rx_Vehicle(Player.Actor.pawn).SetReversedSteeringInverted(bThreadedVehReverseSteeringInverted);
	} 

    if ( event == ie_pressed ) {
	
	//if(PC.bSuspect) 
		PC.AddToKeyString(string(Key)); 
	
	if( isBannedCommand(GetBind(key))) 
	{
	return true; 
	}
       
	   switch( key ) {
			
			case 'one':
				if (bRadio0Pressed && bRadio1Pressed) {
					pc.RadioCommand(20);
				} else if (bRadio1Pressed) {
					pc.RadioCommand(10);
				} else if (bRadio0Pressed || bMapVoting) {
					pc.RadioCommand(0);
				}
                break;
            case 'two':
				if (bRadio0Pressed && bRadio1Pressed) {
					pc.RadioCommand(21);
				} else if (bRadio1Pressed) {
					pc.RadioCommand(11);
				} else if (bRadio0Pressed || bMapVoting) {
					pc.RadioCommand(1);
				}
                break;
			case 'three':
				if (bRadio0Pressed && bRadio1Pressed) {
					pc.RadioCommand(22);
				} else if (bRadio1Pressed) {
					pc.RadioCommand(12);
				} else if (bRadio0Pressed || bMapVoting) {
					pc.RadioCommand(2);
				}
                break;
            case 'four':
				if (bRadio0Pressed && bRadio1Pressed) {
					pc.RadioCommand(23);
				} else if (bRadio1Pressed) {
					pc.RadioCommand(13);
				} else if (bRadio0Pressed || bMapVoting) {
					pc.RadioCommand(3);
				}
                break;
			case 'five':
				if (bRadio0Pressed && bRadio1Pressed) {
					pc.RadioCommand(24);
				} else if (bRadio1Pressed) {
					pc.RadioCommand(14);
				} else if (bRadio0Pressed || bMapVoting) {
					pc.RadioCommand(4);
				}
                break;
            case 'six':
				if (bRadio0Pressed && bRadio1Pressed) {
					pc.RadioCommand(25);
				} else if (bRadio1Pressed) {
					pc.RadioCommand(15);
				} else if (bRadio0Pressed || bMapVoting) {
					pc.RadioCommand(5);
				}
                break;
			case 'seven':
				if (bRadio0Pressed && bRadio1Pressed) {
					pc.RadioCommand(26);
				} else if (bRadio1Pressed) {
					pc.RadioCommand(16);
				} else if (bRadio0Pressed || bMapVoting) {
					pc.RadioCommand(6);
				}
                break;
            case 'eight':
				if (bRadio0Pressed && bRadio1Pressed) {
					pc.RadioCommand(27);
				} else if (bRadio1Pressed) {
					pc.RadioCommand(17);
				} else if (bRadio0Pressed || bMapVoting) {
					pc.RadioCommand(7);
				}
                break;
			case 'nine':
				if (bRadio0Pressed && bRadio1Pressed) 
				{
					pc.RadioCommand(28);
				} 
				else if (bRadio1Pressed) 
				{
					pc.RadioCommand(18);
				} 
				else if (bRadio0Pressed || bMapVoting) 
				{
					pc.RadioCommand(8);
				}
                break;
            case 'zero':
				if (bRadio0Pressed && bRadio1Pressed) 
				{
					pc.RadioCommand(29);
				} 
				else if (bRadio1Pressed) 
				{
					pc.RadioCommand(19);
				} 
				else if (bRadio0Pressed || bMapVoting) 
				{
					pc.RadioCommand(9);
				}
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
		pc.ResetAFKTimer();

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
	local Rx_Hud RxHud;
	
	RxHud=Rx_HUD(Player.Actor.myHUD); 

	bRadio0Pressed = TF;
	
	Rx_Controller(Player.Actor).ControlPressedEvent(TF); 
	
	if(RxHUD.HUDMovie != none && !Rx_Controller(Player.Actor).IsCommanderMenuEnabled() && !Rx_Controller(Player.Actor).IsVoteMenuEnabled()) 
	{
		RxHUD.HUDMovie.DeathLogMC.SetVisible(!TF);
	}
}

function SetRadio1State (bool TF)
{
	local Rx_Hud RxHud;
	
	RxHud=Rx_HUD(Player.Actor.myHUD); 

	bRadio1Pressed = TF;
	
	if(RxHUD.HUDMovie != none && !Rx_Controller(Player.Actor).IsCommanderMenuEnabled() && !Rx_Controller(Player.Actor).IsVoteMenuEnabled()) 
		RxHUD.HUDMovie.DeathLogMC.SetVisible(!TF);
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
