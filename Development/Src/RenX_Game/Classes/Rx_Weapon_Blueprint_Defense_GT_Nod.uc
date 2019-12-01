class Rx_Weapon_Blueprint_Defense_GT_Nod extends Rx_Weapon_Blueprint_Defense;

DefaultProperties
{
	DefenseClass = class'RenX_Game.Rx_Defence_GuardTower_Nod'
	BuildOffset = (X=0.0,Y=0.0,Z=230.0)
	BuildClearRadius = 200.f
	VisualMesh = SkeletalMesh'RX_DEF_GuardTower.Mesh.SK_DEF_GuardTower'
	WeaponIconTexture=Texture2D'RX_DEF_GuardTower.UI.T_WeaponIcon_GuardTower'
	PTIconTexture=Texture2D'RX_DEF_GuardTower.UI.T_PTIcon_GuardTower'
	Price = 750
}
