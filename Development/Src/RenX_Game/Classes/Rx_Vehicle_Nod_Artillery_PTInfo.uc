class Rx_Vehicle_Nod_Artillery_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_Artillery'
		title	    	=	"MOBILE ARTILLERY"
		cost	    	=	"450"
		iconID			=	19
		bAircraft   	=   false
		desc			= 	"<font size='10'>\n-155mm Howitzer\n-Light Armour\n-Long Range Ballistics\n-Driver + Passenger</font>"
		VehicleClass	= 	class'Rx_Vehicle_Artillery'
		PTString		=	"Buy Vehicle - Artillery"
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_Artillery'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_Artillery'
}