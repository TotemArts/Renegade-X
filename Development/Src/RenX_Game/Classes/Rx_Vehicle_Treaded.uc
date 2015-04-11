/*********************************************************
*
* File: RxVehicle_Threaded.uc
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
class Rx_Vehicle_Treaded extends Rx_Vehicle;

var protected MaterialInstanceConstant LeftTreadMaterialInstance, RightTreadMaterialInstance;

/** material parameter controlling tread panner speed */
var() name TreadSpeedParameterName;
var byte LeftTeadIndex, RightTreadIndex;
var SVehicleSimTank SimTank;

/** MaxCuePitch - set when any motor torque applied, MinCuePitch - set when no torque */
var() float MaxCuePitch, MinCuePitch;
var() float EaseOutFactor, EaseOutStep; 
var() float VelocitySaltDegree, VelocityBeginMultiplier;

/** Divident for the InsideTrackTorqueFactor when sprinting. DO NOT SET THIS TO ZERO OR THE GAME/EDITOR WILL CRASH!!!*/
var(Vehicle) float SprintTrackTorqueFactorDivident;

/** PitchOld - used to interpolate, to ease out from old pitch */
var private float PitchOld;


/**
 * PostBeginPlay
 *
 * setup SimTank and Mats
 * */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (WorldInfo.NetMode != NM_DedicatedServer && Mesh != None)
	{
		// set up material instance (for overlay effects)
		LeftTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(LeftTeadIndex);
		RightTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(RightTreadIndex);
		SimTank = SVehicleSimTank(SimObj);
	}
}

/**
 * Tick
 *
 * calculating and setting tread-specific stuff
 * */
simulated event Tick( float DeltaTime )
{
	local float right, left, PitchSet, VelocitySalt;

	super.Tick(DeltaTime);
	if (WorldInfo.NetMode != NM_DedicatedServer && bDriving)
	{
		VelocitySalt = (VSize(Velocity) / MaxSpeed) * VelocityBeginMultiplier;
		PitchSet = (Abs(SimTank.LeftTrackTorque) + Abs(SimTank.RightTrackTorque)) / SimTank.MaxEngineTorque;
		PitchOld =  FInterpEaseOut(PitchOld, PitchSet > 0.0f ? MaxCuePitch : MinCuePitch, EaseOutStep, EaseOutFactor);
		PitchSet = ((VelocitySalt * VelocitySaltDegree) + ((1.0f - VelocitySaltDegree) * PitchOld));
		EngineSound.SoundCue.PitchMultiplier = PitchSet;

		LeftTreadMaterialInstance.GetScalarParameterValue(TreadSpeedParameterName, left);
		RightTreadMaterialInstance.GetScalarParameterValue(TreadSpeedParameterName, right);

		left += (SimTank.LeftTrackVel / (SimTank.MaxEngineTorque * SimTank.InsideTrackTorqueFactor))*0.06;
		right += (SimTank.RightTrackVel / (SimTank.MaxEngineTorque * SimTank.InsideTrackTorqueFactor))*0.06;

		LeftTreadMaterialInstance.SetScalarParameterValue(TreadSpeedParameterName, left);
		RightTreadMaterialInstance.SetScalarParameterValue(TreadSpeedParameterName,  right);
	}

	// brute force method to overcome bDriving false not blocking treaded vehicle movement
	if (bEMPd)
		ZeroMovementVariables();
}

reliable server function IncreaseSprintSpeed()
{
	local float SprintSpeed_Max;

	Super.IncreaseSprintSpeed();

	SprintSpeed_Max = Default.MaxSpeed * MinSprintSpeedMultiplier;

	if(PlayerController(Controller) != None)
	{
		ServerSetMaxSpeed(SprintSpeed_Max);
	}

	MaxSpeed = SprintSpeed_Max;

	if(SVehicleSimTank(SimObj) != None)
	{
		SVehicleSimTank(SimObj).MaxEngineTorque = SVehicleSimTank(SimObj).Default.MaxEngineTorque * MinSprintSpeedMultiplier;
		SVehicleSimTank(SimObj).InsideTrackTorqueFactor =  SVehicleSimTank(SimObj).Default.InsideTrackTorqueFactor * (MinSprintSpeedMultiplier / SprintTrackTorqueFactorDivident);
	}
}
reliable server function DecreaseSprintSpeed()
{
	Super.DecreaseSprintSpeed();

	if(PlayerController(Controller) != None)
	{
		ServerSetMaxSpeed(MaxSpeed);
	}

	MaxSpeed = Default.MaxSpeed;

	if(SVehicleSimTank(SimObj) != None)
	{
		SVehicleSimTank(SimObj).MaxEngineTorque = SVehicleSimTank(SimObj).Default.MaxEngineTorque;
		SVehicleSimTank(SimObj).InsideTrackTorqueFactor =  SVehicleSimTank(SimObj).Default.InsideTrackTorqueFactor;
	}
}

/**
 * Console specific input modification
 * also reversing steering for treaded vehicles here
 */
simulated function SetInputs(float InForward, float InStrafe, float InUp)
{
	Super.SetInputs(InForward, InStrafe, InUp);
	// Reverse steering when reversing
	if (Throttle < 0.0 && PlayerController(Controller) != None && bReverseSteeringInverted)
		Steering *= -1.0;
}

DefaultProperties
{
	SprintTrackTorqueFactorDivident=1.075
	MinSprintSpeedMultiplier=1.0
	MaxSprintSpeedMultiplier=1.3
	SprintTimeInterval=1.0
	SprintSpeedIncrement=1.0

	TreadSpeedParameterName=Veh_Tread_Speed
	MaxCuePitch= 1.2f
	MinCuePitch= 1.0f
	EaseOutFactor = 2.0f
	EaseOutStep = 0.001f
	VelocitySaltDegree = 0.3f
	VelocityBeginMultiplier = 2.5f

	Begin Object Class=AudioComponent Name=ScorpionTireSound
		SoundCue=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TrackDirt'
	End Object
	TireAudioComp=ScorpionTireSound
	Components.Add(ScorpionTireSound);
	
	TireSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TrackDirt')
	TireSoundList(1)=(MaterialType=Foliage,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TrackFoliage')
	TireSoundList(2)=(MaterialType=Grass,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TrackGrass')
	TireSoundList(3)=(MaterialType=Metal,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TrackMetal')
	TireSoundList(4)=(MaterialType=Mud,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TrackMud')
	TireSoundList(5)=(MaterialType=Snow,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TrackSnow')
	TireSoundList(6)=(MaterialType=Stone,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TrackStone')
	TireSoundList(7)=(MaterialType=Water,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TrackWater')
	TireSoundList(8)=(MaterialType=Wood,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TrackWood')

}
