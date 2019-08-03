class Rx_Vehicle_GDI_Humvee_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_GDI_Humvee'
		title	    	=	"HUMVEE"
		cost	    	=	"350"
		iconID			=	9
		bAircraft   	=   false
		desc			= 	"<font size='10'>-.50 Calibre Machine Gun\n-Light Armour\n-Fast Attack Scout\n-Driver + Passenger</font>"
		VehicleClass	= 	class'Rx_Vehicle_Humvee'
		PTString		=	"Buy Vehicle - Humvee"
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_Humvee'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_Humvee'
}