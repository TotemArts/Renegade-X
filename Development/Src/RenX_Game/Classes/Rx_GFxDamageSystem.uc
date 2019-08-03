class Rx_GFxDamageSystem extends GFxMoviePlayer;

var WorldInfo ThisWorld;
var PlayerController PlayerOwner;
var GFxObject DamageScreen, CriticalScreen, DamageScreenType, TibFlashScreen, BurnFlashScreen;
var bool bHealthDirty;
var int DamageRate;
var int BleedType;
var bool bCritical;

function Init(optional LocalPlayer LocPlay)
{
	Start();
	Advance(0.f);

	PlayerOwner = GetPC();
	DamageScreen = GetVariableObject("_root.DamageScreen");
	CriticalScreen = GetVariableObject("_root.CriticalScreen");
	BurnFlashScreen = GetVariableObject("_root.DamageScreen.Damage.BurnDamage");
	TibFlashScreen = GetVariableObject("_root.DamageScreen.Damage.TibDamage");
}

function TickHUD(PlayerController PC)
{
	if (!bMovieIsOpen) {
		return;
	}

	PC = GetPC();
	if (PC != None)
	{
		if (Rx_Pawn(PC.Pawn) != None)
		{
			DamageRate = Rx_Pawn(PC.Pawn).DamageRate;
			if( PC.Pawn.Health <= 25 && !bCritical)
			{
				bCritical = true;
				InitCriticalScreen();
			}
			else if(PC.Pawn.Health > 25 && bCritical)
			{
				bCritical = false;
				DeInitCriticalScreen();
			}
			BleedType=Rx_Pawn(PC.Pawn).BleedDamageType;
			Rx_Pawn(PC.Pawn).BleedDamageType=0;
			InitDamageScreen();

		}
		else if (Rx_Vehicle(PC.Pawn) != None)
		{
			if(bCritical)
			{
				bCritical = false;
				DeInitCriticalScreen();
			}	
			DamageRate = 0;
			BleedType=0;
			InitDamageScreen();
			
		} else 
		{

		}
	}
}

function InitDamageScreen()
{
	if(BleedType == 1)
		BurnFlashScreen.GotoAndPlayI(2);
	else if(BleedType == 2)
		TibFlashScreen.GotoAndPlayI(2);

	if(BleedType > 0)
		BleedType=0;		//Always set back to 0 after use
			
	DamageScreen.GotoAndStopI(100 - (DamageRate));
}

function InitCriticalScreen()
{
	CriticalScreen.GotoAndPlayI(2);
}

function DeInitCriticalScreen()
{
	CriticalScreen.GotoAndStopI(1);
}

function ShowSystem()
{
	DamageScreen.SetVisible(true);
}
function HideSystem()
{
	DamageScreen.SetVisible(false);
}

DefaultProperties
{
	bDisplayWithHudOff=false
	MovieInfo=SwfMovie'RenXHud.RenXDamageSystem'
	bEnableGammaCorrection = false;
}
