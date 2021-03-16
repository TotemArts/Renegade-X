class S_BuildingAttachment_Door_BH extends Rx_BuildingAttachment_PersonnelDoor;
	
defaultproperties
{
	Begin Object Name=TopMeshPiece 
		StaticMesh = StaticMesh'S_BU_Door.Mesh.SM_Door_BH_Top'
	End Object
	
	Begin Object Name=LeftMeshPiece
		StaticMesh = StaticMesh'S_BU_Door.Mesh.SM_Door_BH_Left'
	End Object
	
	Begin Object Name=RightMeshPiece
		StaticMesh = StaticMesh'S_BU_Door.Mesh.SM_Door_BH_Right'
	End Object
 
	TeamID = TEAM_GDI
}
