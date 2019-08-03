class Rx_Vehicle_Nod_Apache_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_Apache'
		title	    	=	"APACHE"
		cost	    	=	"900"
		iconID			=	17
		bAircraft   	=   true
		desc			= 	"<font size='10'>-30mm Auto-Cannon\n-Hydra-70 Rockets\n-Light Armour\n-Attack Helicopter\n-Pilot Only</font>"
		VehicleClass	= 	class'Rx_Vehicle_Apache'
		PTString		=	"Buy Vehicle - Apache"
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_Apache'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_Apache'
}