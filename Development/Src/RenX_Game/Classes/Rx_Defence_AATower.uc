class Rx_Defence_AATower extends Rx_Defence
    placeable;

var UTPawn P;

function Initialize() 
{
	local vector tv;

	SetTeamNum(TeamID);
	ai = Spawn(DefenceControllerClass,self);
	ai.SetOwner(None);  // Must set ai owner back to None, because when the ai possesses this actor, it calls SetOwner - and it would fail due to Onwer loop if we still owned it.
	bAIControl = true;

	/*    Spawning a UTPawn with a UTVehicle_Nod_Turret_Controller
	*     to make it the 'Driver' of the Turret.
	*     Spawning and entering had to be delayed a bit to make it work.
	*/
	tv = Location;
	tv.z += 50;
	tv.x += 50;
	P = Spawn(class'UTPawn',,,tv,,,true);
	P.bIsInvisible=true;
	ai.Possess(P, true);
	setTimer(0.1,false,'enter');
}

function enter(){
    if(Driver == None)
        DriverEnter(P);
    ai.Pawn.PeripheralVision = -1.0;
}


DefaultProperties
{
	TeamID=0;
	DefenceControllerClass=class'Rx_Defence_SAMSiteController'

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=1000
    bLightArmor=false
    bCollideWorld = false
    Physics=PHYS_None
    
    CameraLag=0.1 //0.2
    LookForwardDist=200
    HornIndex=1
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
	
	DeadVehicleLifeSpan=0.0
    
    AIPurpose=AIP_Defensive


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object Name=CollisionCylinder
        CollisionHeight=60.0
        CollisionRadius=260.0
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object
    CylinderComponent=CollisionCylinder    

    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_DEF_GuardTower.Mesh.SK_DEF_AATower'
        AnimTreeTemplate=AnimTree'RX_DEF_GuardTower.Anims.AT_DEF_AATower'
        PhysicsAsset=PhysicsAsset'RX_DEF_GuardTower.Mesh.SK_DEF_AATower_Physics'
		MorphSets[0]=MorphTargetSet'RX_DEF_GuardTower.Mesh.MT_DEF_AATower'
    End Object

    DrawScale=1.0


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Defence_AATower_Weapon',
                GunSocket=(MuzzleFlashSocket_L,MuzzleFlashSocket_R),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(GunYaw,GunPitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-50),
                CameraOffset=-600,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


//    BurnOutMaterial[0]=MaterialInstanceConstant'RX_DEF_GuardTower.Materials.MI_VH_GuardTower_BO'
//    BurnOutMaterial[1]=MaterialInstanceConstant'RX_DEF_GuardTower.Materials.MI_VH_GuardTower_BO'

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_Humvee.Materials.PhysMat_HumveeDriving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_Humvee.Materials.PhysMat_Humvee'

    RecoilTriggerTag = "MainGun"
    VehicleEffects(0)=(EffectStartTag=TurretFireR,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=MuzzleFlashSocket_L)
    VehicleEffects(1)=(EffectStartTag=TurretFireL,EffectTemplate=ParticleSystem'RX_VH_MRLS.Effects.Muzzle_Flash',EffectSocket=MuzzleFlashSocket_R)
    VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire_Thick',EffectSocket=DamageSmoke01)

    WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt')
    WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt')
    WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Scorpion_Water_Splash')
    WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Scorpion_Wheel_Snow')

    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Huge')
    BigExplosionSocket=VH_Death
	
	DamageMorphTargets(0)=(InfluenceBone=MT_FL,MorphNodeName=MorphNodeW_FL,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_FR,MorphNodeName=MorphNodeW_FR,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage2))
    DamageMorphTargets(2)=(InfluenceBone=MT_BL,MorphNodeName=MorphNodeW_BL,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage3))
    DamageMorphTargets(3)=(InfluenceBone=MT_BR,MorphNodeName=MorphNodeW_BR,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage4))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.2)

}