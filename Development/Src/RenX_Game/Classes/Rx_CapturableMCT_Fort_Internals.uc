class Rx_CapturableMCT_Fort_Internals extends Rx_CapturableMCT_Internals
   notplaceable;

var SkeletalMeshComponent FortFlag;
var MaterialInstanceConstant FortFlagMat;

simulated function Init(Rx_Building Visuals, bool isDebug )
{
	local SkeletalMeshActor SM;
	super.Init(Visuals, isDebug);

	foreach AllActors(class 'SkeletalMeshActor',SM)
	{
		if (SM.tag == 'FortFlag')
		{
			FortFlag = SM.SkeletalMeshComponent;
			break;
		}
	}

	MICFlag = FortFlag.CreateAndSetMaterialInstanceConstant(0);
	FlagChanged();
	Armor=0;
}

DefaultProperties
{
   TeamID          = 255
}