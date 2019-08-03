class Rx_Vehicle_Nod_StealthTank_PTInfo extends Rx_Vehicle_PTInfo
; 

/*Base class to hold a vehicle's PT info*/

DefaultProperties
{
		PTIconTexture	=	Texture2D'RenXPurchaseMenu.T_Icon_Veh_Nod_StealthTank'
		title	    	=	"STEALTH TANK"
		cost	    	=	"900"
		iconID			=	23
		bAircraft   	=   false
		desc			= 	"<font size='10'>-2x TOW Missiles\n-Heavy Armour\n-Guerilla Combat Vehicle\n-Active Camouflage\n-DriveOnly</font>"
		VehicleClass	= 	class'Rx_Vehicle_StealthTank'
		PTString		=	"Buy Vehicle - Stank"
		
		GDIVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_StealthTank'
		NodVehicleAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_StealthTank'
}