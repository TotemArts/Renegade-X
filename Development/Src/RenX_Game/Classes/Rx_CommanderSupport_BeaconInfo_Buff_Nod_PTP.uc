/****************************************************
* Holds the basic information for support beacons
*
* -Yosh
*****************************************************/

class Rx_CommanderSupport_BeaconInfo_Buff_Nod_PTP extends Rx_CommanderSupport_BeaconInfo_AOEBuff; 

DefaultProperties
{

MaxCastRange = 0
AOE_Radius = 3000
FireSoundCue = SoundCue'RX_CharSnd_Generic.Ambient_Yelling.AmbientYell_Nod_CloseTheNoose_Cue'
bBroadcastToEnemy 	= false

ModifierClass = class'Rx_StatModifierInfo_Nod_PTP'

PowerName			= "PEACE, THROUGH POWER!"

CPCost				= 1400 //1200
}