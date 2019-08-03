class Rx_Vehicle_Neutral_M2Bradley_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RX_VH_M2Bradley.UI.T_DeathIcon_M2Bradley'
		title	    	=	"M2 Bradley"
		cost	    	=	"600"
		iconID			=	11
		bAircraft   	=   false
		desc			= 	"<font size='10'>\n-75mm Auto-Cannon\n-Heavy Armour\n-Heavy Troop Transport\n-Driver + 2 Passengers</font>"
		VehicleClass	= 	class'Rx_Vehicle_M2Bradley'
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_Humvee'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_Humvee'		
}