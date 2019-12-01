class Rx_Weapon_Blueprint_Defense_Turret_Nod extends Rx_Weapon_Blueprint_Defense;

DefaultProperties
{
	DefenseClass = class'RenX_Game.Rx_Defence_Turret'
	BuildOffset = (X=0.0,Y=0.0,Z=70.0)
	BuildClearRadius = 300.f
	VisualMesh = SkeletalMesh'RX_DEF_Turret.Mesh.SK_DEF_Turret'
	WeaponIconTexture=Texture2D'RX_DEF_Turret.UI.T_WeaponIcon_Turret'
	PTIconTexture=Texture2D'RX_DEF_Turret.UI.T_PTIcon_Turret'
	Price = 750
}
