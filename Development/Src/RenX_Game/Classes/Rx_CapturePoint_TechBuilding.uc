class Rx_CapturePoint_TechBuilding extends Rx_CapturePoint;

DefaultProperties
{
	bInfantryCanCap=true
	bVehiclesCanCap=false

	Begin Object Name=CollisionCylinder
		CollisionRadius=224.0
		CollisionHeight=96.0
	End Object

	FullCaptureScore=100
	FullNeutralizeScore=100
	BaseCapRatePerSecond=0.06667
	BonusCapRatePerSecond=0.015
	MaxCapRatePerSecond=0.125
	DrainRatePerSecond=0.04
}