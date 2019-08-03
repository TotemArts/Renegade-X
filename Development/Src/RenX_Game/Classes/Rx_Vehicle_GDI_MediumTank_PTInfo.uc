class Rx_Vehicle_GDI_MediumTank_PTInfo extends Rx_Vehicle_PTInfo; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_GDI_MediumTank'
		title	    	=	"MEDIUM TANK"
		cost	    	=	"800"
		iconID			=	11
		bAircraft   	=   false
		desc			= 	"<font size='10'>-105mm Cannon\n-Coaxial MG\n-Heavy Armour\n-Main Battle Tank\n-Driver + Passenger</font>"
		VehicleClass	= 	class'Rx_Vehicle_MediumTank'
		PTString		=	"Buy Vehicle - Med"
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_MediumTank'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_MediumTank'

}