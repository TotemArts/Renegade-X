class Rx_Building_TechBuildingPoint_Internals extends Rx_Building_TechBuilding_Internals;

simulated function Init(Rx_Building Visuals, bool isDebug )
{
	super.Init(Visuals,isDebug);
	SetupCapturePoint();
}

function SetupCapturePoint()
{
   local Rx_Building_TechbuildingPoint Point;
   local float CapRadius;
   local float CapHeight;
   local byte StartTeam;


   if(Rx_Building_TechBuildingPoint(BuildingVisuals) != None)
   {
   		Point = Rx_Building_TechbuildingPoint(BuildingVisuals);
   		CP = Spawn(Point.CapturePointClass,self,,BuildingVisuals.Location,BuildingVisuals.Rotation);
         Point.CP = CP;
   		if(Point.CaptureVolume == None)
   		{
	   		CapRadius = Point.CaptureRadius;
   			CapHeight = Point.CaptureHeight;

   			CylinderComponent(CP.CollisionComponent).SetCylinderSize(CapRadius,CapHeight);
   		}
   		else
   		{
   			CP.SetCollision(false,CP.bBlockActors,CP.bIgnoreEncroachers); // disable collision
   			Point.CaptureVolume.CapturePoint = CP;
   		}

         CP.Pointname = GetBuildingName();

         StartTeam = Rx_Building_Techbuilding(BuildingVisuals).StartingTeam;
   
         if(StartTeam <= 1)
         {
            CP.bCaptured = true;
            CP.CapturingTeam=StartTeam;
            CP.CaptureProgress=1;
            CP.GotoState('CapturedIdle');
         }
   } 

}
//disable old method...
function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType);

DefaultProperties
{
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh        		= SkeletalMesh'RX_BU_CommCentre.Meshes.SK_BU_CommCentre'
		AnimSets(0)         		= AnimSet'RX_BU_CommCentre.Anims.AS_BU_CommCentre'
		AnimTreeTemplate    		= AnimTree'RX_BU_CommCentre.Anims.AT_BU_CommCentre'
		PhysicsAsset     			= PhysicsAsset'RX_BU_CommCentre.Meshes.SK_BU_CommCentre_Physics'
		bEnableClothSimulation 	 	= False
		bClothAwakeOnStartup   	 	= False
		// ClothWind              	 	= (X=100.000000,Y=100.000000,Z=20.000000)
	End Object

	AttachmentClasses.Remove(Rx_BuildingAttachment_MCT)
}