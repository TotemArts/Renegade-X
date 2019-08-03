class Rx_Vehicle_Nod_FlameTank_PTInfo extends Rx_Vehicle_PTInfo; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_FlameTank'
		title	    	=	"FLAME TANK"
		cost	    	=	"800"
		iconID			=	21
		bAircraft   	=   false
		desc			= 	"<font size='10'>\n-2x Flame Throwers\n-Heavy Armour\n-Close Range Suppressor\n-Driver + Passenger</font>"
		VehicleClass	= 	class'Rx_Vehicle_FlameTank'
		PTString		=	"Buy Vehicle - FlameTank"
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_FlameTank'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_FlameTank' 
}