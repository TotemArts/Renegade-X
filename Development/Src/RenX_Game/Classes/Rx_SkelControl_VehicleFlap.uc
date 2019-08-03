class Rx_SkelControl_VehicleFlap extends UDKSkelControl_VehicleFlap;

defaultproperties
{
	MaxPitch=30
	MaxPitchTime=4.0
	MaxPitchChange=10000.0
	bApplyRotation=true
	BoneRotationSpace=BCS_BoneSpace
	bAddRotation=True


	ControlStrength=1.0
	bIgnoreWhenNotRendered=true
	RightFlapControl=right_flap
	LeftFlapControl=left_flap
}