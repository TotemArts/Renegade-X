class Rx_SupportVehicle_Air extends Rx_SupportVehicle 
implements(RxIfc_SeekableTarget);

var	float		AntiAirAimAheadMod, AntiAirAccelMod; 

function float GetAimAheadModifier()
{
	return AntiAirAimAheadMod;
}

function float GetAccelrateModifier()
{
	return AntiAirAccelMod;
}

simulated function vector GetAdjustedLocation()
{

	return location; 
}

DefaultProperties
{
	AntiAirAttentionPulseTime 	= 	3.0 
	bAttractAA 			=	true 
	
	AntiAirAimAheadMod	=	1.0
	AntiAirAccelMod		=	1.0
	
	bCollideWorld = false //Override for cruise missiles and things that need to hit the world
	bPushedByEncroachers=false
}