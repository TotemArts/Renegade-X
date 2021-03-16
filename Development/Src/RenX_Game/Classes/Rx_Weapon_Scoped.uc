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
var bool  bCanUseZeroSpread; //Can we use zero spread now? 
var PostProcessChain NightVisionEffect;
var CameraAnim NightVisionAnim;
var() vector	FireOffsetZoomed;
var() vector CameraOffsetZoomed;
var() bool bInstantZoom;

// canvas texture editor
var float ZoomRecoilValue;
var int ZoomRecoilStatus; // 0 - Normal, 1 - Recoil In, 2 - Recoil Out

var float ZoomRecoilMaxIntensity;
var float ZoomRecoilRecoveryRate;
var float ZoomRecoilRate;

var() Array<float> MovingAndScopedAddedSpread;

var bool bIsScoping;

/** LastZoomPlaySoundTimeThreshold is used to avoid spamming of zoom sounds when fast zooming */
var float LastZoomPlaySoundTime, LastZoomPlaySoundTimeThreshold;

/** Played when activate/deactivate night vision */
var SoundCue NightVisionTurnOnSound, NightVisionTurnOffSound; 

simulated function DrawZoomedOverlay( HUD H )
{
    local float ScaleX, ScaleY, StartX, StartY;
	local float HMScale; 
    bDisplayCrosshair = false;

    ScaleY = H.Canvas.SizeY/768.0 + (ZoomRecoilValue/100.f) * ZoomRecoilMaxIntensity;
    ScaleX = ScaleY;
    StartX = (H.Canvas.SizeX - (1024 * ScaleX)) / 2;
    StartY = (H.Canvas.SizeY - (768 * ScaleY)) / 2;
	HMScale= 	Fmax(H.Canvas.SizeX/1920.0, 0.73); 


    // Draw sidebars
    H.Canvas.SetDrawColor(0,0,0);
    H.Canvas.SetPos(0,0);
    H.Canvas.DrawRect(StartX, H.Canvas.sizeY);
    H.Canvas.SetPos(H.Canvas.SizeX - StartX,0);
    H.Canvas.DrawRect(StartX, H.Canvas.sizeY);

    // Draw the crosshair
    if (HudMaterial != none)
    {
        H.Canvas.SetPos(StartX, StartY);
        H.Canvas.DrawMaterialTile(HudMaterial, 1024 * ScaleX, 1024 * ScaleY);
    }
    else 
    {
        // For backwards compatibility
        H.Canvas.SetPos(StartX, StartY);
        H.Canvas.DrawTile(HudTexture, 1024 * ScaleX, 768 * ScaleY, 0, 0, 1024, 768);
    }
    
    DrawHitIndicator(H,H.Canvas.ClipX * 0.5 - (default.CrosshairWidth * HMScale * 0.5),H.Canvas.ClipY * 0.5 - (default.CrosshairHeight * HMScale * 0.5));
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

function byte BestMode()
{
        return 0;
}

/*
 * Initializes and updates the zoom FOV
 */
simulated function StartZoom(UTPlayerController PC)
{
    if (GetZoomedState() != ZST_NotZoomed) // Already zoomed, just update FOV
    {
        //If we zoom, start walking
        Rx_Pawn(Instigator).StartWalking();
		Rx_Pawn(Instigator).WeaponFired(self, false);
        
        if(PC != None)    
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
            if(PC != None)
                Rx_Controller(PC).SetOurCameraMode(FirstPerson);
        }

        NormalViewOffset = default.PlayerViewOffset;

        bDisplayCrosshair = false;


        //Start Walking while zoomed
        Rx_Pawn(Instigator).StartWalking();

        if(!bInstantZoom)
        {
            ClearTimer('MoveWeaponOutOfIronSight');
            SetTimer((0.005 / 100 * AimRate),true,'MoveWeaponToIronSight');  
        } 
        else
            StopZoom();
    }
}
/*
simulated function SetZeroSpreadTimer()
{
	bCanUseZeroSpread = true ; 
}
*/
simulated function StopZoom()
{
    local UTPlayerController PC;

    Super.StopZoom();
	
    if(PlayerViewOffset.y >= IronsightViewOffset.y && !bIsScoping)
    {
        bIsScoping = true;
        PC = UTPlayerController(Instigator.Controller);

        // Set manually, because otherwise the scope gets stuck on the wrong FOV when you bring it up
        if(PC != None)
        {
            PC.SetFOV( ZoomedTargetFOV ); 
            PC.StartZoom(ZoomedTargetFOV, ZoomedRate);
        }    

        if (ZoomInSound != none && bPlayZoomSoundWhenShowOverlay)
            PlaySound(ZoomInSound, true);

        if (bNightVisionEnabledLast)
            ToggleNightVision();

        ChangeVisibility(false); 
 //       SetTimer(0.1,false,'SetZeroSpreadTimer');   
        bCanUseZeroSpread = true; 
    }
}

