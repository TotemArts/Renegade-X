

class Rx_SoftLevelBoundaryVolume extends Volume placeable;

var float				fWaitToWarn;
var Soundcue			PlayerWarnSound;

var() int				DamageWait;
var() bool				bLimitToOneTeam;
var() int				TeamNum;

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

/**
 * @brief Checks if a pair of 2-dimensional rays intersect (ignores Z).
 * 
 * @param vect1 Position vector of the first ray
 * @param vect2 Position vector of the second ray
 * @param unit1 Unit vector representing direction of the first ray
 * @param unit2 Unit vector representing direction of the second ray
 * @return True if the rays intersect, false otherwise
 */
static function bool RaysIntersect2D(vector vect1, vector vect2, vector unit1, vector unit2)
{
	local float div, diff_x, diff_y;

	div = unit2.X * unit1.Y - unit2.Y * unit1.X;
	if (div == 0.0) // parallel
		return false;

	diff_x = vect2.X - vect1.X;
	diff_y = vect2.Y - vect1.Y;
	return (diff_y * unit2.X - diff_x * unit2.Y) / div > 0 && (diff_y * unit1.X - diff_x * unit1.Y) / div > 0;
}

function bool Touches(Rx_SoftLevelBoundaryVolume in_volume)
{
	local Rx_SoftLevelBoundaryVolume vol;


	foreach TouchingActors(class'Rx_SoftLevelBoundaryVolume', vol)
		if (vol == in_volume)
			return true;
	return false;
}

function bool Intersects(Rx_SoftLevelBoundaryVolume vol)
{
	return Touches(vol) && RaysIntersect2D(Location, vol.Location, vector(ArrowRotation), vector(vol.ArrowRotation));
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local array<Rx_Controller> controllers;
	local Rx_Controller PC;
	local int index;

	if(bLimitToOneTeam)
	{
		if((Rx_Pawn(Other) != None && Rx_Pawn(Other).GetTeamNum() != TeamNum) || (Rx_Vehicle(Other) != None && Rx_Vehicle(Other).GetTeamNum() != TeamNum))
			return;
	}
	
	if (UDKVehicle(Other) != None) // A vehicle - Add all occupants
	{
		UDKVehicle(Other).bAllowedExit = false;
		for (index = 0; index != UDKVehicle(Other).Seats.Length; ++index)
			if (UDKVehicle(Other).Seats[index].SeatPawn.Controller != None && Rx_Controller(UDKVehicle(Other).Seats[index].SeatPawn.Controller) != None)
				controllers.AddItem(Rx_Controller(UDKVehicle(Other).Seats[index].SeatPawn.Controller));
	}
	else if (Pawn(Other) != None && Rx_Controller(Pawn(Other).Controller) != None) // A player's pawn - Add player
		controllers.AddItem(Rx_Controller(Pawn(Other).Controller));
	else // Happens when leaving vehicle before controller is attached
		return;

	while (controllers.Length != 0)
	{
		PC = controllers[controllers.Length - 1];
		controllers.Remove(controllers.Length - 1, 1);
		PC.BoundaryVolumes.AddItem(self);

		if (PC.IsInPlayArea)
		{
			PC.PlayAreaLeaveDamageWaitCounter = 0;
			PC.PlayAreaLeaveDamageWait = DamageWait;
			PC.SetTimer(fWaitToWarn, false, 'PlayAreaTimerTick');
			PC.IsInPlayArea = false;
		}
	}
}

function SuccessfulExit(Actor Other, Rx_Controller PC)
{
	if (UDKVehicle(Other) != None)
		UDKVehicle(Other).bAllowedExit = true;

	PC.IsInPlayArea = true;
	if (WorldInfo.NetMode != NM_DedicatedServer && Rx_Hud(PC.myHUD) != None)
		Rx_Hud(PC.myHUD).ClearPlayAreaAnnouncement();
	else
		PC.ClearPlayAreaAnnouncementClient();
}

