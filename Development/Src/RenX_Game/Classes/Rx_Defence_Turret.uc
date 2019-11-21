class Rx_Defence_Turret extends Rx_Defence
    placeable;

DefaultProperties
{
	TeamID=1
//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=1250 //1000
    bLightArmor=false
    bCollideWorld = false
    Physics=PHYS_None
    
    CameraLag=0.1 //0.2
    LookForwardDist=200
    HornIndex=0
    COMOffset=(x=0.0,y=0.0,z=-55.0)
    
	PeripheralVision=-1.0
    
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
    End Object
    CylinderComponent=CollisionCylinder    

    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_DEF_Turret.Mesh.SK_DEF_Turret'
        AnimTreeTemplate=AnimTree'RX_DEF_Turret.Anims.AT_DEF_Turret'
        PhysicsAsset=PhysicsAsset'RX_DEF_Turret.Mesh.SK_DEF_Turret_Physics'
		MorphSets[0]=MorphTargetSet'RX_DEF_Turret.Mesh.MT_DEF_Turret'
    End Object

    DrawScale=1.0

	VehicleIconTexture=Texture2D'RX_DEF_Turret.UI.T_VehicleIcon_Turret'
	MinimapIconTexture=Texture2D'RX_DEF_Turret.UI.T_MinimapIcon_Turret'


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Defence_Turret_Weapon',
                GunSocket=(MuzzleFlashSocket),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(TurretYaw,TurretPitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-100),
                CameraOffset=-300,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    BurnOutMaterial[0]=MaterialInstanceConstant'RX_DEF_Turret.Materials.MI_Turret_Destroyed'
    BurnOutMaterial[1]=MaterialInstanceConstant'RX_DEF_Turret.Materials.MI_Turret_Destroyed'

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_Humvee.Materials.PhysMat_HumveeDriving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_Humvee.Materials.PhysMat_Humvee'

    RecoilTriggerTag = "MainGun"
    VehicleEffects(0)=(EffectStartTag="MainGun",EffectTemplate=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash',EffectSocket="MuzzleFlashSocket")
    VehicleEffects(1)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire_Thick',EffectSocket=DamageSmoke01)

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Huge')
    BigExplosionSocket=VH_Death
	
	DamageMorphTargets(0)=(InfluenceBone=TurretPitch,MorphNodeName=MorphNodeW_F,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=Hatch,MorphNodeName=MorphNodeW_B,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage2))
    DamageMorphTargets(2)=(InfluenceBone=DP_ReactiveArmour_9,MorphNodeName=MorphNodeW_R,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage3))
    DamageMorphTargets(3)=(InfluenceBone=DP_ReactiveArmour_1,MorphNodeName=MorphNodeW_L,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage4))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=1.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.1)

}