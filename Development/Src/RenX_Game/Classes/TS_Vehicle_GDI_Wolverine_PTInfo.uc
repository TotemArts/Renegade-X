class TS_Vehicle_GDI_Wolverine_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'TSPurchaseMenu.T_Icon_Veh_GDI_Wolverine'
		title	    	=	"WOLVERINE"
		cost	    	=	"500"
		iconID			=	9
		bAircraft   	=   false
		desc			= 	"<font size='10'>-2x Gatling Gun\n-Light Armour\n-Fast Attack Scout\n-Driver</font>"
		VehicleClass	= 	class'TS_Vehicle_Wolverine'
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_TankReady'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_TankReady'
}