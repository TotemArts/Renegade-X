/**
* Simple Dummies used for shooting targets 
* [Should likely be attached to a factory]
*/

class Rx_RangeDummy_Flak extends Rx_RangeDummy_NoArmour
placeable; 

DefaultProperties
{
	ActorName = "Dummy[Flak Armour]" 
	ArmorType = ARM_Flak
	bUseInfantryArmour = true 
	
	Begin Object Name=WSkeletalMesh	
		SkeletalMesh=SkeletalMesh'rx_ch_gdi_soldier.Mesh.SK_CH_GDI_Grenadier'
	End Object
	Mesh=WSkeletalMesh
	Components.Add(WSkeletalMesh)

}	