class Rx_BuildingAttachment_AirElevator extends Rx_BuildingAttachment_Elevator;

DefaultProperties
{
	LiftSpeed = 5.f
	TopZ = 244.f;
	StayUpTime = 3.f;

	SpawnName           = "_Elevator"
	SocketPattern       = "ElevatorSocket"

	// VISUAL PROPERTIES
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled                        = True
		bSynthesizeSHLight              = True
		bUseBooleanEnvironmentShadowing = False
		bCastShadows 					= True
	End Object
	LightComp = MyLightEnvironment
	Components.Add(MyLightEnvironment)

	Begin Object Class=StaticMeshComponent Name=ElevMeshCmp
		StaticMesh=StaticMesh'RX_BU_AirStrip.Mesh.SM_BU_AirTower_Elevator'
		CollideActors                = True
		BlockActors                  = True
		BlockRigidBody               = True
		BlockZeroExtent              = True
		BlockNonZeroExtent           = True
		bCastDynamicShadow           = True
		bAcceptsDynamicLights        = True
		bAcceptsLights               = True
		bAcceptsDecalsDuringGameplay = True
		bAcceptsDecals               = True
		bSelfShadowOnly 			 = True
		RBCollideWithChannels	=(Default=TRUE,BlockingVolume=TRUE)
		LightEnvironment = MyLightEnvironment
		LightingChannels = (bInitialized=True,Dynamic=True,Static=True)
		Translation= (X=0.0,Y=0.0,Z=12.0)
	End Object
	Components.Add(ElevMeshCmp)

	AscendingSound=SoundCue'RX_BU_AirStrip.Sounds.SC_Elevator'
	DescendingSound=SoundCue'RX_BU_AirStrip.Sounds.SC_Elevator'
}