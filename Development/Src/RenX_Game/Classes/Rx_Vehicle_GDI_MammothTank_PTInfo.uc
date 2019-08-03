class Rx_Vehicle_GDI_MammothTank_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_GDI_MammothTank'
		title	    	=	"MAMMOTH TANK"
		cost	    	=	"1500"
		iconID			=	10
		bAircraft   	=   false
		desc			= 	"<font size='10'>-2x 120mm Cannons\n-4x Tusk Missiles\n-Heavy Armour\n-Heavy Battle Tank\n-Driver + Passenger</font>"
		VehicleClass	= 	class'Rx_Vehicle_MammothTank'
		PTString		=	"Buy Vehicle - Mammoth"
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_MammothTank'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_MammothTank'

}