class Rx_Building_Emp extends Rx_Building_Techbuilding
   placeable;

simulated function String GetHumanReadableName()
{
	return "Electromagnetic Pulse cannon";
}

defaultproperties
{

	Begin Object Name=Static_Exterior
        StaticMesh 						= StaticMesh'RX_BU_EMPCannon.Mesh.EMPCannonBase'
    End Object

    Begin Object Name=Static_Interior
        StaticMesh 						= none
    End Object

    Begin Object Name=PT_Screens
        StaticMesh                      	= none
    End Object

    Begin Object Class=StaticMeshComponent Name=Emp_Screens
        CastShadow                     	= True
		AlwaysLoadOnClient              	= True
		AlwaysLoadOnServer             	= True
		CollideActors                   	= True
		BlockActors                     	= True
		BlockRigidBody                  	= True
		BlockZeroExtent                 	= True
		BlockNonZeroExtent              	= True
		bCastDynamicShadow              = True
		bAcceptsLights                  	= True
		bAcceptsDecalsDuringGameplay    	= True
		bAcceptsDecals                  	= True
		bAllowApproximateOcclusion      	= True
		bUsePrecomputedShadows          = True
		bForceDirectLightMap            	= True
		bAcceptsDynamicLights           	= False
		LightingChannels                	= (bInitialized=True,Static=True)
        StaticMesh                      	= StaticMesh'RX_BU_Silo.Meshes.SM_BU_Silo_MCT'
		Translation						= ( X=0, Y=150, Z=-95)
		Rotation    						= (Pitch=0,Yaw=16384,Roll=0)
    End Object
	
	StaticMeshPieces.Add(Emp_Screens)
	Components.Add(Emp_Screens)
	
	BuildingInternalsClass  = Rx_Building_Emp_Internals
}