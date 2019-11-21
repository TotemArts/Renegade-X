class Rx_Weapon_Blueprint_Defense_GT_GDI extends Rx_Weapon_Blueprint_Defense;

DefaultProperties
{
	DefenseClass = class'RenX_Game.Rx_Defence_GuardTower'
	BuildOffset = (X=0.0,Y=0.0,Z=230.0)
	BuildClearRadius = 150.f
	VisualMesh = SkeletalMesh'RX_DEF_GuardTower.Mesh.SK_DEF_GuardTower'
	WeaponIconTexture=Texture2D'RX_DEF_GuardTower.UI.T_VehicleIcon_GuardTower'
	Price = 750
}
