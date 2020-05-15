/*********************************************************
*
* File: Rx_Vehicle_Harvester.uc
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
class Rx_Vehicle_Harvester extends Rx_Vehicle_Treaded
    abstract;
    
var UTPawn                          DummyDriver; 
var byte 							TeamNum;  
var float 							LastAttackBroadCastTime;
var array<SoundCue> 			    AttackedEvaSounds;
var array<SoundCue> 			    DestroyedEvaSounds;
var repnotify bool 					bPlayOpeningAnim;
var repnotify bool 					bPlayClosingAnim;
var repnotify bool 					bPlayHarvestingAnim;
var bool 							bTurningToDock;
var string							FriendlyStateName; 
var class<Rx_Message_Harvester>     HarvyMessageClass;

var SkeletalMeshComponent AntennaMesh;

/** The Cantilever Beam that is the Antenna itself*/
var UTSkelControl_CantileverBeam AntennaBeamControl;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTeamNum(TeamNum);
	//SetTimer(5.0,false,'gg');
	SetTimer(2.0, false, 'harvInit');
	Mesh.PlayAnim('CloseIdle');

	Mesh.AttachComponentToSocket(AntennaMesh,'AntennaSocket');

	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMesh.FindSkelControl('Beam'));

	if(AntennaBeamControl != none)
	{
		AntennaBeamControl.EntireBeamVelocity = GetVelocity;
	}
}

replication
{
	if ( bNetDirty && ROLE == ROLE_AUTHORITY)
		bPlayOpeningAnim, bPlayClosingAnim, bPlayHarvestingAnim, FriendlyStateName; 
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'bPlayOpeningAnim' ) {
		if(bPlayOpeningAnim)
			Mesh.PlayAnim('Opening');
	} else if( VarName == 'bPlayClosingAnim' ) {
		if(bPlayClosingAnim)
			Mesh.PlayAnim('Opening',,,,,true);;
	} else if( VarName == 'bPlayHarvestingAnim' ) {
		if(bPlayHarvestingAnim)
			Mesh.PlayAnim('Harvesting',,true);
		else
			Mesh.StopAnim();
	} else {
		super.ReplicatedEvent(VarName);
	}
}


/** For Antenna delegate purposes (let's turret motion be more dramatic)*/
function vector GetVelocity()
{
	return Velocity;
}

function harvInit() {

	local vector tv;

	if(Controller != none) {
		return;
	}
	tv = location;
	tv.z += 60;
	tv.x += 50;

	SetTeamNum(TeamNum);
	DummyDriver = Spawn(class'UTPawn',,,tv,,,true);

	if(Rx_MapInfo(WorldInfo.GetMapInfo()).MapBotType == navmesh)
		Controller = Spawn(class'Rx_Vehicle_HarvesterController_Mesh',self,,tv,,,true);
	else
		Controller = Spawn(class'Rx_Vehicle_HarvesterController_Waypoints',self,,tv,,,true);


	Controller.SetOwner(None);
	AIController(Controller).SetTeam(TeamNum);
	Controller.Possess(DummyDriver,true);
	Rx_Vehicle_HarvesterController(Controller).harv_vehicle = self;

	SetTimer(0.1f, false, 'Start');
	SetTimer(1.0, true, 'regenerateHealth');
	if(Rx_Game(WorldInfo.Game) != None)
	{
		Rx_Game(WorldInfo.Game).ReassignHarvester(Self);
	}
	
}

function PancakeOther(Pawn Other)
{
    if(DummyDriver == None || Other != DummyDriver) 
    {
    	super.PancakeOther(Other);
	}
}

function Start()
{
   DriverEnter(DummyDriver);
   Controller.GotoState('MovingToTib');
}


simulated function bool DriverEnter(Pawn p) {
	if(p.IsA('Rx_Pawn')) {
		return false;
	} else {
		return super.DriverEnter(p);	
	}
}

event bool ContinueOnFoot()
{
	return false; // overriden to prevent AI from leaving the harvester
}

/*
 * Sets Teammaterials. The Code to change Teammaterials was removed in super.TeamChanged() but it makes sense
 * for the Harvester
 */
simulated function TeamChanged() {
	
	local MaterialInterface NewMaterial;	

	super.TeamChanged();

	if (TeamMaterials.length > 0 && WorldInfo.NetMode != NM_DedicatedServer)
	{
		NewMaterial = TeamMaterials[Team];
		if (NewMaterial != None)
		{
			if (DamageMaterialInstance[0] != None)
			{
				DamageMaterialInstance[0].SetParent(NewMaterial);
			}
			else
			{
				Mesh.SetMaterial(0, NewMaterial);
			}
		}
		UpdateDamageMaterial();
	}
}

