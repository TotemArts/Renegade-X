//=============================================================================
// Handles rotation sounds for a Sentinel.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelComponent_RotationSound extends AudioComponent;

/** Rotation speed that results in 1.0 pitch for rotation sounds. */
var() float RotationSoundPitchScale;
/** Rotation speed that results in 1.0 volume for rotation sounds. */
var() float RotationSoundVolumeScale;
/** Upper limit on rotation sound volume. */
var() float RotationSoundVolumeMax;
/** Name of parameter to change motor sound */
var() name RotationSoundParamName;
/** Default motor sound. */
var() SoundNodeWave RotationSoundNodeWave;

/** Time constant for calculating average rotation speeds. */
var() float AverageDeltaRotationTime;

/** The average change in rotation per second. */
var float AverageDeltaRotation;

function Initialize()
{
	SetWaveParameter(RotationSoundParamName, RotationSoundNodeWave);
	RotationSoundVolumeScale = default.RotationSoundVolumeScale;
	RotationSoundVolumeMax = default.RotationSoundVolumeMax;
}

/**
 * Sets pitch and volume based on average rotation speed.
 */
function AdjustRotationSounds(float DeltaTime, float DeltaRotation)
{
	AverageDeltaRotation -= AverageDeltaRotation * (DeltaTime / AverageDeltaRotationTime);
	AverageDeltaRotation += Abs(DeltaRotation) / AverageDeltaRotationTime;
	PitchMultiplier = AverageDeltaRotation / RotationSoundPitchScale;
	VolumeMultiplier = FMin(AverageDeltaRotation / RotationSoundVolumeScale, RotationSoundVolumeMax);
}

/**
 * Changes the rotation sound.
 */
function ChangeSound(SoundNodeWave NewSound)
{
	SetWaveParameter(RotationSoundParamName,  NewSound);
}

/**
 * Scales max volume and the speed needed to reach that volume.
 */
function ModifyVolumeParameters(float VolumeParameterModifier)
{
	RotationSoundVolumeScale = default.RotationSoundVolumeScale / VolumeParameterModifier;
	RotationSoundVolumeMax = default.RotationSoundVolumeMax * VolumeParameterModifier;
}

defaultproperties
{
	RotationSoundPitchScale=7000.0
	RotationSoundVolumeScale=1500.0
	RotationSoundVolumeMax=3.0
	RotationSoundParamName=MotorSound
	RotationSoundNodeWave=None
	AverageDeltaRotationTime=0.1

	SoundCue=None
	bShouldRemainActiveIfDropped=true
	bStopWhenOwnerDestroyed=true
	bAutoPlay=true
	VolumeMultiplier=0.0
}