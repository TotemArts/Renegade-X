class TS_Vehicle_Nod_TickTank_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'TSPurchaseMenu.T_Icon_Veh_Nod_TickTank'
		title	    	=	"TICK TANK"
		cost	    	=	"900"
		iconID			=	22
		bAircraft   	=   false
		desc			= 	"<font size='10'>\n-75mm Cannon\n-Heavy Armour\n-Main Battle Tank\n-Driver + Passenger</font>"
		VehicleClass	= 	class'TS_Vehicle_TickTank'
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_TankReady'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_TankReady'
}