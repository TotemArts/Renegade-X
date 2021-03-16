class Rx_Hud_Component extends Object;

var Canvas Canvas;
var protected Rx_Hud RenxHud;

var protected const Color ColorGreyedOut;
var protected const Color ColorWhite;
var protected const Color ColorRed;
var protected const Color ColorYellow;
var protected const Color ColorGreen;
var protected const Color ColorBlue;
var protected const Color ColorBlue2;
var protected const Color ColorBlue3;

enum STANCE
{
	STANCE_NEUTRAL,
	STANCE_ENEMY,
	STANCE_FRIENDLY
};

function Update(float DeltaTime, Rx_HUD HUD)
{
	Canvas = HUD.Canvas;
	if (RenxHud == none)
	{
		RenxHud = HUD;
	}
}

function STANCE GetStance(Actor inActor)
{
	if (inActor.GetTeamNum() != TEAM_GDI && inActor.GetTeamNum() != TEAM_NOD)
	{
		return STANCE_NEUTRAL;
	} 
	else if (inActor.GetTeamNum() == RenxHud.PlayerOwner.GetTeamNum())
	{
		return STANCE_FRIENDLY;
	}
	else
	{
		return STANCE_ENEMY;
	}
}

function bool IsStealthedEnemyUnit(pawn inPawn)
{
	local RxIfc_Stealth StealthPawn; 
	
	StealthPawn = RxIfc_Stealth(inPawn);
	
	if ( StealthPawn!= none && GetStance(inPawn) == STANCE_ENEMY)
	{
		if (!StealthPawn.GetIsinTargetableState())
		{
			return true;
		}
	}
	return false;
}

function bool IsEnemySpy(Rx_Pawn inPawn)
{
	if (inPawn.isSpy() && GetStance(inPawn) == STANCE_ENEMY)
		return true;
	else
		return false;
}

function float GetWeaponRange()
{
	return RenxHud.GetWeaponRange();
}

function float GetWeaponTargetingRange()
{
	return RenxHud.GetWeaponTargetingRange();
}

function bool IsPTorMCT (actor a)
{
	if (Rx_BuildingAttachment_MCT(a) != none || Rx_BuildingAttachment_PT(a) != none)
		return true;
	else return false;
}

function bool IsBuildingComponent (actor a)
{
	if (Rx_BuildingAttachment(a) != none || Rx_Building(a) != none || Rx_Building_Internals(a) != none)
		return true;
	else return false;
}

function bool IsTechBuildingComponent (actor a)
{
	if(a.isA('Rx_CapturableMCT'))
		return false;
	else if (Rx_Building_TechBuilding_Internals(a) != none)
		return true;
	else if ( Rx_Building_Techbuilding(a) != none )
		return true;
	else if (Rx_BuildingAttachment(a) != none && Rx_Building_TechBuilding_Internals(Rx_BuildingAttachment(a).OwnerBuilding) != none)
		return true;
	else return false;
}

function Vehicle GetDrivenVehicle()
{
	if (RenxHud.PlayerOwner != none && RenxHud.PlayerOwner.Pawn != none && RenxHud.PlayerOwner.Pawn.DrivenVehicle != none)
	{
		return RenxHud.PlayerOwner.Pawn.DrivenVehicle;
	}
	else return none;
}

function bool IsActorInView (actor inActor, optional bool IgnoreTrace = false)
{
	local Vector screenCoords;
	local Vector2D screenCoords2d;
	local Vector canvasOrigin, acotrDir, hitnorm, hitloc;
	local Rx_SmokeScreen DummyActor;
	local Actor temp;

	if (IsBuildingComponent(inActor) && !IsPTorMCT(inActor))
		return true;

	screenCoords = Canvas.Project(inActor.Location);

	if (screenCoords.X > Canvas.SizeX || screenCoords.X < 0 ||
		screenCoords.Y > Canvas.SizeY || screenCoords.Y < 0 ||
		screenCoords.Z <= 0)
	{
		return false; // Actor is not onscreen.
	}
	else if (!IgnoreTrace) // Actor is onscreen, so draw name if visible to camera.
	{
		screenCoords2d.X = screenCoords.X; 
		screenCoords2d.Y = screenCoords.Y;
		Canvas.DeProject(screenCoords2d,canvasOrigin,acotrDir);

		// We want to do a full trace on enemy pawns to hide them behind dynamic objects.
		if (Rx_Pawn(inActor) != none && GetStance(inActor) == STANCE_ENEMY) 
		{
			temp = inActor.trace(hitloc,hitnorm,canvasOrigin);
			if (temp == (RenxHud.PlayerOwner.ViewTarget) || temp == none)
			{
				foreach inActor.TraceActors(class'Rx_SmokeScreen', DummyActor, hitloc, hitnorm, canvasOrigin)
					return false;
				return true;
			}
			else return false;
		}
		// Others (vehicles and friendly pawns) are ok to do fast trace and draw names behind dynamic objects since they're less gameplay critical to be hidden.
		else 
			return (inActor.FastTrace(canvasOrigin,,,true));
	}
	else return true;
}

// as a bit of extension, when actor is not in play or you need to take a bit of offset...

function bool IsLocationInView (vector inVector, optional bool IgnoreTrace = false)
{
	local Vector screenCoords;
	local Vector2D screenCoords2d;
	local Vector canvasOrigin, acotrDir;

	screenCoords = Canvas.Project(inVector);

	if (screenCoords.X > Canvas.SizeX || screenCoords.X < 0 ||
		screenCoords.Y > Canvas.SizeY || screenCoords.Y < 0 ||
		screenCoords.Z <= 0)
	{
		return false; // location is not onscreen.
	}
	else if (!IgnoreTrace) // location is onscreen
	{
		screenCoords2d.X = screenCoords.X; 
		screenCoords2d.Y = screenCoords.Y;
		Canvas.DeProject(screenCoords2d,canvasOrigin,acotrDir);

		return (RenxHud.PlayerOwner.FastTrace(canvasOrigin,inVector,,true));
	}
	else return true;
}

function Draw()
{

}

function float GetAlphaForDistance(float distance, float maxDistance, optional float maxAlphaPercentage = 0.8)
{
	local float Alpha, maxAlphaDist;

	if (distance <maxDistance)
	{
		maxAlphaDist = maxDistance * maxAlphaPercentage;
		if(distance >= maxAlphaDist)
		{
			Alpha = FMin((maxDistance - distance) / (maxDistance - maxAlphaDist), 1.f);

			return Alpha;
		}
		else return 1.f;
	}
	
	return 0.f;
}

function float GetResolutionModifier()
{
	return FMax(0.75,RenXHud.ViewportSize.Y / 1080);
}

DefaultProperties
{
	ColorGreyedOut = (R = 0, G = 0, B = 0, A = 100)
	ColorWhite = (R = 255, G = 255, B = 255, A = 255)
	ColorRed = (R = 255, G = 62, B = 0, A = 255)
	ColorYellow = (R = 255, G = 215, B = 0, A = 255)
	ColorGreen = (R = 93, G = 255, B = 0, A = 255)
	ColorBlue = (R = 167, G = 227, B = 255, A = 255)
	ColorBlue2 = (R = 50, G = 50, B = 255, A = 150)
	ColorBlue3 = (R = 50, G = 255, B = 255, A = 255) //Used on armour bar/text for targeting box.
}
