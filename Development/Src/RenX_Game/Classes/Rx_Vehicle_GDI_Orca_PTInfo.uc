class Rx_Vehicle_GDI_Orca_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_GDI_Orca'
		title	    	=	"ORCA FIGHTER"
		cost	    	=	"900"
		iconID			=	13
		bAircraft   	=   true
		desc			= 	"<font size='10'>-Hellfire Missiles\n-.50 Calibre Machine Gun\n-Light Armour\n-Attack VTOL\n-Pilot and Passenger</font>"
		VehicleClass	= 	class'Rx_Vehicle_Orca'
		PTString		=	"Buy Vehicle - Orca"

		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_Orca'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_Orca'
}