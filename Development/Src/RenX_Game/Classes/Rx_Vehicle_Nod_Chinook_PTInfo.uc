class Rx_Vehicle_Nod_Chinook_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_TransportHelicopter'
		title	    	=	"TRANSPORT HELICOPTER"
		cost	    	=	"700"
		iconID			=	24
		bAircraft   	=   true
		desc			= 	"<font size='10'>\n-2x Gattling Guns\n-Light Armour\n-Troop Transport\n-Pilot + 4 Passengers</font>"
		VehicleClass	= 	class'Rx_Vehicle_Chinook_Nod'
		PTString		=	"Buy Vehicle - Chinook"
				
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_TransportHelicopter'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_TransportHelicopter'
}