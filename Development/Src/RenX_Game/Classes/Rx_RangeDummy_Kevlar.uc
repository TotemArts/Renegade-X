/**
* Simple Dummies used for shooting targets 
* [Should likely be attached to a factory]
*/

class Rx_RangeDummy_Kevlar extends Rx_RangeDummy_NoArmour
placeable; 

DefaultProperties
{
	ActorName = "Dummy[Kevlar Armour]" 
	ArmorType = ARM_Kevlar
	bUseInfantryArmour = true 
	
	Begin Object Name=WSkeletalMesh	
		SkeletalMesh=SkeletalMesh'rx_ch_gdi_soldier.Mesh.SK_CH_GDI_soldier'
	End Object
	Mesh=WSkeletalMesh
	Components.Add(WSkeletalMesh)

}	