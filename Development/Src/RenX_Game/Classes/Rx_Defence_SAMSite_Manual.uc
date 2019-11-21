class Rx_Defence_SAMSite_Manual extends Rx_Defence_Emplacement
    placeable;


DefaultProperties
{

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=1000
    bLightArmor=false
    bCollideWorld = false
    Physics=PHYS_None
    
    CameraLag=0.1 //0.2
    LookForwardDist=200
    HornIndex=0
    COMOffset=(x=0.0,y=0.0,z=-55.0)
    
    bUsesBullets = true
    bIgnoreEncroachers=True
    bSeparateTurretFocus=false
    bCanCarryFlag=false
    bCanStrafe=false
    bFollowLookDir=true
    bTurnInPlace=true
    bCanFlip=False
    bHardAttach=true
    
    MaxDesireability=0.8
    MomentumMult=0.7
    
    AIPurpose=AIP_Defensive


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object Name=CollisionCylinder
        CollisionHeight=60.0
        CollisionRadius=260.0
        Translation=(X=0.0,Y=0.0,Z=-0.0)
    End Object
    CylinderComponent=CollisionCylinder    

    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_DEF_SamSite.Mesh.SK_SamSite'
        AnimTreeTemplate=AnimTree'RX_DEF_SamSite.Anims.AT_DEF_SAMSite'
        PhysicsAsset=PhysicsAsset'RX_DEF_SamSite.Mesh.SK_SamSite_Physics'
    End Object

    DrawScale=1.0

	VehicleIconTexture=Texture2D'RX_DEF_SamSite.UI.T_VehicleIcon_SAMSite'
	MinimapIconTexture=Texture2D'RX_DEF_SamSite.UI.T_MinimapIcon_SAMSite'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Defence_SAMSite_Weapon',
                GunSocket=(Fire_01,Fire_02,Fire_03,Fire_04,Fire_05,Fire_06),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(Turret_Yaw,Turret_Pitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-75),
                CameraOffset=-400,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    BurnOutMaterial[0]=MaterialInstanceConstant'RX_DEF_SamSite.Materials.MI_SamSite_Destroyed'
    BurnOutMaterial[1]=MaterialInstanceConstant'RX_DEF_SamSite.Materials.MI_SamSite_Destroyed'

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_Humvee.Materials.PhysMat_HumveeDriving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_Humvee.Materials.PhysMat_Humvee'

    RecoilTriggerTag = "MainGun"
    VehicleEffects(0)=(EffectStartTag=TurretFire01,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire_01)
    VehicleEffects(1)=(EffectStartTag=TurretFire02,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire_02)
    VehicleEffects(2)=(EffectStartTag=TurretFire03,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire_03)
    VehicleEffects(3)=(EffectStartTag=TurretFire04,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire_04)
    VehicleEffects(4)=(EffectStartTag=TurretFire05,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire_05)
    VehicleEffects(5)=(EffectStartTag=TurretFire06,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=Fire_06)
    VehicleEffects(6)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke01)

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Huge')
    BigExplosionSocket=VH_Death

}