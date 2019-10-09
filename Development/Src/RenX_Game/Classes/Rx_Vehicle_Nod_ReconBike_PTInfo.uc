class Rx_Vehicle_Nod_ReconBike_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_ReconBike'
		title	    	=	"RECON BIKE"
		cost	    	=	"250"
		iconID			=	11
		bAircraft   	=   false
		desc			= 	"<font size='10'>-2x TOW Missiles\n-Very Light Armour\n-Fast Harasser\n-Driver Only</font>"
		VehicleClass	= 	class'Rx_Vehicle_ReconBike'
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_ReconBike'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_ReconBike'

}