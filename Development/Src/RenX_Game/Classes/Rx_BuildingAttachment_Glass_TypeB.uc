class Rx_BuildingAttachment_Glass_TypeB extends Rx_BuildingAttachment_Glass;
// TypeB Glass for the Hand of Nod
defaultproperties
{
	SpawnName     = "_Glass"
	SocketPattern = "GlassTypeB_"

	Begin Object Name=GlassMesh
		StaticMesh = StaticMesh'RX_BU_Hand.Mesh.SM_HON_Window_TypeB'
	End Object
	Components.Add(GlassMesh)
}