event RanInto( Actor Other )
{
	local float Speed;
	local Vector Momentum;
	local class<UDKEmitCameraEffect> CameraEffect;
	local bool bEnemyIsInfrontOfMe;		
	
	if(Other == DummyDriver)
		return;
	
	if( Pawn(Other) == none || Vehicle(Other) != none || Other == Instigator || Other.Role != ROLE_Authority || WorldInfo.GRI.OnSameTeam(self, Other) )
		return;
	
	Speed = VSizeSq(Velocity);
	if (Speed > Square(MinRunOverSpeed))
	{
		bEnemyIsInfrontOfMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(Location,rotation,Other.location) > 220;
		if(!bEnemyIsInfrontOfMe)
			return;
		
		Momentum = Velocity * 0.25 * Pawn(Other).Mass;
		if ( RanOverSound != None )
			PlaySound(RanOverSound);

		Other.TakeDamage(Pawn(Other).HealthMax, GetCollisionDamageInstigator(), Other.Location, Momentum, RanOverDamageType);

		if (Pawn(Other).Health <= 0 && UTPlayerController(Controller) != none)
		{
			CameraEffect = RanOverDamageType.static.GetDeathCameraEffectInstigator(UTPawn(Other));
			if (CameraEffect != None)
			{
				UTPlayerController(Controller).ClientSpawnCameraEffect(CameraEffect);
			}
		}
	}

}

simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{

	super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	if (EventInstigator != None && WorldInfo.TimeSeconds >= LastAttackBroadCastTime + 30.f && EventInstigator.GetTeamNum() != GetTeamNum())
	{
		BroadcastAttack();
		LastAttackBroadCastTime = WorldInfo.TimeSeconds;
	}
	
	if(Health <= 0 && EventInstigator.PlayerReplicationInfo != none)
		Rx_PRI(EventInstigator.PlayerReplicationInfo).AddVehicleKill();
	
}

function BroadcastAttack()
{
	BroadcastLocalizedMessage(HarvyMessageClass,0,self.PlayerReplicationInfo);
}

function BroadcastDestroyed()
{
	local Rx_Controller PC; 
	
	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
		{
			if (PC.GetTeamNum() == GetTeamNum())
			{
				PC.CTextMessage(Caps("Harvester Lost"),'Red',180, 1);
			}
			else
			{
				PC.CTextMessage(Caps("Enemy Harvester Destroyed"),'Green',180,1);
				//If we were actually being hit by the enemy team, give the team bonus 
				if(DamagingParties.length > 0)
					PC.DisseminateVPString("[Team Harvester Kill Bonus]&" $ class'Rx_VeterancyModifiers'.default.Ev_HarvesterDestroyed $ "&");
			}
		}

	BroadcastLocalizedMessage(HarvyMessageClass,1,self.PlayerReplicationInfo);
}

simulated function Destroyed()
{
	if(Rx_Game(WorldInfo.Game) != None)
		Rx_Game(WorldInfo.Game).GetVehicleManager().HarvDestroyed(TeamNum,true);
	
	super.Destroyed();
	
}

simulated state DyingVehicle
{
	simulated function BeginState(name PreviousStateName)
	{
		BroadcastDestroyed();
		super.BeginState(PreviousStateName);
	}
}

event bool DriverLeave(bool bForceLeave)
{
	local bool bLeft;

	bLeft = Super.DriverLeave(bForceLeave);

	if(bLeft && Health > 0 && !CanUnmanHarvy())
	{
		BlowUpVehicle();
	}

	return bLeft;
}

function bool CanUnmanHarvy() // in case anyone wants to mod the harvy to be able to be unmanned
{
	return false;
}

simulated function byte GetTeamNum() {
	return TeamNum;
}

function string BuildDeathVPString(Controller Killer, class<DamageType> DamageType)
{
	if(Killer == none || LastTeamToUse == Killer.GetTeamNum() ) return ""; //Meh, you get nothing
		
		return "[Harvester Kill]&+" $ default.VPReward[VRank] $ "&" ;
	
}

//A much lighter variant of the VPString builder, used to calculate assists (Which only add in negative modifiers for in-base and higher VRank)
function int BuildAssistVPString(Controller Killer) 
{
	//No Modifiers for the Harvester
	return 0; 	
}

simulated function string GetFriendlyStateName()  //State specific
{
	return FriendlyStateName; 
}

function SetFriendlyStateName(string SetToString)  //State specific
{
	FriendlyStateName = SetToString; 
}

