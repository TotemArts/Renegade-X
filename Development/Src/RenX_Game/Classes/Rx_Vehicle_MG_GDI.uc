
class Rx_Vehicle_MG_GDI extends Rx_Vehicle_Attacheable
    placeable;

    
    
/** Firing sounds */
var() AudioComponent FiringAmbient;
var() SoundCue FiringStopSound;


simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
    // Trigger any vehicle Firing Effects
    VehicleEvent('MainGun');
    
    if (!FiringAmbient.bWasPlaying)
    {
        FiringAmbient.Play();
    }
}

simulated function VehicleWeaponStoppedFiring(bool bViaReplication, int SeatIndex)
{
    // Trigger any vehicle Firing Effects
    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        if (Role == ROLE_Authority || bViaReplication || WorldInfo.NetMode == NM_Client)
        {
            VehicleEvent('STOP_MainGun');
        }
    }

    PlaySound(FiringStopSound, TRUE, FALSE, FALSE, Location, FALSE);
    FiringAmbient.Stop();
}

   

DefaultProperties
{


//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=500
    bLightArmor=False
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bSeparateTurretFocus=True
    CameraLag=0.05 		// 0.1
	LookForwardDist=200
    bHasHandbrake=true
    GroundSpeed=0
    AirSpeed=0
    MaxSpeed=0
    HornIndex=1
    COMOffset=(x=10.0,y=0.0,z=0.0)
    bUsesBullets = true
    bOkAgainstBuildings=false
    bSecondaryFireTogglesFirstPerson=true
	
	CustomGravityScaling=1.0
	
	Physics=PHYS_None

	

//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_Humvee.Mesh.SK_Turret_MG_GDI'
        AnimTreeTemplate=AnimTree'RX_VH_Humvee.Anims.AT_Turret_MG_GDI'
        PhysicsAsset=PhysicsAsset'RX_VH_Humvee.Mesh.SK_Turret_MG_GDI_Physics'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_Humvee.Mesh.SK_Turret_MG_GDI'

	VehicleIconTexture=Texture2D'RX_DEF_GuardTower.UI.T_VehicleIcon_GuardTower'
	MinimapIconTexture=Texture2D'RX_DEF_GuardTower.UI.T_MinimapIcon_GuardTower'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Vehicle_Humvee_Weapon',
                GunSocket=(FireSocket),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(b_Turret_Yaw,b_Turret_PitchPitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-40),
                CameraOffset=-350,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_AutoRifle_MuzzleFlash'
                )}

//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_Humvee.Materials.PhysMat_HumveeDriving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_Humvee.Materials.PhysMat_Humvee'

    RecoilTriggerTag = "MainGun"
	VehicleEffects(0)=(EffectStartTag="MainGun",EffectEndTag="STOP_MainGun",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.P_MuzzleFlash_50Cal_Looping',EffectSocket="Fire01")
	VehicleEffects(1)=(EffectStartTag="MainGun",EffectEndTag="STOP_MainGun",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.P_ShellCasing_Looping',EffectSocket="ShellCasingSocket")

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\
 
    Begin Object Class=AudioComponent name=FiringmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire_Looping'
    End Object
    FiringAmbient=FiringmbientSoundComponent
    Components.Add(FiringmbientSoundComponent)
    
    FiringStopSound=SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire_Stop'
}