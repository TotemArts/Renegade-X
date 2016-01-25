// Custom Building interface made by Ruud033. It uses a SeqAct in Kismet to set it's values for custom maps and mods used in Renegade-X. www.renegade-x.com

class Rx_Building_Interface extends Rx_BuildingAttachment implements (Rx_ObjectTooltipInterface)
   placeable;

var() StaticMeshComponent Mesh;
var() repnotify TEAM TeamNum;
var() repnotify string BuildingName;
var() string tooltip;

replication
{
	if(bNetDirty && Role == ROLE_Authority)
		TeamNum, BuildingName;
}

function OnModifyBuilding(Rx_SeqAct_Modify_Interface FireAction)
{
    local int KismetTeamNum;
    local string KismetBuildingName;

    KismetTeamNum = FireAction.TeamNumber;
    KismetBuildingName = FireAction.BuildingName;

   `log("Updating BuildingName through Kismet");

    TeamNum = TEAM(KismetTeamNum);
    BuildingName = KismetBuildingName;
}

simulated function bool IsTouchingOnly()
{
   return true;
}

simulated function bool IsBasicOnly()
{
   return false;
}

simulated function string GetHumanReadableName()
{
   return BuildingName;
}

simulated event byte ScriptGetTeamNum()
{
   return TeamNum;
}

simulated function string GetTooltip(Rx_Controller PC)
{
   if (PC.GetTeamNum() == GetTeamNum() && class'Rx_Utils'.static.OrientationToB(self, PC.Pawn) > 0.1)
      return Repl(tooltip, "{GBA_USE}", Caps(UDKPlayerInput(PC.PlayerInput).GetUDKBindNameFromCommand("GBA_Use")), true);
   return "";
}

defaultproperties
{
   SpawnName     = "_PT"
   SocketPattern = "Pt_"
   CollisionType       = COLLIDE_TouchAllButWeapons
   RemoteRole          = ROLE_SimulatedProxy
   bCollideActors = True
   BuildingName = "Default Building Name"
   TeamNum = 255
   tooltip = ""
      
   Begin Object Class=StaticMeshComponent Name=MeshCmp
      StaticMesh                   = StaticMesh'EngineMeshes.Cube'
      CollideActors                = True
      BlockActors                  = True
      BlockRigidBody               = True
      BlockZeroExtent              = True
      BlockNonZeroExtent           = True
      bCastDynamicShadow           = False //true
      bAcceptsDynamicLights        = False //true
      bAcceptsLights               = True
      bAcceptsDecalsDuringGameplay = True
      bAcceptsDecals               = True
      RBChannel                    = RBCC_Pawn
      RBCollideWithChannels        = (Pawn=True)
   End Object
   Components.Add(MeshCmp)
   Mesh = MeshCmp
   
}