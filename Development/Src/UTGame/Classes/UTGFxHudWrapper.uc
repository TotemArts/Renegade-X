/**********************************************************************

Copyright   :   Copyright 2006-2007 Scaleform Corp. All Rights Reserved.

Portions of the integration code is from Epic Games as identified by Perforce annotations.
Copyright 2014-2015 Epic Games, Inc. All rights reserved.

Licensees may use this file in accordance with the valid Scaleform
Commercial License Agreement provided with the software.

This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING
THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR ANY PURPOSE.

**********************************************************************/
/**
 * HUDWrapper to workaround lack of multiple inheritance.
 * Related Flash content:   ut3_hud.fla
 *                          ut3_minimap.fla
 *                          ut3_scoreboard.fla
 *
 */
class UTGFxHudWrapper extends UTHUDBase;

/** Main Heads Up Display Flash movie */
var GFxMinimapHud   HudMovie;

/** Movie for non-functional sample inventory management UI */
var GFxProjectedUI      InventoryMovie;

/** Class of HUD Movie object */
var class<GFxMinimapHUD> MinimapHUDClass;

exec function MinimapZoomIn()
{
	HudMovie.MinimapZoomIn();
}

exec function MinimapZoomOut()
{
	HudMovie.MinimapZoomOut();
}

singular event Destroyed()
{
	RemoveMovies();

	Super.Destroyed();
}

/**
  * Destroy existing Movies
  */
function RemoveMovies()
{
	if ( HUDMovie != None )
	{
		HUDMovie.Close(true);
		HUDMovie = None;
	}
	if (InventoryMovie != None)
	{
		InventoryMovie.Close(true);
		InventoryMovie = None;
	}
	Super.RemoveMovies();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	CreateHUDMovie();
}

/**
  * Create and initialize the HUDMovie.
  */
function CreateHUDMovie()
{
	HudMovie = new MinimapHUDClass;
	HudMovie.SetTimingMode(TM_Real);
	HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
	HudMovie.ToggleCrosshair(true);
}

/**
  * Returns the index of the local player that owns this HUD
  */
function int GetLocalPlayerOwnerIndex()
{
	return HudMovie.LocalPlayerOwnerIndex;
}

/**
 *  Toggles visibility of normal in-game HUD
 */
function SetVisible(bool bNewVisible)
{
	HudMovie.ToggleCrosshair(bNewVisible);
	HudMovie.Minimap.SetVisible(bNewVisible);
	Super.SetVisible(bNewVisible);
	HudMovie.SetPause(!bNewVisible);
}

function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{
	HudMovie.DisplayHit(HitDir, Damage, DamageType);
}

/**
  * Called when pause menu is opened
  */
function CloseOtherMenus()
{
	if ( InventoryMovie != none && InventoryMovie.bMovieIsOpen )
	{
		InventoryMovie.StartCloseAnimation();
		return;
	}
}


/**
  * Recreate movies since resolution changed (also creates them initially)
  */
function ResolutionChanged()
{
	local bool bNeedInventoryMovie;

	bNeedInventoryMovie = InventoryMovie != none && InventoryMovie.bMovieIsOpen;
	super.ResolutionChanged();

	CreateHUDMovie();
	if ( bNeedInventoryMovie )
	{
		ToggleInventory();
	}
}

/**
 * PostRender is the main draw loop.
 */
event PostRender()
{
	super.PostRender();

	if (HudMovie != none)
		HudMovie.TickHud(0);

	if ( InventoryMovie != none && InventoryMovie.bMovieIsOpen )
	{
		InventoryMovie.Tick(RenderDelta);
		InventoryMovie.UpdatePos();
	}

	if ( bShowHud && bEnableActorOverlays )
	{
		DrawHud();
	}

	if (bShowMobileHud)
	{
		DrawInputZoneOverlays();
	}
}

/**
  * Call PostRenderFor() on actors that want it.
  */
