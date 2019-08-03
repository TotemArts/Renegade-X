class Rx_Vehicle_Nod_APC_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_APC'
		title	    	=	"ARMOURED PERSONNEL CARRIER"
		cost	    	=	"500"
		iconID			=	18
		bAircraft   	=   false
		desc			= 	"<font size='10'>-M134 Minigun\n-Heavy Armour\n-Troop Transport\n-Driver + 4 Passengers</font>"
		VehicleClass	= 	class'Rx_Vehicle_APC_Nod'
		PTString		=	"Buy Vehicle - APC"
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_APC'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_APC'
}