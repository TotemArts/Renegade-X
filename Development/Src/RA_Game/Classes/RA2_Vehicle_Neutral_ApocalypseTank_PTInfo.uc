class RA2_Vehicle_Neutral_ApocalypseTank_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_Neutral_ApocalypseTank'
		title	    	=	"APOCALYPSE TANK"
		cost	    	=	"1750"
		iconID			=	13
		bAircraft   	=   false
		desc			= 	"<font size='10'>\n-120mm Cannons\n-Tusk Missiles\n-Heavy Armour\n-Heavy Battle Tank\n-Driver + Passenger</font>"
		VehicleClass	= 	class'RA2_Vehicle_ApocalypseTank'
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_TankReady'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_TankReady'	
}