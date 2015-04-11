class Rx_Weapon_Scoped extends Rx_Weapon_Reloadable
    abstract;

var bool bPlayZoomSoundWhenShowOverlay, bPlayZoomSoundWhenHideOverlay;
var bool bNightVisionEnabled;
var bool bNightVisionEnabledLast;
var bool WasThirdPerson; // (Before zooming)
//var bool bDisplayCrosshair;
var Texture2D HudTexture;
var Material HudMaterial;
var float FadeTime;
var float ZoomedFOVMin;
var float ZoomedFOVMax;
var float ZoomedFOVIncrement;
var PostProcessChain NightVisionEffect;
var CameraAnim NightVisionAnim;
var() vector	FireOffsetZoomed;

/** LastZoomPlaySoundTimeThreshold is used to avoid spamming of zoom sounds when fast zooming */
var float LastZoomPlaySoundTime, LastZoomPlaySoundTimeThreshold;

/** Played when activate/deactivate night vision */
var SoundCue NightVisionTurnOnSound, NightVisionTurnOffSound; 

simulated function DrawZoomedOverlay( HUD H )
{
    local float ScaleX, ScaleY, StartX;

    bDisplayCrosshair = false;

    ScaleY = H.Canvas.SizeY/768.0;
    ScaleX = ScaleY;
    StartX = (H.Canvas.SizeX - (1024 * ScaleX)) / 2;

    // Draw sidebars
    H.Canvas.SetDrawColor(0,0,0);
    H.Canvas.SetPos(0,0);
    H.Canvas.DrawRect(StartX, H.Canvas.sizeY);
    H.Canvas.SetPos(H.Canvas.SizeX - StartX,0);
    H.Canvas.DrawRect(StartX, H.Canvas.sizeY);

    // Draw the crosshair
    if (HudMaterial != none)
    {
        H.Canvas.SetPos(StartX, 0);
        H.Canvas.DrawMaterialTile(HudMaterial, 1024 * ScaleX, 1024 * ScaleY);
    }
    else 
    {
        // For backwards compatibility
        H.Canvas.SetPos(StartX, 0);
        H.Canvas.DrawTile(HudTexture, 1024 * ScaleX, 768 * ScaleY, 0, 0, 1024, 768);
    }
    
    DrawHitIndicator(H,H.Canvas.ClipX * 0.5 - (default.CrosshairWidth * 0.5),H.Canvas.ClipY * 0.5 - (default.CrosshairHeight * 0.5));
}

/*
 * Hides the crosshair when zoomed, as the overlay should have one
 */
simulated function DrawCrosshair( Hud HUD )
{
    local UTPlayerController PC;

    if ( GetZoomedState() != ZST_NotZoomed )
    {
        DrawZoomedOverlay(HUD);
    }
    if( bDisplayCrosshair )
    {
        PC = UTPlayerController(Instigator.Controller);
        if ( (PC == None) || PC.bNoCrosshair )
        {
            return;
        }
        super.DrawCrosshair(HUD);
    }
}

simulated function PreloadTextures(bool bForcePreload)
{
    Super.PreloadTextures(bForcePreload);

    if (HudTexture != None)
    {
        HudTexture.bForceMiplevelsToBeResident = bForcePreload;
    }
}

/*
 * Initializes and updates the zoom FOV
 */
simulated function StartZoom(UTPlayerController PC)
{
    if (GetZoomedState() != ZST_NotZoomed) // Already zoomed, just update FOV
    {
        //If we zoom, start walking
        Rx_Pawn(GetALocalPlayerController().Pawn).StartWalking();
        
        PC.StartZoom(ZoomedTargetFOV, ZoomedRate);

        // play sound if needed
        if (GetZoomedState() != ZST_NotZoomed && WorldInfo.TimeSeconds - LastZoomPlaySoundTime >= LastZoomPlaySoundTimeThreshold)
        {
            if (GetZoomedState() == ZST_ZoomingIn && ZoomInSound != none)
                PlaySound(ZoomInSound, true);
            else if (GetZoomedState() == ZST_ZoomingOut && ZoomOutSound != none)
                PlaySound(ZoomOutSound, true);

            LastZoomPlaySoundTime = WorldInfo.TimeSeconds;
        }
    }
    else if ( HasAmmo(0) ) // Not zoomed, but are allowed to zoom
    {
        WasThirdPerson = false;

        if (!Instigator.IsFirstPerson())
        {
            WasThirdPerson = true;
            Rx_Controller(PC).SetOurCameraMode(FirstPerson);
        }

        bDisplayCrosshair = false;

        // Set manually, because otherwise the scope gets stuck on the wrong FOV when you bring it up
        PC.SetFOV( ZoomedTargetFOV ); 
        
        //Start Walking while zoomed
        Rx_Pawn(GetALocalPlayerController().Pawn).StartWalking();
        
        PC.StartZoom(ZoomedTargetFOV, ZoomedRate);
        
        if (ZoomInSound != none && bPlayZoomSoundWhenShowOverlay)
            PlaySound(ZoomInSound, true);

        if (bNightVisionEnabledLast)
            ToggleNightVision();

        ChangeVisibility(false);        
    }
}

