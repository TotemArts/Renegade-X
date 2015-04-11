/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class CastleGame extends SimpleGame;

/** Set to true to allow attract mode */
var config bool bAllowAttractMode;


event OnEngineHasLoaded()
{
}

/**
 * Don't allow dying in CastleGame!
 */
function bool PreventDeath(Pawn KilledPawn, Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	return true;
}

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	// We'll only force CastleGame game type for maps that we know were build for Epic Citadel (EpicCitadel).
	// Note that ignore any possible prefix on the map file name so that PIE and Play On still work with this.
	if( Right( MapName, 11 ) ~= "EpicCitadel" ||
		InStr( MapName, "EpicCitadel." ) != -1 )
	{
		return super.SetGameType(MapName, Options, Portal);
	}

	return class'UDKBase.SimpleGame';
}

defaultproperties
{
	PlayerControllerClass=class'UDKBase.CastlePC'
	HUDType=class'UDKBase.MobileHUDExt'
}



