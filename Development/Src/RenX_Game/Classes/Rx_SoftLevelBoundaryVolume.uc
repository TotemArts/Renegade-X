

class Rx_SoftLevelBoundaryVolume extends Volume placeable;

var float				fWaitToWarn;
var Soundcue			PlayerWarnSound;

var int					DamageWaitCounter;
var() int				DamageWait;

var() ArrowComponent 	Arrow;
var() rotator 			ArrowRotation;

var const int degrees_90;
var const int degrees_180;
var const int degrees_360;

// Yaw: Between degrees_180 and -degrees_180, inclusive
// low_yaw/high_yaw: Between degrees_360 and -degrees_360, exclusive
static function bool IsInRange(int low_yaw, int high_yaw, int yaw)
{
	if (high_yaw - low_yaw >= default.degrees_360) // Full circle
		return true;

	if (yaw >= low_yaw && yaw <= high_yaw) // high_yaw < 180, low_yaw > -180
		return true;

	if (high_yaw > default.degrees_180)
	{
		if (low_yaw > 0) // high_yaw > 180, low_yaw > 0
		{
			if (yaw < 0)
				yaw += default.degrees_360;

			return yaw > low_yaw && yaw < high_yaw;
		}
		else if (low_yaw == 0) // high_yaw > 180, low_yaw == 0
		{
			if (yaw < 0)
				yaw += default.degrees_360;

			return yaw < high_yaw;
		}
		// high_yaw > 180, low_yaw < 0 -- Reachable only when yaw < 0, and not between 0 and low_yaw.
		// Therefore, yaw is either not within the range, or is between -180 and (high_yaw - 360)
		return yaw < high_yaw - default.degrees_360;
	}

	if (low_yaw < -default.degrees_180)
	{
		if (high_yaw < 0) // high_yaw < 0, low_yaw < -180
		{
			if (yaw > 0)
			{
				yaw -= default.degrees_360;
				if (yaw > low_yaw && yaw < high_yaw)
					return true;
			}
		}
		else if (high_yaw == 0) // high_yaw == 0, low_yaw < -180
		{
			if (yaw > 0)
				yaw -= default.degrees_360;
			return yaw < low_yaw;
		}

		// 180 > high_yaw > 0, low_yaw < -180 -- Reachable only when yaw > 0, and not between 0 and high_yaw.
		// Therefore, yaw is either not within the range, or is between (low_yaw + 360) and 180
		return yaw > low_yaw + default.degrees_360;
	}

	// low_yaw >= -180, high_yaw <= 180
	// Reachable only when:
	// - Yaw is 180 and high_yaw is not 180, but low_yaw is -180
	// - Yaw is -180 and low_yaw is not -180, but high_yaw is 180
	// - Yaw is not within bounds

	return (yaw == default.degrees_180 && low_yaw == -default.degrees_180) || (yaw == -default.degrees_180 && high_yaw == default.degrees_180);
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local array<Rx_Controller> controllers;
	local Rx_Controller PC;
	local int index;
	
	if (UDKVehicle(Other) != None) // A vehicle
	{
		UDKVehicle(Other).bAllowedExit = false;
		for (index = 0; index != UDKVehicle(Other).Seats.Length; ++index)
			if (UDKVehicle(Other).Seats[index].SeatPawn.Controller != None && Rx_Controller(UDKVehicle(Other).Seats[index].SeatPawn.Controller) != None)
				controllers.AddItem(Rx_Controller(UDKVehicle(Other).Seats[index].SeatPawn.Controller));
	}
	else if (Pawn(Other) != None && Rx_Controller(Pawn(Other).Controller) != None) // A player's pawn
			controllers.AddItem(Rx_Controller(Pawn(Other).Controller));
	else
		`log("ERROR: NEITHER VEHICLE NOR PAWN");

	while (controllers.Length != 0)
	{
		PC = controllers[controllers.Length - 1];
		controllers.Remove(controllers.Length - 1, 1);

		if (PC.IsInPlayArea)
		{
			PC.PlayAreaLeaveDamageWaitCounter = DamageWaitCounter;
			PC.PlayAreaLeaveDamageWait = DamageWait;
			PC.SetTimer(fWaitToWarn, false, 'PlayAreaTimerTick');
			PC.IsInPlayArea = false;
		}
	}
}

event UnTouch(Actor Other)
{
	local array<Rx_Controller> controllers;
	local Rx_Controller PC;
	local int index;

	if (IsInRange(ArrowRotation.Yaw - degrees_90, ArrowRotation.Yaw + degrees_90, Rotator(Other.Velocity).Yaw)) // Successful exit via x/y bounds (walking/driving)
		// TODO: Successful exit via z/pitch (flying)
	{
		if (UDKVehicle(Other) != None) // A vehicle
		{
			UDKVehicle(Other).bAllowedExit = true;
			for (index = 0; index != UDKVehicle(Other).Seats.Length; ++index)
				if (UDKVehicle(Other).Seats[index].SeatPawn.Controller != None && Rx_Controller(UDKVehicle(Other).Seats[index].SeatPawn.Controller) != None)
					controllers.AddItem(Rx_Controller(UDKVehicle(Other).Seats[index].SeatPawn.Controller));
		}
		else if (Pawn(Other) != None && Rx_Controller(Pawn(Other).Controller) != None) // A player's pawn
			controllers.AddItem(Rx_Controller(Pawn(Other).Controller));
		else
			`log("ERROR: NEITHER VEHICLE NOR PAWN");

		while (controllers.Length != 0)
		{
			PC = controllers[controllers.Length - 1];
			controllers.Remove(controllers.Length - 1, 1);

			PC.IsInPlayArea = true;
			if (WorldInfo.NetMode != NM_DedicatedServer && Rx_Hud(PC.myHUD) != None)
				Rx_Hud(PC.myHUD).ClearPlayAreaAnnouncement();
			else
				PC.ClearPlayAreaAnnouncementClient();
		}
	}
}

DefaultProperties
{
	Begin Object Class=ArrowComponent Name=AC
		ArrowColor=(R=150,G=100,B=150)
		ArrowSize=5.0
		AbsoluteRotation=true
		bDisableAllRigidBody=false
	End Object
	Components.Add(AC)
	Arrow=AC
	
	degrees_90 = 16384
	degrees_180 = 32768
	degrees_360 = 65536
	
	//how long before PlayerWarnSound is played and damage countdown starts.
	fWaitToWarn				= 1.0f 
	
	//sounds
	PlayerWarnSound			= SoundCue'RX_Dialogue.Generic.S_BackToObjective_Cue'
	//BeepSound				= SoundCue'RX_WP_Timed.Sounds.SC_Beep_Single'
	
	//how much damage to apply every second outside volume.
	//DamageToCause			= 20
	
	//how long before start applying damage.
	DamageWait				= 10
	
	//internal
	DamageWaitCounter		= 0
	bPawnsOnly 			    = true
}