/*********************************************************
*
* File: Rx_Vehicle_APC_Nod_Weapon.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class S_Vehicle_APC_Weapon extends Rx_Vehicle_APC_Nod_Weapon;

DefaultProperties
{
	BeamTemplates[0]=ParticleSystem'S_FX_Munitions.Beams.P_InstantHit_Tracer_Nod_Large'
	BeamTemplates_Heroic[0]= ParticleSystem'S_FX_Munitions.Beams.P_InstantHit_Tracer_Nod_Large_Heroic'
}