simulated function bool ForceVisible()
{
	return PlayerReplicationInfo == none || Rx_DefencePRI(PlayerReplicationInfo).bSpotted;  
}
DefaultProperties
{

    Begin Object Name=CollisionCylinder
    CollisionHeight=100.0
    CollisionRadius=240.0
    Translation=(X=0.0,Y=0.0,Z=64.0)
    End Object

    HarvyMessageClass = class'Rx_Message_Harvester'

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\
	
	MinRunOverSpeed 	= 100.0f
	
	bBlocksNavigation = true	

	Health=1000//1000
    MaxDesireability=0
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.15 //0.4
	LookForwardDist=300
    GroundSpeed=300
    MaxSpeed=1500
    LeftStickDirDeadZone=0.1
    TurnTime=18
     ViewPitchMin=-13000
    HornIndex=0
    COMOffset=(x=-19.0,y=0.0,z=-40.0)
	bAlwaysRegenerate = true 
	
	RadarVisibility = 0 //start invisible for a moment 
	
	/************************/
	/*Veterancy Multipliers*/
	/***********************/



	//You think I won't find a way to make heroic harvesters? Pfffft, watch me D= 
	Vet_HealthMod(0)=1 //1000
	Vet_HealthMod(1)=1.25 //1250
	Vet_HealthMod(2)=1.5 //1500
	Vet_HealthMod(3)=2.0 //2000
	
	Vet_SprintSpeedMod(0)=1
	Vet_SprintSpeedMod(1)=1.05
	Vet_SprintSpeedMod(2)=1.10
	Vet_SprintSpeedMod(3)=1.20
	
	// +X as opposed to *X
	Vet_SprintTTFD(0)=0
	Vet_SprintTTFD(1)=0.05
	Vet_SprintTTFD(2)=0.10
	Vet_SprintTTFD(3)=0.20

	//VP Given on death (by VRank)
		VPReward(0) = 6 
		VPReward(1) = 8
		VPReward(2) = 10 
		VPReward(3) = 14 

		VPCost(0) = 10
		VPCost(1) = 20
		VPCost(2) = 30
	/**********************/

	AttackedEvaSounds(0) = SoundCue'RX_EVA_VoiceClips.gdi_EVA.S_EVA_GDI_GDIHarvester_UnderAttack_Cue' 
	AttackedEvaSounds(1) = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDIHarvester_UnderAttack_Cue'
	AttackedEvaSounds(2) = SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodHarvester_UnderAttack_Cue'
	AttackedEvaSounds(3) = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodHarvester_UnderAttack_Cue'
	
	

	DestroyedEvaSounds(0) = SoundCue'RX_EVA_VoiceClips.gdi_EVA.S_EVA_GDI_GDIHarvester_Destroyed_Cue'
	DestroyedEvaSounds(1) = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDIHarvester_Destroyed_Cue' 
	DestroyedEvaSounds(2) = SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodHarvester_Destroyed_Cue'
	DestroyedEvaSounds(3) = SoundCue'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodHarvester_Destroyed_Cue' 
	 
	
    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_Harvester.Mesh.SK_VH_Harvester'
        AnimTreeTemplate=AnimTree'RX_VH_Harvester.Anims.AT_VH_Harvester'
        PhysicsAsset=PhysicsAsset'RX_VH_Harvester.Mesh.SK_VH_Harvester_Physics'
		MorphSets[0]=MorphTargetSet'RX_VH_Harvester.Mesh.MT_VH_Harvester'
        AnimSets.Add(AnimSet'RX_VH_Harvester.Anims.AS_VH_Harvester')
    End Object	
    
    SkeletalMeshForPT=SkeletalMesh'RX_VH_Harvester.Mesh.SK_VH_Harvester'
	
	Begin Object Class=SkeletalMeshComponent Name=SAntennaMesh
		SkeletalMesh=SkeletalMesh'RX_VH_MRLS.Mesh.SK_Antenna'
		AnimTreeTemplate=AnimTree'RX_VH_MRLS.Anims.AT_Antenna'
		LightEnvironment = MyLightEnvironment
	End Object
	AntennaMesh=SAntennaMesh

    Begin Object Class=SVehicleSimTank Name=SimObject

        bClampedFrictionModel=true

        WheelSuspensionStiffness=200
        WheelSuspensionDamping=50.0
        WheelSuspensionBias=0.125

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
        EngineDamping=4
        InsideTrackTorqueFactor=0.3
        TurnInPlaceThrottle=0.25 //0.3
        TurnMaxGripReduction=0.99 //0.980
        TurnGripScaleRate=0.8
        MaxEngineTorque=1700
		EngineBrakeFactor=10.0;
        End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={( GunClass=none,
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-10),
				SeatBone=Base,
				SeatSocket=VH_Death,
                CameraOffset=-600,
                )}
                
	VehicleIconTexture=Texture2D'RX_VH_Harvester.UI.T_VehicleIcon_Harvester'
	MinimapIconTexture=Texture2D'RX_VH_Harvester.UI.T_MinimapIcon_Harvester'
            
