class S_Vehicle_Harvester_Nod extends Rx_Vehicle_Harvester
    placeable;

DefaultProperties
{
	HarvyMessageClass = class'S_Message_Harvester'
	TeamNum = 1 

    Begin Object name=SVehicleMesh
        Materials(0)=MaterialInstanceConstant'RX_VH_Harvester.Materials.MI_VH_Harvester_Nod'
		AnimTreeTemplate=AnimTree'RX_VH_Harvester.Anims.AT_VH_Harvester_Nod'
    End Object
}
