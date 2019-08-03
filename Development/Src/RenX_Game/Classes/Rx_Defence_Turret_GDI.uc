class Rx_Defence_Turret_GDI extends Rx_Defence_Turret
    placeable;

DefaultProperties
{
	TeamID=0
	
//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\    

    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_DEF_Turret.Mesh.SK_DEF_Turret_GDI'
    End Object

//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    BurnOutMaterial[0]=MaterialInstanceConstant'RX_DEF_Turret.Materials.MI_Turret_GDI_Destroyed'
    BurnOutMaterial[1]=MaterialInstanceConstant'RX_DEF_Turret.Materials.MI_Turret_GDI_Destroyed'

}