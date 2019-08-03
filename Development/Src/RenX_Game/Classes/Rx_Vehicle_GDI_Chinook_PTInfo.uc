class Rx_Vehicle_GDI_Chinook_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_TransportHelicopter'
		title	    	=	"TRANSPORT HELICOPTER"
		cost	    	=	"700"
		iconID			=	24
		bAircraft   	=   true
		desc			= 	"<font size='10'>-2x Gatling Guns\n-Light Armour\n-Troop Transport\n-Pilot + 4 Passengers</font>"
		VehicleClass	= 	class'Rx_Vehicle_Chinook_GDI'
		PTString		=	"Buy Vehicle - Chinook"

		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_TransportHelicopter'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_TransportHelicopter'
}