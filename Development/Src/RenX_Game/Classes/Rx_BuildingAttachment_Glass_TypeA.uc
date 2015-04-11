class Rx_BuildingAttachment_Glass_TypeA extends Rx_BuildingAttachment_Glass
	placeable;
// TypeA Glass for the Hand of Nod
defaultproperties
{
	SpawnName     = "_Glass"
	SocketPattern = "GlassTypeA_"

	Begin Object Name=GlassMesh
		StaticMesh = StaticMesh'RX_BU_Hand.Mesh.SM_HON_Window_TypeA'
	End Object
	Components.Add(GlassMesh)

}
