class Rx_Hud_PlayerNames extends Rx_Hud_Component;

var float RenderDelta;

var const float EnemyDisplayNamesRadius;
var const float EnemyVehicleDisplayNamesRadius;
var const float EnemyTargetedDisplayNamesRadius;
var const float EnemyTargetedVehicleDisplayNamesRadius;

var const float FriendlyDisplayNamesRadius;
var const float FriendlyVehicleDisplayNamesRadius;
var const float FriendlyTargetedDisplayNamesRadius;
var const float FriendlyTargetedVehicleDisplayNamesRadius;

var private const Font PlayerNameFont;
var private CanvasIcon Interact;

function Update(float DeltaTime, Rx_HUD HUD)
{
	Canvas = HUD.Canvas;
	if (RenxHud == none)
	{
		RenxHud = HUD;
	}

	RenderDelta = DeltaTime;
}

function Draw()
{
	DrawPlayerNames();
	DrawVehicleSeats();
}

function bool VehicleSeatOccupied(int Seat, int SeatMask)
{
	return bool(SeatMask & (1<<(seat)));
}

function bool JustUsInVehicle(Rx_Vehicle Vehicle)
{
	local int i;

	for (i = 0; i < Vehicle.Seats.Length; i++)
	{
		if (VehicleSeatOccupied(i,Vehicle.SeatMask) && Vehicle.GetSeatPRI(i) != none )
		{
			if (RenxHud.PlayerOwner.PlayerReplicationInfo.GetHumanReadableName() != Vehicle.GetSeatPRI(i).GetHumanReadableName())
				return false;
		}
	}
	return true;
}

function DrawVehicleSeats()
{
	local Rx_Vehicle OtherVehicle;
	local Pawn OurPawn;
	local string ScreenName;
	local float NameAlpha;
	local float OtherPawnDistance;
	local int i;

	// No need to draw player names on dedicated
	if(RenxHud.WorldInfo.NetMode == NM_DedicatedServer)
		return;
	
	OurPawn = Pawn(RenxHud.PlayerOwner.ViewTarget);
	// Only draw if we have a pawn of some sort.
	if(OurPawn == None)
		return;

	
	
	// For each Rx_Vehicle in the game
   	foreach RenxHud.WorldInfo.AllPawns(class'Rx_Vehicle', OtherVehicle)
	{
		if (OtherVehicle == None || Rx_Vehicle_Harvester(OtherVehicle) != none)
			continue;
		if (Rx_Defence(OtherVehicle) != none && Rx_Defence(OtherVehicle).bAIControl) // A defense that is controlled by AI.
			continue;
		if (IsStealthedEnemyUnit(OtherVehicle) || OtherVehicle.Health <= 0)
			continue;

		if (!RenxHud.ShowOwnNameInVehicle && 
			(OtherVehicle == RenxHud.PlayerOwner.ViewTarget || (Rx_VehicleSeatPawn(RenxHud.PlayerOwner.ViewTarget) != none && OtherVehicle == Rx_VehicleSeatPawn(RenxHud.PlayerOwner.ViewTarget).MyVehicle))
			&& JustUsInVehicle(OtherVehicle))
			continue;

		if (OurPawn.DrivenVehicle != none) // If we are in a vehicle, check distancefrom the vehicle location
			OtherPawnDistance = VSize(OurPawn.DrivenVehicle.Location-OtherVehicle.location);
		else
			OtherPawnDistance = VSize(OurPawn.Location-OtherVehicle.location);

		// Fade based on display radius.
		if (RenxHud.TargetingBox.TargetedActor == OtherVehicle)
		{
			if(GetStance(OtherVehicle) == STANCE_FRIENDLY)
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,FriendlyTargetedVehicleDisplayNamesRadius);
			else
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,EnemyTargetedVehicleDisplayNamesRadius);
		}
		else
		{
			if(GetStance(OtherVehicle) == STANCE_FRIENDLY)
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,FriendlyVehicleDisplayNamesRadius);
			else
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,EnemyVehicleDisplayNamesRadius);
		}
		
		if (NameAlpha == 0 || !IsActorInView(OtherVehicle))
			continue;

		ScreenName = "";
		if (IsVehicleEmpty(otherVehicle))
		{
			DrawNameOnActor(OtherVehicle,"Empty",GetStance(OtherVehicle),NameAlpha);
		}
		else if(OurPawn.GetTeamNum() == OtherVehicle.GetTeamNum())
		{
			for (i = 0; i < OtherVehicle.Seats.Length; i++)
			{
				if (VehicleSeatOccupied(i,OtherVehicle.SeatMask) && OtherVehicle.GetSeatPRI(i) != none )
				{
					ScreenName = OtherVehicle.GetSeatPRI(i).GetHumanReadableName();
					DrawNameOnActor(OtherVehicle,ScreenName,GetStance(OtherVehicle),NameAlpha, i);
				}
			}
		}
   	}
}

function bool IsVehicleEmpty( Rx_Vehicle otherVehicle)
{
	local int i;
	for (i = 0; i < OtherVehicle.Seats.Length; i++)
	{
		if (VehicleSeatOccupied(i,OtherVehicle.SeatMask))
			return false;
	}
	return true;
}

