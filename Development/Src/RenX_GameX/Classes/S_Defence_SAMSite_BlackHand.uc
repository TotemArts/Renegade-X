class S_Defence_SAMSite_BlackHand extends Rx_Defence_SAMSite
    placeable;

DefaultProperties
{
	TeamID=0

    Begin Object name=SVehicleMesh
        Materials[1]=MaterialInstanceConstant'S_DEF_SamSite_BH.Materials.MI_SamSite_Main'
        Materials[2]=MaterialInstanceConstant'S_DEF_SamSite_BH.Materials.MI_SamSite_Missiles'
    End Object

    BurnOutMaterial[0]=MaterialInstanceConstant'S_DEF_SamSite_BH.Materials.MI_SamSite_Destroyed'
    BurnOutMaterial[1]=MaterialInstanceConstant'S_DEF_SamSite_BH.Materials.MI_SamSite_Destroyed'
}