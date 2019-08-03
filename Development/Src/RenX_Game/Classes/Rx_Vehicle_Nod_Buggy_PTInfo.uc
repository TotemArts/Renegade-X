class Rx_Vehicle_Nod_Buggy_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_Buggy'
		title	    	=	"BUGGY"
		cost	    	=	"300"
		iconID			=	20
		bAircraft   	=   false
		desc			= 	"<font size='10'>-.50 Calibre Machine Gun\n-Light Armour\n-Fast Attack Scout\n-Driver + Passenger</font>"
		VehicleClass	= 	class'Rx_Vehicle_Buggy'
		PTString		=	"Buy Vehicle - Buggy"
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_Buggy'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_Buggy'

}