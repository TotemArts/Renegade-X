class Rx_CapturableMCT_MC_Internals extends Rx_CapturableMCT_Internals
   notplaceable;

var SkeletalMeshComponent MCFlag;
var MaterialInstanceConstant MCFlagMat;

simulated function Init(Rx_Building Visuals, bool isDebug )
{
	local SkeletalMeshActor SM;
	super.Init(Visuals, isDebug);

	foreach AllActors(class 'SkeletalMeshActor',SM)
	{
		if ( SM.tag == 'MCFlag')
		{
			MCFlag = SM.SkeletalMeshComponent;
			break;		
		}
	}

	MICFlag = MCFlag.CreateAndSetMaterialInstanceConstant(0);
	FlagChanged();
	Armor=0;
}

DefaultProperties
{
   TeamID          = 255
}