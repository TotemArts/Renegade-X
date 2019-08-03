class Rx_Vehicle_GDI_MRLS_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_GDI_MRLS'
		title	    	=	"MOBILE ROCKET LAUNCHER SYSTEM"
		cost	    	=	"450"
		iconID			=	12
		bAircraft   	=   false
		desc			= 	"<font size='10'>-M269 Missiles\n-Light Armour\n-Long Range Ballistics\n-Driver + Passenger</font>"
		VehicleClass	= 	class'Rx_Vehicle_MRLS'
		PTString		=	"Buy Vehicle - MRLS"

		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_MRLS'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_MRLS'
}