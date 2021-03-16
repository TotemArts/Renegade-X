class S_Building_TeamSilo_BH extends Rx_Building_TeamSilo_Nod
	placeable;

simulated function String GetHumanReadableName()
{
	return "Silo";
}

defaultproperties
{
   TeamID = TEAM_GDI
   BuildingInternalsClass = S_Building_TeamSilo_BH_Internals
   bSignificant		= false
   bTriggerUnderAttack = true
   GDIColor    = "#3260FF"
	
	Begin Object Name=Static_Exterior
		StaticMesh = StaticMesh'S_BU_TeamSilo.Meshes.SM_Silo_BH'
		LightingChannels=(bInitialized=True,Static=True)
	End Object
	
	Begin Object Name=Static_Interior
        StaticMesh = StaticMesh'S_BU_TeamSilo.Meshes.SM_Silo_Exterior_BH'
		LightingChannels=(bInitialized=True,Static=True)
    End Object

}

