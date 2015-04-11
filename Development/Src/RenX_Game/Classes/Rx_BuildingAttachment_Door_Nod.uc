class Rx_BuildingAttachment_Door_NOD extends Rx_BuildingAttachment_PersonnelDoor;
	
defaultproperties
{
	Begin Object Name=TopMeshPiece 
		StaticMesh = StaticMesh'rx_bu_door.Mesh.SM_Door_Nod_Top'
	End Object
	
	Begin Object Name=LeftMeshPiece
		StaticMesh = StaticMesh'rx_bu_door.Mesh.SM_Door_Nod_Left'
	End Object
	
	Begin Object Name=RightMeshPiece
		StaticMesh = StaticMesh'rx_bu_door.Mesh.SM_Door_Nod_Right'
	End Object
 
	TeamID = TEAM_NOD
}