/*
 * Unzooms and cleans up related stuff
 */
simulated function EndZoom(UTPlayerController PC)
{
    bDisplayCrosshair = true;
    


    if(bIsScoping)
    {
        bNightVisionEnabledLast = bNightVisionEnabled;
        ToggleNightVision(true);
   
        if (ZoomOutSound != none && bPlayZoomSoundWhenHideOverlay)
            PlaySound(ZoomOutSound, true);

        //Hack to put hand back on gun after zooming out. Need real zoom out animations.
        PlayWeaponAnimation(WeaponFireAnim[0], 0.01,,BaseSkelComponent);
        bIsScoping = false;
    }
    
    //Stop walking
    if(PC != None)
        PC.EndZoom();

    ClearTimer('MoveWeaponToIronSight');
    SetTimer((0.005 / 100 * AimRate),true,'MoveWeaponOutOfIronSight');

    
    if (Instigator.IsFirstPerson() == true)
    {
        if (WasThirdPerson == true && PC != None)
        {
			Rx_Controller(PC).SetOurCameraMode(ThirdPerson);
        }
        else
        {
            ChangeVisibility(true);
        }
    }
	
	  Rx_Pawn(Instigator).StopWalking();
	  Rx_Pawn(Instigator).WeaponStoppedFiring(self, false);
//	  ClearTimer('SetZeroSpreadTimer');
	  bCanUseZeroSpread = false; 
	
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
//	ClearTimer('SetZeroSpreadTimer');
	bCanUseZeroSpread = false;
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

    if (!Rx_MapInfo(WorldInfo.GetMapInfo()).bNightVisionEnabled)
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

simulated event vector GetMuzzleLoc()
{
	if (GetZoomedState() != ZST_NotZoomed) {
		FireOffset = default.FireOffsetZoomed;
	} else {
		FireOffset = default.FireOffset;	
	}
	return super.GetMuzzleLoc();
}

//EDIT for zero spread timer 

simulated function rotator AddSpread(rotator BaseAim)
{
    local vector X, Y, Z;
    local rotator ret;
    local float RecoilSpreadTemp, RandY, RandZ;

    if(IronSightAndScopedSpread.Length > 0 && (bIronsightActivated || GetZoomedState() != ZST_NotZoomed) && bCanUseZeroSpread) 
    {
        CurrentSpread = IronSightAndScopedSpread[CurrentFireMode];

        if(VSize(Instigator.Velocity) >= 20) //This if and the code in it is the only thing added. Deadeye is about 80 when scoped and moving, gives a little wiggle room in case you are moving very slowly from just having stopped or something.
        {
            CurrentSpread += MovingAndScopedAddedSpread[CurrentFireMode];
        }
    } else 
    {
        CurrentSpread = Spread[CurrentFireMode];
    }
    if (CurrentSpread == 0 )
    {
        return BaseAim;
    }
    else
    {
        if(RecoilSpreadIncreasePerShot == 0.0 && Spread[CurrentFireMode] == 0.0 && Rx_Bot(Pawn(owner).controller) == None) 
        {
            ret = BaseAim;
        } 
        else 
        {
            GetAxes(BaseAim, X, Y, Z);
            RandY = FRand() - 0.5;
            RandZ = Sqrt(0.5 - Square(RandY)) * (FRand() - 0.5);
            CurrentSpread += RecoilSpread;
            ret = rotator(X + RandY * CurrentSpread * Y + RandZ * CurrentSpread * Z);
        }
        
        if(RecoilSpreadDecreaseDelay != default.RecoilSpreadDecreaseDelay && RecoilSpreadIncreasePerShot != 0.0) {
            RecoilSpreadTemp = RecoilSpread;
            RecoilSpread += RecoilSpreadIncreasePerShot;
            if(CurrentSpread + RecoilSpread >= MaxSpread) {
                RecoilSpread = RecoilSpreadTemp;
            }
        }
        return ret;
    }
}

simulated function WeaponCalcCamera(float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot)
{
    if(GetZoomedState() != ZST_NotZoomed)
       out_CamLoc += CameraOffsetZoomed;
}

simulated function vector InstantFireStartTrace()
{
    local vector R;

    R = super.InstantFireStartTrace();

    if(GetZoomedState() != ZST_NotZoomed)
       R += CameraOffsetZoomed;

    return R;

}

simulated function FireAmmunition()
{
    super.FireAmmunition();

    if(WorldInfo.NetMode == NM_DedicatedServer || Instigator.Controller == None || !Instigator.Controller.IsLocalPlayerController())
        return;

    if(ZoomRecoilStatus == 2)
    {
        ZoomRecoilStatus = 1;
        if(ZoomRecoilValue > 50.f)
        {
            ZoomRecoilValue = 50.f;
        }
    }
    else if(ZoomRecoilStatus == 1)
    {
        if(ZoomRecoilValue > 50.f)
        {
            ZoomRecoilValue = 50.f;
        }
    }
    else
    {
        ZoomRecoilStatus = 1;
    }
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
    super.ProcessViewRotation(DeltaTime, out_ViewRotation, out_DeltaRot);

    if(ZoomRecoilStatus == 1)
    {
        ZoomRecoilValue = FInterpTo(ZoomRecoilValue,100.f,DeltaTime,ZoomRecoilRate);
        if(ZoomRecoilValue >= 100.f)
        {
            ZoomRecoilStatus = 2;
            ZoomRecoilValue = 100.f;
        }
    }
    else if(ZoomRecoilStatus == 2)
    {
        ZoomRecoilValue = FInterpTo(ZoomRecoilValue,0.f,DeltaTime,ZoomRecoilRecoveryRate);
        if(ZoomRecoilValue <= 0.f)
        {
            ZoomRecoilStatus = 0;
            ZoomRecoilValue = 0.f;
        }
    }
//    `log(Self@"ZoomRecoilValue :"@ ZoomRecoilValue);
}

DefaultProperties
{
    FireOffsetZoomed=(X=0,Y=0,Z=0)
    CameraOffsetZoomed = (X=0, Y=0, Z=-10)

    MovingAndScopedAddedSpread(0)=0.002
    
    NightVisionEffect=PostProcessChain'RenX_AssetBase.PostProcess.PP_NightVisionChain'
    NightVisionAnim=CameraAnim'RenX_AssetBase.PostProcess.C_NightVision'
    
    ZoomOutSound=SoundCue'RX_WP_SniperRifle.Sounds.SC_Scope_ZoomOut'
    ZoomInSound=SoundCue'RX_WP_SniperRifle.Sounds.SC_Scope_ZoomIn'

    bDisplayCrosshair = true
    FadeTime=0.3
    HudTexture=none // Texture2D'RenX_AssetBase.PostProcess.T_SniperScope'
    HudMaterial=Material'RenX_AssetBase.PostProcess.M_SniperScope'

    AimRate = 45.f

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

    ZoomRecoilMaxIntensity = 0.25
    ZoomRecoilRecoveryRate = 10
    ZoomRecoilRate = 75


    bNightVisionEnabled = false // For maintaining current state due to complexity of finding this out
    bNightVisionEnabledLast = false // For remembering if
}