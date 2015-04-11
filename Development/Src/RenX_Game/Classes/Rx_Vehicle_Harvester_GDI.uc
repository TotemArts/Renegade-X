/*********************************************************
*
* File: Rx_Vehicle_Harvester_GDI.uc
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
class Rx_Vehicle_Harvester_GDI extends Rx_Vehicle_Harvester
    placeable;



DefaultProperties
{

//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\

	TeamNum = 0
    Begin Object name=SVehicleMesh
        Materials(0)=MaterialInstanceConstant'RX_VH_Harvester.Materials.MI_VH_Harvester_GDI'
    End Object
    
}
