class Rx_Vehicle_Nod_LightTank_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_LightTank'
		title	    	=	"LIGHT TANK"
		cost	    	=	"600"
		iconID			=	22
		bAircraft   	=   false
		desc			= 	"<font size='10'>\n-75mm Cannon\n-Heavy Armour\n-Main Battle Tank\n-Driver + Passenger</font>"
		VehicleClass	= 	class'Rx_Vehicle_LightTank'
		PTString		=	"Buy Vehicle - LightTank"
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_LightTank'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_LightTank'
}