/*
 * Unzooms and cleans up related stuff
 */
simulated function EndZoom(UTPlayerController PC)
{
    bDisplayCrosshair = true;
    bNightVisionEnabledLast = bNightVisionEnabled;
    ToggleNightVision(true);
    
    //Stop walking
    Rx_Pawn(GetALocalPlayerController().Pawn).StopWalking();
    
    PC.EndZoom();

    if (ZoomOutSound != none && bPlayZoomSoundWhenHideOverlay)
        PlaySound(ZoomOutSound, true);
    
    //Hack to put hand back on gun after zooming out. Need real zoom out animations.
    PlayWeaponAnimation(WeaponFireAnim[0], 0.01,,BaseSkelComponent);
    
    if (Instigator.IsFirstPerson() == true)
    {
        if (WasThirdPerson == true)
        {
			Rx_Controller(PC).SetOurCameraMode(ThirdPerson);
        }
        else
        {
            ChangeVisibility(true);
        }
    }
}

/*
 * Called when you switch weapons
 */
simulated function PutDownWeapon()
{
    if (GetZoomedState() != ZST_NotZoomed)
    {
        EndZoom(UTPlayerController(Instigator.Controller));
    }
    super.PutDownWeapon();
}

/*
 * Called when you mouse wheel down, also for zooming out
 */
simulated function bool DoOverrideNextWeapon()
{
    if (GetZoomedState() != ZST_NotZoomed)
    {
        ZoomedTargetFOV += Min(ZoomedFOVIncrement, ZoomedFOVMax-ZoomedTargetFOV);
        StartZoom(UTPlayerController(Instigator.Controller));
        return true;
    }
    return false;
}

/*
 * Called when you mouse wheel up, also for zooming in
 */
simulated function bool DoOverridePrevWeapon()
{
    if (GetZoomedState() != ZST_NotZoomed)
    {
        ZoomedTargetFOV -= Min(ZoomedFOVIncrement, ZoomedTargetFOV-ZoomedFOVMin);
        StartZoom(UTPlayerController(Instigator.Controller));
        return true;
    }
    return super.DoOverridePrevWeapon();
}

simulated function HolderDied()
{
    ToggleNightVision(true);
}

/*
 * Turns night vision on and off
 * @Parameter bEnable is whether to enable or disable night vision
 * @Parameter bSaveState will not modify bNightVisionUpdated, such that you can restore its state later
 */
reliable client function ToggleNightVision(optional bool bDisable)
{
    local UTPlayerController PC;
    local LocalPlayer LP;
    local int i;

    if (GetZoomedState() == ZST_NotZoomed && !bDisable)
        return;

    if (NightVisionEffect == none)
        return;

    PC = UTPlayerController(Instigator.Controller);
    if (PC != None)
    {
        LP = LocalPlayer(PC.Player);
        if (LP != None)
        {
            if (!bNightVisionEnabled && !bDisable)
            {
                LP.InsertPostProcessingChain(NightVisionEffect, INDEX_NONE, true);
                PC.ClientPlayCameraAnim(NightVisionAnim,,,,,true);
                bNightVisionEnabled = true;

                if (NightVisionTurnOnSound != none)
                    PlaySound(NightVisionTurnOnSound, true);
            }
            else
            {
                for (i = 0; i < LP.PlayerPostProcessChains.length; i++)
                {
                    if (LP.PlayerPostProcessChains[i].FindPostProcessEffect('NightVisionEffect') != None)
                    {
                        LP.RemovePostProcessingChain(i);
                        i--;
                        bNightVisionEnabled = false;
                        
                        
                    }
                }
                PC.ClientStopCameraAnim(NightVisionAnim);

                if (NightVisionTurnOffSound != none)
                    PlaySound(NightVisionTurnOffSound, true);
            }
        }
    }
}