//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_Harvester.Materials.PhysMat_Harvester_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_Harvester.Materials.PhysMat_Harvester'

    VehicleEffects(0)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.GenericExhaust',EffectSocket=Exhaust_01)
    VehicleEffects(1)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Humvee.Effects.GenericExhaust',EffectSocket=Exhaust_02)
    VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke01)
    VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke02)
    VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks01)
    VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Random',EffectSocket=DamageSparks02)
    VehicleEffects(6)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Tracks',EffectSocket=DamageTSparks01)
    VehicleEffects(7)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Sparks_Tracks',EffectSocket=DamageTSparks02)
    VehicleEffects(8)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire_Thick',EffectSocket=DamageFire01)
    VehicleEffects(9)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire_Thick',EffectSocket=DamageFire02)

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
	
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_VH_Harvester.Effect.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death
	
	DamageMorphTargets(0)=(InfluenceBone=MT_F,MorphNodeName=MorphNodeW_F,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_FL,MorphNodeName=MorphNodeW_FL,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage2))
    DamageMorphTargets(2)=(InfluenceBone=MT_FR,MorphNodeName=MorphNodeW_FR,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage3))
    DamageMorphTargets(3)=(InfluenceBone=MT_B,MorphNodeName=MorphNodeW_B,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage4))
	DamageMorphTargets(4)=(InfluenceBone=MT_BL,MorphNodeName=MorphNodeW_BL,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage2))
    DamageMorphTargets(5)=(InfluenceBone=MT_BR,MorphNodeName=MorphNodeW_BR,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage3))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.2)

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_MediumTank.Sounds.Med_IdleCue'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);

    EnterVehicleSound=SoundCue'RX_VH_MediumTank.Sounds.Med_startCue'
    ExitVehicleSound=SoundCue'RX_VH_MediumTank.Sounds.Med_stopCue'
	
	ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode_Large'
	
	Begin Object Class=AudioComponent Name=ScorpionSquealSound
		SoundCue=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_TireSlide'
	End Object
	SquealSound=ScorpionSquealSound
	Components.Add(ScorpionSquealSound);
	
	Begin Object Name=ScorpionTireSound
		SoundCue=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireDirt'
	End Object
	TireAudioComp=ScorpionTireSound
	Components.Add(ScorpionTireSound);
	
	TireSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireDirt')
	TireSoundList(1)=(MaterialType=Foliage,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireFoliage')
	TireSoundList(2)=(MaterialType=Grass,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireGrass')
	TireSoundList(3)=(MaterialType=Metal,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireMetal')
	TireSoundList(4)=(MaterialType=Mud,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireMud')
	TireSoundList(5)=(MaterialType=Snow,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireSnow')
	TireSoundList(6)=(MaterialType=Stone,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireStone')
	TireSoundList(7)=(MaterialType=Water,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireWater')
	TireSoundList(8)=(MaterialType=Wood,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireWood')


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\

    Begin Object Class=Rx_Vehicle_Harvester_Wheel Name=R_Wheel_01
        BoneName="Whee_R_01"
        SkelControlName="Wheel_R_Control_01"
        Side=SIDE_Right
        WheelRadius=37
    End Object
    Wheels(0)=R_Wheel_01

    Begin Object Class=Rx_Vehicle_Harvester_Wheel Name=R_Wheel_02
        BoneName="Whee_R_02"
        SkelControlName="Wheel_R_Control_02"
        Side=SIDE_Right
    End Object
    Wheels(1)=R_Wheel_02

    Begin Object Class=Rx_Vehicle_Harvester_Wheel Name=R_Wheel_03
        BoneName="Whee_R_03"
        SkelControlName="Wheel_R_Control_03"
        Side=SIDE_Right
    End Object
    Wheels(2)=R_Wheel_03


    Begin Object Class=Rx_Vehicle_Harvester_Wheel Name=L_Wheel_01
        BoneName="Whee_L_01"
        SkelControlName="Wheel_L_Control_01"
        Side=SIDE_Left
        WheelRadius=37
    End Object
    Wheels(3)=L_Wheel_01

    Begin Object Class=Rx_Vehicle_Harvester_Wheel Name=L_Wheel_02
        BoneName="Whee_L_02"
        SkelControlName="Wheel_L_Control_02"
        Side=SIDE_Left
    End Object
    Wheels(4)=L_Wheel_02

    Begin Object Class=Rx_Vehicle_Harvester_Wheel Name=L_Wheel_03
        BoneName="Whee_L_03"
        SkelControlName="Wheel_L_Control_03"
        Side=SIDE_Left
    End Object
    Wheels(5)=L_Wheel_03
	
	bAlwaysRelevant = true 
}