event UnTouch(Actor Other)
{
	local array<Rx_Controller> controllers;
	local Rx_Controller PC;
	local int index;

	if(bLimitToOneTeam)
	{
		if((Rx_Pawn(Other) != None && Rx_Pawn(Other).GetTeamNum() != TeamNum) || (Rx_Vehicle(Other) != None && Rx_Vehicle(Other).GetTeamNum() != TeamNum))
			return;
	}

	if (UDKVehicle(Other) != None) // A vehicle - Add all occupants
	{
		for (index = 0; index != UDKVehicle(Other).Seats.Length; ++index)
			if (UDKVehicle(Other).Seats[index].SeatPawn.Controller != None && Rx_Controller(UDKVehicle(Other).Seats[index].SeatPawn.Controller) != None)
				controllers.AddItem(Rx_Controller(UDKVehicle(Other).Seats[index].SeatPawn.Controller));
	}
	else if (Rx_Pawn(Other) != None && Rx_Controller(Rx_Pawn(Other).Controller) != None) // A player's pawn - Add player
	{
		if (WorldInfo.TimeSeconds - Rx_Pawn(Other).LastRanInto > 1.0)
			controllers.AddItem(Rx_Controller(Pawn(Other).Controller));
	}
	else // Never happens
		return;

	if (IsInRange(ArrowRotation.Yaw - degrees_90, ArrowRotation.Yaw + degrees_90, Rotator(Other.Velocity + Other.GetAggregateBaseVelocity()).Yaw)) // Successful exit via x/y bounds (walking/driving)
		// TODO: Successful exit via z/pitch (flying/jumping/falling)
	{
		while (controllers.Length != 0)
		{
			PC = controllers[controllers.Length - 1];
			controllers.Remove(controllers.Length - 1, 1);
			PC.BoundaryVolumes.RemoveItem(self);

			// We're no longer in any volumes
			if (PC.BoundaryVolumes.Length == 0)
			{
				// We did not just leave a corner
				if (WorldInfo.TimeSeconds > PC.LastLeftBoundaryTime + Rx_MapInfo(WorldInfo.GetMapInfo()).SoftLevelBoundaryCornerTimeThreshold)
					SuccessfulExit(Other, PC);
				else // We just left a corner
				{
					if (Intersects(PC.LastLeftBoundary)) // These point to the same area; use AND logic (check if they BOTH are successful exits)
					{
						if (IsInRange(PC.LastLeftBoundary.ArrowRotation.Yaw - degrees_90, PC.LastLeftBoundary.ArrowRotation.Yaw + degrees_90, Rotator(Other.Velocity + Other.GetAggregateBaseVelocity()).Yaw)) // Successful exit via x/y bounds (walking/driving)
							SuccessfulExit(Other, PC);
					}
					else // These do not point to the same area; use OR logic (check if ANY are successful exits)
						SuccessfulExit(Other, PC);
				}
			}

			PC.LastLeftBoundary = self;
			PC.LastLeftBoundaryTime = WorldInfo.TimeSeconds;
		}
	}
	else // We exited a volume unsuccessfully.
	{
		while (controllers.Length != 0)
		{
			PC = controllers[controllers.Length - 1];
			controllers.Remove(controllers.Length - 1, 1);
			PC.BoundaryVolumes.RemoveItem(self);

			if (PC.BoundaryVolumes.Length == 0) // We're no longer in any volumes
			{
				if (WorldInfo.TimeSeconds <= PC.LastLeftBoundaryTime + Rx_MapInfo(WorldInfo.GetMapInfo()).SoftLevelBoundaryCornerTimeThreshold) // We just left a corner
				{
					if (Intersects(PC.LastLeftBoundary) == false) // These do not point to the same area; use OR logic (check if ANY are successful exits)
					{
						if (IsInRange(PC.LastLeftBoundary.ArrowRotation.Yaw - degrees_90, PC.LastLeftBoundary.ArrowRotation.Yaw + degrees_90, Rotator(Other.Velocity + Other.GetAggregateBaseVelocity()).Yaw)) // Successful exit via x/y bounds (walking/driving)
							SuccessfulExit(Other, PC);
					}
					// else // These point to the same area; use AND logic (check if BOTH are successful exits)
				}
			}

			PC.LastLeftBoundary = self;
			PC.LastLeftBoundaryTime = WorldInfo.TimeSeconds;
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
	
	//how long before start applying damage.
	DamageWait				= 10
	
	//internal
	bPawnsOnly 			    = true
}