simulated event CauseMuzzleFlash()
{
    if(GetZoomedState() == ZST_NotZoomed)
    {
        super.CauseMuzzleFlash();
    }
}

/*
 * Called every change between first and third person views.
 */
simulated function ChangeVisibility(bool bIsVisible)
{
    super.Changevisibility(bIsvisible);
    if(bIsVisible)
    {
        PlayArmAnimation('WeaponZoomOut',0.00001); // to cover zooms ended while in 3p
    }
    if(!Instigator.IsFirstPerson() && GetZoomedState() != ZST_NotZoomed) // to be consistent with not allowing zoom from 3p
    {
        EndZoom(UTPlayerController(Instigator.Controller));
    }
}

simulated function bool DenyClientWeaponSet()
{
    return (GetZoomedState() != ZST_NotZoomed);
}

simulated function vector GetEffectLocation()
{
    // tracer comes from center if zoomed in
    return (GetZoomedState() != ZST_NotZoomed) ? Instigator.Location : Super.GetEffectLocation();
}

/**
 * State WeaponPuttingDown
 * Putting down weapon in favor of a new one.
 * Weapon is transitioning to the Inactive state.
 */
simulated state WeaponPuttingDown
{
    simulated event BeginState( Name PreviousState )
    {
        if (bDebugWeapon)
        {
            `log("---"@self$"."$GetStateName()$".BeginState("$PreviousState$")");
        }
        ToggleNightVision(true);
        super.BeginState(PreviousState);
    }

}

simulated state Reloading
{
    simulated function BeginState( name PreviousState )
    {
        if (GetZoomedState() == ZST_Zoomed)
        {
            EndZoom(UTPlayerController(Instigator.Controller));
        }
        super.BeginState(PreviousState);
    }
}

simulated state BoltActionReloading
{
    simulated function BeginState( name PreviousState )
    {
        /**
        if (GetZoomedState() == ZST_Zoomed)
        {
            EndZoom(UTPlayerController(Instigator.Controller));
        }
        */
        if(WorldInfo.NetMode == NM_StandAlone)
        {
        	PlayWeaponBoltReloadAnim();
        	PlaySound( BoltReloadSound[CurrentFireMode], false,true);
        }
        super.BeginState(PreviousState);
    }
}

simulated event vector GetMuzzleLoc()
{
	if (GetZoomedState() != ZST_NotZoomed) {
		FireOffset = default.FireOffsetZoomed;
	} else {
		FireOffset = default.FireOffset;	
	}
	return super.GetMuzzleLoc();
}

DefaultProperties
{
    FireOffsetZoomed=(X=0,Y=0,Z=0)
    
    NightVisionEffect=PostProcessChain'RenX_AssetBase.PostProcess.PP_NightVisionChain'
    NightVisionAnim=CameraAnim'RenX_AssetBase.PostProcess.C_NightVision'
    
    ZoomOutSound=SoundCue'RX_WP_SniperRifle.Sounds.SC_Scope_ZoomOut'
    ZoomInSound=SoundCue'RX_WP_SniperRifle.Sounds.SC_Scope_ZoomIn'

    bDisplayCrosshair = true
    FadeTime=0.3
    HudTexture=none // Texture2D'RenX_AssetBase.PostProcess.T_SniperScope'
    HudMaterial=Material'RenX_AssetBase.PostProcess.M_SniperScope'

    NightVisionTurnOnSound = SoundCue'RX_WP_SniperRifle.Sounds.SC_NightVision_On'
    NightVisionTurnOffSound = SoundCue'RX_WP_SniperRifle.Sounds.SC_NightVision_Off'
    bPlayZoomSoundWhenShowOverlay = true
    bPlayZoomSoundWhenHideOverlay = false
    LastZoomPlaySoundTimeThreshold = 0.15
    ZoomedRate = 60.0
    ZoomedFOVIncrement = 15
    ZoomedFOVMin = 10.0 // Lower is more zoomed
    ZoomedFOVMax = 25.0 // Higher is less zoomed
    ZoomedTargetFOV = 25.0

    bNightVisionEnabled = false // For maintaining current state due to complexity of finding this out
    bNightVisionEnabledLast = false // For remembering if
}