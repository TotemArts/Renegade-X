class S_Defence_Turret_BlackHand extends Rx_Defence_Turret
    placeable;

DefaultProperties
{
	TeamID=0
	
//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\    

    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_DEF_Turret.Mesh.SK_DEF_Turret'
        Materials[0]=MaterialInstanceConstant'S_DEF_Turret_BH.Materials.MI_VH_Turret'
    End Object

//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    BurnOutMaterial[0]=MaterialInstanceConstant'S_DEF_Turret_BH.Materials.MI_Turret_Destroyed'
    BurnOutMaterial[1]=MaterialInstanceConstant'S_DEF_Turret_BH.Materials.MI_Turret_Destroyed'

}