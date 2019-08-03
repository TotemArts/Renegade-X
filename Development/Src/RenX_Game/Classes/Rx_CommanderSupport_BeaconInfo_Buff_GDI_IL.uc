/****************************************************
* Holds the basic information for support beacons
*
* -Yosh
*****************************************************/

class Rx_CommanderSupport_BeaconInfo_Buff_GDI_IL extends Rx_CommanderSupport_BeaconInfo_AOEBuff; 

DefaultProperties
{

MaxCastRange = 0
AOE_Radius = 3000
FireSoundCue = SoundCue'RX_SoundEffects.SFX.S_RadarBuzz_Cue'
bBroadcastToEnemy 	= false

ModifierClass = class'Rx_StatModifierInfo_GDI_IL'

PowerName			= "Inspiring Leadership"

CPCost				= 600
}