event DrawHUD()
{
	local vector ViewPoint;
	local rotator ViewRotation;
	local float XL, YL, YPos;

	if (UTGRI != None && !UTGRI.bMatchIsOver  )
	{
		Canvas.Font = GetFontSizeIndex(0);
		PlayerOwner.GetPlayerViewPoint(ViewPoint, ViewRotation);
		DrawActorOverlays(Viewpoint, ViewRotation);
	}

	if ( bCrosshairOnFriendly )
	{
		// verify that crosshair trace might hit friendly
		bGreenCrosshair = CheckCrosshairOnFriendly();
		bCrosshairOnFriendly = false;
	}
	else
	{
		bGreenCrosshair = false;
	}

	if ( HudMovie.bDrawWeaponCrosshairs )
	{
		PlayerOwner.DrawHud(self);
	}

	if ( bShowDebugInfo )
	{
		Canvas.Font = GetFontSizeIndex(0);
		Canvas.DrawColor = ConsoleColor;
		Canvas.StrLen("X", XL, YL);
		YPos = 0;
		PlayerOwner.ViewTarget.DisplayDebug(self, YL, YPos);

		if (ShouldDisplayDebug('AI') && (Pawn(PlayerOwner.ViewTarget) != None))
		{
			DrawRoute(Pawn(PlayerOwner.ViewTarget));
		}
		return;
	}
}

function LocalizedMessage
(
	class<LocalMessage>		InMessageClass,
	PlayerReplicationInfo	RelatedPRI_1,
	PlayerReplicationInfo	RelatedPRI_2,
	string					CriticalString,
	int						Switch,
	float					Position,
	float					LifeTime,
	int						FontSize,
	color					DrawColor,
	optional object			OptionalObject
)
{
	local class<UTLocalMessage> UTMessageClass;

	UTMessageClass = class<UTLocalMessage>(InMessageClass);

	if (InMessageClass == class'UTMultiKillMessage')
		HudMovie.ShowMultiKill(Switch, "Kill Streak!");
	else if (ClassIsChildOf (InMessageClass, class'UTDeathMessage'))
		HudMovie.AddDeathMessage (RelatedPRI_1, RelatedPRI_2, class<UTDamageType>(OptionalObject));
	else  if ( (UTMessageClass == None) || UTMessageClass.default.MessageArea > 6 )
	{
		HudMovie.AddMessage("text", InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
	}
	else if ( (UTMessageClass.default.MessageArea < 4) || (UTMessageClass.default.MessageArea == 6) )
	{
		HudMovie.SetCenterText(InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
	}

	// Skip message area 4,5 for now (pickup and weapon switch messages)
}

/**
 * Add a new console message to display.
 */
function AddConsoleMessage(string M, class<LocalMessage> InMessageClass, PlayerReplicationInfo PRI, optional float LifeTime)
{
	// check for beep on message receipt
	if( bMessageBeep && InMessageClass.default.bBeep )
	{
		PlayerOwner.PlayBeepSound();
	}

	HudMovie.AddMessage("text", M);
}

/*
 * Toggle for  3D Inventory menu.
 */
exec function ToggleInventory()
{
	if ( InventoryMovie != None && InventoryMovie.bMovieIsOpen )
	{
		InventoryMovie.StartCloseAnimation();
	}
	else if ( PlayerOwner.Pawn != None )
	{
		if (InventoryMovie == None)
		{
			InventoryMovie = new class'GFxProjectedUI';
		}

		InventoryMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
		InventoryMovie.SetTimingMode(TM_Real);
		InventoryMovie.Start();

		if (!WorldInfo.bPlayersOnly)
		{
		   PlayerOwner.ConsoleCommand("playersonly");
		}

		// Hide the HUD.
		SetVisible(false);
	}
}

function CompleteCloseInventory()
{
	if (WorldInfo.bPlayersOnly)
	{
		PlayerOwner.ConsoleCommand("playersonly");
	}

	SetTimer(0.1, false, 'CompleteCloseTimer');
}

/*
 * Used to manage the timing of events on Inventory close.
 *
 */
function CompleteCloseTimer()
{
	//If InventoryMovie exists, destroy it.
	if ( InventoryMovie != none && InventoryMovie.bMovieIsOpen )
	{
		InventoryMovie.Close(FALSE); // Keep the Pause Menu loaded in memory for reuse.
	}

	SetVisible(true);
}

defaultproperties
{
	bEnableActorOverlays=true
	MinimapHUDClass=class'GFxMinimapHUD'
}
