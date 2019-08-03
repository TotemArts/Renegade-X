class TS_Vehicle_Nod_Buggy_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'TSPurchaseMenu.T_Icon_Veh_Nod_AttackBuggy'
		title	    	=	"ATTACK BUGGY"
		cost	    	=	"350"
		iconID			=	11
		bAircraft   	=   false
		desc			= 	"<font size='10'>-.Vulcan Cannon\n-Light Armour\n-Fast Attack Scout\n-Driver + Passenger</font>"
		VehicleClass	= 	class'TS_Vehicle_Buggy'
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_TankReady'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_TankReady'
		
		
		
}