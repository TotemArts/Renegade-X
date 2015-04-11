class Rx_GFxDamageSystem extends GFxMoviePlayer;

var WorldInfo ThisWorld;
var PlayerController PlayerOwner;
var GFxObject DamageScreen;
var bool bHealthDirty;
var int DamageRate;

function Init(optional LocalPlayer LocPlay)
{
	Start();
	Advance(0.f);

	PlayerOwner = GetPC();
	DamageScreen = GetVariableObject("_root.DamageScreen");
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
			if( PC.Pawn.Health <= 25 )
			{
				DamageScreen.GotoAndStopI(PC.Pawn.Health);
			}
			else
			{
				InitDamageScreen();
			}
		}
		else if (Rx_Vehicle(PC.Pawn) != None)
		{
			DamageRate = 0;
			InitDamageScreen();
		} else 
		{

		}
	}
}
function InitDamageScreen()
{
	DamageScreen.GotoAndStopI(100 - (DamageRate));
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
