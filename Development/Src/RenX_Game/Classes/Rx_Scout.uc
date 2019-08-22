// This is the "scout class" for RenegadeX
// It is not a real character or other game element.
// It exists for helping pathfinding and navmesh generation.
// The unreal engine will use this as the object to work out if a path is viable.

class Rx_Scout extends UTScout;

defaultproperties
{

	Begin Object NAME=CollisionCylinder
		CollisionRadius=+0020.000000
	End Object
	
	PrototypePawnClass = class'RenX_Game.Rx_Pawn'
	SizePersonFindName = Human;
	PathSizes.Empty
	PathSizes(0)=(Desc=Crouched,Radius=10,Height=40)
	PathSizes(1)=(Desc=Human,Radius=20,Height=60) // Human
/*	PathSizes(2)=(Desc=VehClass1,Radius=258,Height=187) //Humvee, S Tank, Med Tank
	PathSizes(3)=(Desc=VehClass2,Radius=250,Height=539) //Titan
	PathSizes(4)=(Desc=VehClass3,Radius=321,Height=248) //Arty,MLRS,Harv,AAPC, TS Arty
	PathSizes(5)=(Desc=Common,Radius=396,Height=242) //Mammoth
	PathSizes(6)=(Desc=VehClass5,Radius=470,Height=550) //Juggernaut
	PathSizes(7)=(Desc=Max,Radius=645,Height=770) //MMK2
*/
	PathSizes(2)=(Desc=Small,Radius=60,Height=100)
	PathSizes(3)=(Desc=PlayerCommon,Radius=200,Height=100) // Most T2 vehicles, but not Harvester
	PathSizes(4)=(Desc=Common,Radius=240,Height=100) // Harvester
	PathSizes(5)=(Desc=Max,Radius=300,Height=125) // Mammoth Tank
	PathSizes(6)=(Desc=ExtraLarge,Radius=400,Height=250)
	PathSizes(7)=(Desc=Vehicle,Radius=650,Height=250)

	EdgePathColors.Empty
	EdgePathColors(0)=(R=0,G=0,B=255)
	EdgePathColors(1)=(R=0,G=100,B=255)
	EdgePathColors(2)=(R=128,G=128,B=255)
	EdgePathColors(3)=(R=0,G=255,B=0)
	EdgePathColors(4)=(R=0,G=255,B=255)
	EdgePathColors(5)=(R=255,G=128,B=0)
	EdgePathColors(6)=(R=255,G=255,B=255)

	TestJumpZ=350
	TestGroundSpeed=600
	TestMaxFallSpeed=2500
	TestFallSpeed=1200
	WalkableFloorZ=0.7f
	LedgeCheckThreshold=300.0f
	MaxJumpHeight=450
	//MinNumPlayerStarts=1
	//DefaultReachSpecClass=class'Engine.Reachspec'

	NavMeshGen_StepSize=10
	NavMeshGen_MaxGroundCheckSize=10.0f
	NavMeshGen_EntityHalfHeight=30
	NavMeshGen_StartingHeightOffset=40
	NavMeshGen_MaxDropHeight=300.0
	//NavMeshGen_MaxStepHeight=35.0
	NavMeshGen_VertZDeltaSnapThresh=40.0
	NavMeshGen_MinPolyArea=20
	//NavMeshGen_BorderBackfill_CheckDist=140.0
	//NavMeshGen_MinMergeDotAreaThreshold=2.0
	//NavMeshGen_MinMergeDotSmallArea=0.0
	NavMeshGen_MinMergeDotLargeArea=0.75
	NavMeshGen_MaxPolyHeight=770
	//NavMeshGen_HeightMergeThreshold=20
	//NavMeshGen_EdgeMaxDelta=20.0
	//NavMeshGen_MinEdgeLength=7.0
	//NavMeshGen_ExpansionDoObstacleMeshSimplification=FALSE

	MinMantleFallDist=300
	MaxMantleFallDist=800
	MinMantleLateralDist=300
	MaxMantleLateralDist=800
	MaxMantleFallTime=300
}