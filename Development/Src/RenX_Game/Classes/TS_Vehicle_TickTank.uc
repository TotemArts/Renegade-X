/*********************************************************
*
* File: TS_Vehicle_TickTank.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class TS_Vehicle_TickTank extends Rx_Vehicle_Deployable
    placeable;

var const float TakeDamageMultiplier;

state Deployed
{
	simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DmgType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		Super.TakeDamage(Damage * TakeDamageMultiplier, EventInstigator, HitLocation, Momentum, DmgType, HitInfo, DamageCauser);
	}
}

DefaultProperties
{
	TakeDamageMultiplier = 0.65;

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=700
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.1 //0.25
	LookForwardDist=200
    GroundSpeed=300
    MaxSpeed=1000
    LeftStickDirDeadZone=0.1
    TurnTime=18
     ViewPitchMin=-13000
    HornIndex=1
    COMOffset=(x=0.0,y=0.0,z=-60.0)
    bSecondaryFireTogglesFirstPerson=true
	
	SprintTrackTorqueFactorDivident=1.035

    Begin Object Class=SVehicleSimTank Name=SimObject

        bClampedFrictionModel=true

        WheelSuspensionStiffness=100
        WheelSuspensionDamping=3.0
        WheelSuspensionBias=0.05

//        WheelLongExtremumSlip=0
//        WheelLongExtremumValue=20
//        WheelLatExtremumValue=4

        // Longitudinal tire model based on 10% slip ratio peak
        WheelLongExtremumSlip=0.5
        WheelLongExtremumValue=2.0
        WheelLongAsymptoteSlip=2.0
        WheelLongAsymptoteValue=0.6

        // Lateral tire model based on slip angle (radians)
           WheelLatExtremumSlip=0.5 //0.35     // 20 degrees
        WheelLatExtremumValue=4.0
        WheelLatAsymptoteSlip=1.4     // 80 degrees
        WheelLatAsymptoteValue=2.0

        ChassisTorqueScale=0.0
        StopThreshold=20
        EngineDamping=4.0
        InsideTrackTorqueFactor=0.375
        TurnInPlaceThrottle=0.225
        TurnMaxGripReduction=0.995 //0.980
        TurnGripScaleRate=0.8
        MaxEngineTorque=7000
    End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'TS_VH_TickTank.Mesh.SK_VH_TickTank'
        AnimTreeTemplate=AnimTree'TS_VH_TickTank.Anims.AT_VH_TickTank'
		AnimSets(0)=AnimSet'TS_VH_TickTank.Anims.AS_VH_TickTank'
        PhysicsAsset=PhysicsAsset'TS_VH_TickTank.Mesh.SK_VH_TickTank_Physics'
        MorphSets[0]=MorphTargetSet'TS_VH_TickTank.Mesh.MT_VH_TickTank'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_LightTank.Mesh.SK_PTVH_LightTank'

	VehicleIconTexture=Texture2D'TS_VH_TickTank.Materials.T_VehicleIcon_TickTank'
	MinimapIconTexture=Texture2D'TS_VH_TickTank.Materials.T_RadarBlip_TickTank'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'TS_Vehicle_TickTank_Weapon',
                GunSocket=(Fire_Cannon),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(b_Turret_Yaw,b_Turret_Pitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-10),
                CameraOffset=-410,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}
                
    Seats(1)={( GunClass=none,
				TurretVarPrefix="Passenger",
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-10),
                CameraOffset=-410,
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    LeftTeadIndex     = 1
    RightTreadIndex   = 2

    DrivingPhysicalMaterial=PhysicalMaterial'TS_VH_TickTank.Materials.PhysMat_TickTank_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'TS_VH_TickTank.Materials.PhysMat_TickTank'

    RecoilTriggerTag = "MainGun"
    VehicleEffects(0)=(EffectStartTag="MainGun",EffectTemplate=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash',EffectSocket="Fire_Cannon")
	
	VehicleEffects(1)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSteam01)
	VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks01)
	VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks02)
    VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks03)
    VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Tracks',EffectSocket=DamageTSpark01)
    VehicleEffects(6)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire01)
	VehicleEffects(7)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageFire02)

	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
    WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt_Small')
	WheelParticleEffects[2]=(MaterialType=Grass,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt_Small')
    WheelParticleEffects[3]=(MaterialType=Water,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Water')
    WheelParticleEffects[4]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Snow_Small')
	WheelParticleEffects[5]=(MaterialType=Concrete,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
	WheelParticleEffects[6]=(MaterialType=Metal,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
	WheelParticleEffects[7]=(MaterialType=Stone,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Stone')
	WheelParticleEffects[8]=(MaterialType=WhiteSand,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_WhiteSand_Small')
	WheelParticleEffects[9]=(MaterialType=YellowSand,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_YellowSand_Small')
	DefaultWheelPSCTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt_Small'
	
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Huge')
    BigExplosionSocket=VH_Death

	DamageMorphTargets(0)=(InfluenceBone=b_Digger,MorphNodeName=MorphNodeW_Ch_F,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage1))
    DamageMorphTargets(3)=(InfluenceBone=b_Turret_Yaw,MorphNodeName=MorphNodeW_Ch_B,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage4))
    DamageMorphTargets(6)=(InfluenceBone=b_Wheel_L_6_Upper,MorphNodeName=MorphNodeW_Ch_L,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage3))
    DamageMorphTargets(7)=(InfluenceBone=b_Wheel_R_6,MorphNodeName=MorphNodeW_Ch_R,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage2))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=1.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=1.0)
	
	IdleAnim(0)="IdleUnDeployed"
	IdleAnim(1)="IdleUnDeployed"
	DeployAnim(0)="Deploying"
	DeployAnim(1)="UnDeploying"
	

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'TS_VH_TickTank.Sounds.SC_TickTank_Idle'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
   
    EnterVehicleSound=SoundCue'TS_VH_TickTank.Sounds.SC_TickTank_Start'
    ExitVehicleSound=SoundCue'TS_VH_TickTank.Sounds.SC_TickTank_Stop'
	
	DeploySound=none	// SoundCue'TS_VH_TickTank.Sounds.SC_TickTank_Deploying'
	UndeploySound=none	// SoundCue'TS_VH_TickTank.Sounds.SC_TickTank_UnDeploying'


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\


    Begin Object class=Rx_Vehicle_LightTank_Wheel Name=R_Wheel_1
        BoneName="b_Wheel_R_1"
        SkelControlName="Wheel_R_1_Cont"
        Side=SIDE_Right
		WheelRadius=28
		SuspensionTravel=0
    End Object
    Wheels(0)=R_Wheel_1
	
	Begin Object class=Rx_Vehicle_LightTank_Wheel Name=R_Wheel_2
        BoneName="b_Wheel_R_2"
        SkelControlName="Wheel_R_2_Cont"
        Side=SIDE_Right
		WheelRadius=28
		SuspensionTravel=25
    End Object
    Wheels(1)=R_Wheel_2
	
	Begin Object class=Rx_Vehicle_LightTank_Wheel Name=R_Wheel_3
        BoneName="b_Wheel_R_3"
        SkelControlName="Wheel_R_3_Cont"
        Side=SIDE_Right
		WheelRadius=28
		SuspensionTravel=25
    End Object
    Wheels(2)=R_Wheel_3
	
	Begin Object class=Rx_Vehicle_LightTank_Wheel Name=R_Wheel_4
        BoneName="b_Wheel_R_4"
        SkelControlName="Wheel_R_4_Cont"
        Side=SIDE_Right
		WheelRadius=28
		SuspensionTravel=25
    End Object
    Wheels(3)=R_Wheel_4
	
	Begin Object class=Rx_Vehicle_LightTank_Wheel Name=R_Wheel_5
        BoneName="b_Wheel_R_5"
        SkelControlName="Wheel_R_5_Cont"
        Side=SIDE_Right
		WheelRadius=28
		SuspensionTravel=25
    End Object
    Wheels(4)=R_Wheel_5
	
	Begin Object class=Rx_Vehicle_LightTank_Wheel Name=R_Wheel_6
        BoneName="b_Wheel_R_6"
        SkelControlName="Wheel_R_6_Cont"
        Side=SIDE_Right
		WheelRadius=28
		SuspensionTravel=0
    End Object
    Wheels(5)=R_Wheel_6
	
	
	
	
	Begin Object class=Rx_Vehicle_LightTank_Wheel Name=L_Wheel_1
        BoneName="b_Wheel_L_1"
        SkelControlName="Wheel_L_1_Cont"
        Side=SIDE_Left
		WheelRadius=28
		SuspensionTravel=0
    End Object
    Wheels(6)=L_Wheel_1
	
	Begin Object class=Rx_Vehicle_LightTank_Wheel Name=L_Wheel_2
        BoneName="b_Wheel_L_2"
        SkelControlName="Wheel_L_2_Cont"
        Side=SIDE_Left
		WheelRadius=28
		SuspensionTravel=25
    End Object
    Wheels(7)=L_Wheel_2
	
	Begin Object class=Rx_Vehicle_LightTank_Wheel Name=L_Wheel_3
        BoneName="b_Wheel_L_3"
        SkelControlName="Wheel_L_3_Cont"
        Side=SIDE_Left
		WheelRadius=28
		SuspensionTravel=25
    End Object
    Wheels(8)=L_Wheel_3
	
	Begin Object class=Rx_Vehicle_LightTank_Wheel Name=L_Wheel_4
        BoneName="b_Wheel_L_4"
        SkelControlName="Wheel_L_4_Cont"
        Side=SIDE_Left
		WheelRadius=28
		SuspensionTravel=25
    End Object
    Wheels(9)=L_Wheel_4
	
	Begin Object class=Rx_Vehicle_LightTank_Wheel Name=L_Wheel_5
        BoneName="b_Wheel_L_5"
        SkelControlName="Wheel_L_5_Cont"
        Side=SIDE_Left
		WheelRadius=28
		SuspensionTravel=25
    End Object
    Wheels(10)=L_Wheel_5
	
	Begin Object class=Rx_Vehicle_LightTank_Wheel Name=L_Wheel_6
        BoneName="b_Wheel_L_6"
        SkelControlName="Wheel_L_6_Cont"
        Side=SIDE_Left
		WheelRadius=28
		SuspensionTravel=0
    End Object
    Wheels(11)=L_Wheel_6

}