function DrawPlayerNames()
{
	local Rx_Pawn OtherPawn;
	local Pawn OurPawn;
	local string ScreenName;
	local float NameAlpha;
	local float OtherPawnDistance;

	// No need to draw player names on dedicated
	if(RenxHud.WorldInfo.NetMode == NM_DedicatedServer)
		return;
	
	OurPawn = Pawn(RenxHud.PlayerOwner.ViewTarget);
	// Only draw if we have a pawn of some sort.
	if(OurPawn == None)
		return;
	
	// For each Rx_Pawn in the game
   	foreach RenxHud.WorldInfo.AllPawns(class'Rx_Pawn', OtherPawn)
	{
		if (OtherPawn == None || OtherPawn.PlayerReplicationInfo == None || OtherPawn.Health <= 0)
			continue;
		if ((OtherPawn == ourPawn && !RenxHud.ShowOwnName) || IsStealthedEnemyUnit(OtherPawn) || OtherPawn.DrivenVehicle != None)
			continue;	

		if (OurPawn.DrivenVehicle != none) // If we are in a vehicle, check distancefrom the vehicle location
			OtherPawnDistance = VSize(OurPawn.DrivenVehicle.Location-OtherPawn.location);
		else
			OtherPawnDistance = VSize(OurPawn.Location-OtherPawn.location);

		// Fade based on display radius.
		if (RenxHud.TargetingBox.TargetedActor == OtherPawn)
		{
			if(GetStance(OtherPawn) == STANCE_FRIENDLY)
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,FriendlyTargetedDisplayNamesRadius);
			else
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,EnemyTargetedDisplayNamesRadius);
		}
		else
		{
			if(GetStance(OtherPawn) == STANCE_FRIENDLY)
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,FriendlyDisplayNamesRadius);
			else
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,EnemyDisplayNamesRadius);
		}

		if (NameAlpha == 0 || !IsActorInView(OtherPawn))
			continue;		

		ScreenName = OtherPawn.PlayerReplicationInfo.GetHumanReadableName();
		
		DrawNameOnActor(OtherPawn,ScreenName,GetStance(OtherPawn),NameAlpha);
   	}
}

function DrawNameOnActor(Actor inActor, string inName, optional STANCE inStance = STANCE_NEUTRAL,optional float Opacity = 1.0f, optional int listOffset = 0)
{
	local float XLen, YLen;
	local vector ScreenLoc;
	local FontRenderInfo FontInfo;

	ScreenLoc = Canvas.Project(inActor.Location);

	Canvas.StrLen(inName, XLen, YLen);

	Canvas.SetPos(ScreenLoc.X-0.5*XLen,ScreenLoc.Y-1.2*YLen + (YLen * listOffset));
	FontInfo.bEnableShadow=true;

	Canvas.Font = PlayerNameFont;			

	if (!RenxHud.NicknamesUseTeamColors || RenxHud.PlayerOwner.WorldInfo.IsPlayingDemo())
	{
		if (inStance == STANCE_ENEMY)
			Canvas.DrawColor = ColorRed;
		else if (inStance == STANCE_FRIENDLY)
			Canvas.DrawColor = ColorGreen;
		else 
			Canvas.DrawColor = ColorWhite;
	}
	else
	{
		if (RenxHud.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == TEAM_GDI && inStance == STANCE_FRIENDLY ||
			RenxHud.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == TEAM_NOD && inStance == STANCE_ENEMY)
			Canvas.DrawColor = ColorYellow;
		else if (RenxHud.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == TEAM_NOD && inStance == STANCE_FRIENDLY ||
			RenxHud.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == TEAM_GDI && inStance == STANCE_ENEMY)
			Canvas.DrawColor = ColorRed;
		else
			Canvas.DrawColor = ColorWhite;
	}
				
	Canvas.DrawColor.A *= Opacity;
	Canvas.DrawText(inName,,1.0,1.0,FontInfo);
	if(RenxHud.PlayerOwner.GetTeamNum() == inActor.GetTeamNum() && (Rx_Pawn(inActor) != None && Rx_Pawn(inActor).bBlinkingName)
																|| (Rx_Vehicle(inActor) != None && Rx_Vehicle(inActor).bBlinkingName))
	{
		DrawRadioCommandUsedIcon(inActor);
	}	
}

private function DrawRadioCommandUsedIcon(Actor inActor)
{
	local float X,Y;
	local vector ScreenLoc;
	
	ScreenLoc = inActor.Location;
	ScreenLoc.z += 60;	
	
	ScreenLoc = Canvas.Project(ScreenLoc);
	X = ScreenLoc.X - ((Interact.UL/2) * 1.3);

	Y = ScreenLoc.Y - (Interact.VL * 1.3);
	
	Y += Sin(class'WorldInfo'.static.GetWorldInfo().TimeSeconds * 7.0f) * 6.0f;

	Canvas.SetDrawColor(255,255,255,255);
	Canvas.DrawIcon(Interact,X,Y,1.3);
}

function float GetAlphaForDistance(float distance, float maxDistance)
{
	local float Alpha;

	if (distance <maxDistance)
	{
		if(distance >= maxDistance * 4/5)
		{
			Alpha = distance - 4.0/5.0*maxDistance;
			Alpha = Alpha/(maxDistance/5.0/100.0);
			Alpha = FMin(1.0,1.0-(1.0*Alpha/100.0));
			return Alpha;
		}
		else return 1;
	}
	else return 0;
}

DefaultProperties
{
	PlayerNameFont = Font'RenXHud.Font.PlayerName'

	EnemyDisplayNamesRadius = 1000.0f
	EnemyTargetedDisplayNamesRadius = 1500.0f
	EnemyVehicleDisplayNamesRadius = 2500.0f
	EnemyTargetedVehicleDisplayNamesRadius = 3000.0f
	
	FriendlyDisplayNamesRadius = 2000.0f
	FriendlyTargetedDisplayNamesRadius = 8000.0f
	FriendlyVehicleDisplayNamesRadius = 3500.0f
	FriendlyTargetedVehicleDisplayNamesRadius = 10000.0f
	
	Interact = (Texture = Texture2D'renxtargetsystem.T_TargetSystem_Interact', U= 0, V = 0, UL = 32, VL = 64)
}
