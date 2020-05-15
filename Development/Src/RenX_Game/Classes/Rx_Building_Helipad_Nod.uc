class Rx_Building_Helipad_Nod extends Rx_Building_Nod_VehicleFactory
   placeable;

simulated function String GetHumanReadableName()
{
	return "Helipad";
}

simulated function PostBeginPlay()
{
	Super(Rx_Building).PostBeginPlay();
}

defaultproperties
{
	TeamID                 = TEAM_NOD
	BuildingInternalsClass  = Rx_Building_Helipad_Nod_Internals
	myBuildingType=BT_Air

    Begin Object Name=Static_Exterior
        StaticMesh = StaticMesh'RX_BU_Helipad.Mesh.SM_Helipad_Base'
		Materials[0] = MaterialInstanceConstant'RX_BU_Helipad.Materials.MI_Helipad_Base_Nod'
		Materials[1] = MaterialInstanceConstant'RX_BU_Helipad.Materials.MI_Helipad_Generator_Nod'
		Materials[4] = MaterialInstanceConstant'RX_BU_Helipad.Materials.MI_Lights_Nod'
    End Object

    Begin Object Name=Static_Interior
        StaticMesh = StaticMesh'RX_BU_Helipad.Mesh.SM_Helipad_Catwalk'
    End Object

    Begin Object Name=PT_Screens
        StaticMesh = StaticMesh'RX_BU_Helipad.Mesh.SM_Screens'
        Materials[1] = Material'rx_deco_terminal.Materials.M_PT_Screen_Nod'
		Materials[2] = MaterialInstanceConstant'RX_BU_Helipad.Materials.MI_BuildingIcon_Nod'
		Materials[3] = Material'rx_deco_terminal.Materials.M_Screen_ScanLine_Nod'
		Materials[4] = Material'rx_deco_terminal.Materials.M_Screen_Logo_Nod'
		Materials[5] = Material'rx_deco_terminal.Materials.M_Screen_ScrollingText_Nod'
    End Object
    
    Begin Object Class=StaticMeshComponent Name=Static_Decorative
        StaticMesh = StaticMesh'RX_BU_Helipad.Mesh.SM_Helipad_Deco'
		CastShadow                      = True
		AlwaysLoadOnClient              = True
		AlwaysLoadOnServer              = True
		CollideActors                   = True
		BlockActors                     = True
		BlockRigidBody                  = True
		BlockZeroExtent                 = True
		BlockNonZeroExtent              = True
		bCastDynamicShadow              = True
		bAcceptsLights                  = True
		bAcceptsDecalsDuringGameplay    = True
		bAcceptsDecals                  = True
		bAllowApproximateOcclusion      = True
		bUsePrecomputedShadows          = True
		bForceDirectLightMap            = True
		bAcceptsDynamicLights           = True
		LightingChannels                = (bInitialized=True,Static=True)
		Translation						= (Z=-150)
    End Object
	StaticMeshPieces.Add( Static_Decorative )
	Components.Add( Static_Decorative )

	/***************************************************/
	/*             Point Light Components              */
	/***************************************************/
	Begin Object Name=PointLightComponent1
		Translation = (X=-1.061371,Y=454.174805,Z=23.690796)
		LightColor  = (B=217,G=233,R=255,A=0)
		Radius = 256
		FalloffExponent = 4.0
		Brightness = 1.0
		LightmassSettings=(LightSourceRadius=32.0)
	End Object
	PointLightComponents.Add(PointLightComponent1)
	Components.Add(PointLightComponent1)

	Begin Object Name=PointLightComponent2
		Translation = (X=-108.240295,Y=453.241943,Z=64.774841)
		LightColor  = (B=0,G=10,R=255,A=0)
		Radius = 200
		FalloffExponent = 4.0
		Brightness = 3.0
		LightmassSettings=(LightSourceRadius=16.0)
	End Object
	PointLightComponents.Add(PointLightComponent2)
	Components.Add(PointLightComponent2)

	Begin Object Name=PointLightComponent3
		Translation = (X=113.294479,Y=452.710571,Z=52.398956)
		LightColor  = (B=0,G=10,R=255,A=0)
		Radius = 200
		FalloffExponent = 4.0
		Brightness = 3.0
		LightmassSettings=(LightSourceRadius=16.0)
	End Object
	PointLightComponents.Add(PointLightComponent3)
	Components.Add(PointLightComponent3)
	
	Begin Object Name=PointLightComponent4
		Translation = (X=42.776855,Y=362.687012,Z=126.338135)
		LightColor  = (B=255,G=148,R=85,A=0)
		Radius = 128
		FalloffExponent = 4.0
		Brightness = 3.0
		LightmassSettings=(LightSourceRadius=8.0)
	End Object
	PointLightComponents.Add(PointLightComponent4)
	Components.Add(PointLightComponent4)
	
	Begin Object Name=PointLightComponent5
		Translation = (X=-39.670349,Y=362.473022,Z=126.903931)
		LightColor  = (B=255,G=148,R=85,A=0)
		Radius = 128
		FalloffExponent = 4.0
		Brightness = 3.0
		LightmassSettings=(LightSourceRadius=8.0)
	End Object
	PointLightComponents.Add(PointLightComponent5)
	Components.Add(PointLightComponent5)


	/***************************************************/
	/*              Spot Light Components              */
	/***************************************************/
	Begin Object Name=SpotLightComponent1
		Translation = (X=24.361603,Y=283.539063,Z=124.102264)
		Rotation    = (Pitch=-9440,Yaw=-2400,Roll=16384)
		LightColor  = (B=245,G=252,R=251,A=255)
		Radius = 1024
		FalloffExponent = 4.0
		Brightness = 10.0
		LightmassSettings=(LightSourceRadius=8.0)
		InnerConeAngle = 15.0
		OuterConeAngle = 45.0
	End Object
	Components.Add(SpotLightComponent1)
	SpotLightComponents.Add(SpotLightComponent1)

	Begin Object Name=SpotLightComponent2
		Translation = (X=-24.464325,Y=283.606934,Z=123.888458)
		Rotation    = (Pitch=-9446,Yaw=-30728,Roll=16435)
		LightColor  = (B=245,G=252,R=251,A=255)
		Radius = 1024
		FalloffExponent = 4.0
		Brightness = 10.0
		LightmassSettings=(LightSourceRadius=8.0)
		InnerConeAngle = 15.0
		OuterConeAngle = 45.0
	End Object
	Components.Add(SpotLightComponent2)
	SpotLightComponents.Add(SpotLightComponent2)

	Begin Object Name=SpotLightComponent3
		Translation = (X=0.0,Y=581.346191,Z=127.612122)
		Rotation    = (Pitch=-10368,Yaw=16384,Roll=-16384)
		LightColor  = (B=243,G=251,R=249,A=255)
		Radius = 512
		FalloffExponent = 4.0
		Brightness = 10.0
		LightmassSettings=(LightSourceRadius=16.0)
		InnerConeAngle = 35.0
		OuterConeAngle = 70.0
	End Object
	Components.Add(SpotLightComponent3)
	SpotLightComponents.Add(SpotLightComponent3)

	Begin Object Name=SpotLightComponent4
		Translation = (X=-0.401093,Y=507.714478,Z=129.394379)
		Rotation    = (Pitch=-11456,Yaw=-81920,Roll=-49152)
		LightColor  = (B=246,G=253,R=251,A=255)
		Radius = 256
		FalloffExponent = 2.0
		Brightness = 20.0
		LightmassSettings=(LightSourceRadius=8.0)
		InnerConeAngle = 30.0
		OuterConeAngle = 75.0
	End Object
	Components.Add(SpotLightComponent4)
	SpotLightComponents.Add(SpotLightComponent4)
}