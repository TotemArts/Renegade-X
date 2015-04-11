class Rx_Building_AdvancedGuardTower extends Rx_Building
   placeable
   implements (RxIfc_TargetedDescription);
   
var() bool bWeaponsDisabled;   
var vector SentinelLocation;

replication
{
	if( bNetDirty && Role == ROLE_Authority )
		SentinelLocation;
}

simulated function String GetHumanReadableName()
{
	return "Adv. Guard Tower";
}

simulated function string GetTargetedDescription(PlayerController PlayerPerspective)
{
	if (GetHealth() > 0 && Rx_Building_Team_Internals(BuildingInternals).bNoPower)
		return "Weapons Offline";
	return "";
}

defaultproperties
{
	TeamID                 = TEAM_GDI
	BuildingInternalsClass = Rx_Building_AdvancedGuardTower_Internals

	Begin Object Name=Static_Exterior
		StaticMesh = StaticMesh'RX_BU_AGT.Mesh.SM_BU_AGT_Exterior'
	End Object

	Begin Object Name=Static_Interior
		StaticMesh = StaticMesh'RX_BU_AGT.Mesh.SM_BU_AGT_Interior'
	End Object

	Begin Object Name=Static_Interior_Complex
		StaticMesh = StaticMesh'RX_BU_AGT.Mesh.SM_BU_AGT_Interior_Complex'
	End Object

	Begin Object Name=PT_Screens
		StaticMesh = StaticMesh'RX_BU_AGT.Mesh.SM_BU_AGT_Screens'
	End Object

	/***************************************************/
	/*             Point Light Components              */
	/***************************************************/
	Begin Object Name=PointLightComponent1
		Translation = (X=-114.0,Y=66.0,Z=92.0)
		Radius = 300.0
	End Object
	Components.Add(PointLightComponent1)
	PointLightComponents.Add(PointLightComponent1)

	Begin Object Name=PointLightComponent2
		Translation = (X=80.0,Y=66.0,Z=92.0)
		Radius = 300.0
	End Object
	Components.Add(PointLightComponent2)
	PointLightComponents.Add(PointLightComponent2)

	/***************************************************/
	/*              Spot Light Components              */
	/***************************************************/
	Begin Object Name=SpotLightComponent1
		Translation = (X=-60.0,Y=-115.0,Z=-55.0)
		Rotation    = (Pitch=0,Yaw=16384,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent1)
	SpotLightComponents.Add(SpotLightComponent1)

	Begin Object Name=SpotLightComponent2
		Translation = (X=-60.0,Y=248.0,Z=-55.0)
		Rotation    = (Pitch=0,Yaw=-16384,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent2)
	SpotLightComponents.Add(SpotLightComponent2)

	Begin Object Name=SpotLightComponent3
		Translation = (X=163.0,Y=67.0,Z=-71.0)
		Rotation    = (Pitch=1638,Yaw=-32768,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent3)
	SpotLightComponents.Add(SpotLightComponent3)

	Begin Object Name=SpotLightComponent4
		Translation = (X=-270.0,Y=-46.0,Z=42.0)
		Rotation    = (Pitch=-16384,Yaw=0,Roll=0)
		LightColor  = (B=242,G=250,R=255,A=0)
		Brightness = 6.0
		InnerConeAngle = 45.0
		OuterConeAngle = 60.0
	End Object
	Components.Add(SpotLightComponent4)
	SpotLightComponents.Add(SpotLightComponent4)
}
