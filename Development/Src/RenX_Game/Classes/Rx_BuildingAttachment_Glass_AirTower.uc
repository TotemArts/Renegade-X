class Rx_BuildingAttachment_Glass_AirTower extends Rx_BuildingAttachment_Glass;

DefaultProperties
{
	Begin Object Name=SkelGlassMesh
		SkeletalMesh = SkeletalMesh'RX_BU_AirStrip.Mesh.SK_BU_AirTower_Glass'
	End Object
	Components.Add(SkelGlassMesh)

	SpawnName           = "_Glass"
	SocketPattern       = "ATGlass_"
	CollisionComponent  = SkelGlassMesh
}
