class RA2_Vehicle_Neutral_TeslaTank_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_Neutral_TeslaTank'
		title	    	=	"TESLA TANK"
		cost	    	=	"1200"
		iconID			=	12
		bAircraft   	=   false
		desc			= 	"<font size='10'>\n-Tesla Coils\n-Heavy Armour\n-Anti-Surface Tank\n-Driver + Passenger</font>"
		VehicleClass	= 	class'RA2_Vehicle_TeslaTank'
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_TankReady'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_TankReady'	
}