class TS_Vehicle_GDI_HMRLS_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'TSPurchaseMenu.T_Icon_Veh_GDI_HoverMRLS'
		title	    	=	"HOVER MRLS"
		cost	    	=	"800"
		iconID			=	2
		bAircraft   	=   false
		desc			= 	"<font size='10'>-Multi-Launch-Missile-System\n-Light Armour\n-Long Range Support\n-Driver</font>"
		VehicleClass	= 	class'TS_Vehicle_HoverMRLS'
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_TankReady'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_TankReady'
		
}