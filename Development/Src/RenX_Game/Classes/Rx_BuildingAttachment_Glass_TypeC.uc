class Rx_BuildingAttachment_Glass_TypeC extends Rx_BuildingAttachment_Glass;
// TypeC Glass for the Hand of Nod
defaultproperties
{
	SpawnName     = "_Glass"
	SocketPattern = "GlassTypeC_"
	Begin Object Name=GlassMesh
		StaticMesh = StaticMesh'RX_BU_Hand.Mesh.SM_HON_Window_TypeC'
	End Object
	Components.Add(GlassMesh)
}
