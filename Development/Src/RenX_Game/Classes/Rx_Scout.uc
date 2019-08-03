// This is the "scout class" for RenegadeX
// It is not a real character or other game element.
// It exists for helping pathfinding and navmesh generation.
// The unreal engine will use this as the object to work out if a path is viable.

class Rx_Scout extends UTScout;

defaultproperties
{
	
	PrototypePawnClass = class'RenX_Game.Rx_Pawn'
	SizePersonFindName = Human;

	PathSizes(0)=(Desc=Crouched,Radius=16,Height=35)
	PathSizes(1)=(Desc=Human,Radius=16,Height=50)
/*	PathSizes(2)=(Desc=VehClass1,Radius=258,Height=187) 
	PathSizes(3)=(Desc=VehClass2,Radius=250,Height=539) 
	PathSizes(4)=(Desc=VehClass3,Radius=321,Height=248) 
	PathSizes(5)=(Desc=Common,Radius=396,Height=242) 
	PathSizes(6)=(Desc=VehClass5,Radius=470,Height=550) 
	PathSizes(7)=(Desc=Max,Radius=645,Height=770) 
*/
	PathSizes(2)=(Desc=Small,Radius=30,Height=60)
	PathSizes(3)=(Desc=Common,Radius=60,Height=100)
	PathSizes(4)=(Desc=Max,Radius=200,Height=100)
	PathSizes(5)=(Desc=Vehicle,Radius=260,Height=100)	

/*
	EdgePathColors(0)=(R=0,G=128,B=255)
	EdgePathColors(1)=(R=0,G=0,B=255)
	EdgePathColors(2)=(R=255,G=0,B=0)
	EdgePathColors(3)=(R=255,G=0,B=255)
	EdgePathColors(4)=(R=0,G=255,B=0)
	EdgePathColors(5)=(R=255,G=0,B=128)
	EdgePathColors(6)=(R=0,G=128,B=128)
	EdgePathColors(7)=(R=128,G=128,B=0)
*/
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
	NavMeshGen_EntityHalfHeight=40
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