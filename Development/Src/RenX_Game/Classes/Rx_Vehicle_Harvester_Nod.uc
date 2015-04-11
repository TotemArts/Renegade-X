/*********************************************************
*
* File: Rx_Vehicle_Harvester_Nod.uc
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
class Rx_Vehicle_Harvester_Nod extends Rx_Vehicle_Harvester
    placeable;



DefaultProperties
{

//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\

	TeamNum = 1 

    Begin Object name=SVehicleMesh
        Materials(0)=MaterialInstanceConstant'RX_VH_Harvester.Materials.MI_VH_Harvester_Nod'
		AnimTreeTemplate=AnimTree'RX_VH_Harvester.Anims.AT_VH_Harvester_Nod'
    End Object
}
