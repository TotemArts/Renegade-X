/****************************************************
* Holds the basic information for support beacons
*
* -Yosh
*****************************************************/

class Rx_CommanderSupport_BeaconInfo_Buff_GDI_OI extends Rx_CommanderSupport_BeaconInfo_AOEBuff; 

DefaultProperties
{

MaxCastRange = 0
AOE_Radius = 3000
FireSoundCue = SoundCue'RX_CharSnd_Generic.Ambient_Yelling.AmbientYell_GDI_GoGoGo_Cue'
bBroadcastToEnemy 	= false

ModifierClass = class'Rx_StatModifierInfo_GDI_OI'

PowerName			= "Offensive Initiative"
CPCost				= 1400 //1200
}