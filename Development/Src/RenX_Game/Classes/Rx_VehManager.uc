
class Rx_VehManager extends Actor;

// struct for the queue elements
struct VQueueElement
{
   var Rx_PRI Buyer;
   var int          VehID;
};
// used for production place cache
struct ProductionPlacePair
{
   var Vector V;
   var Rotator R;
};

var array<Rx_TeamInfo>              	  Teams;
var Rx_Game                               RGame;
var private array<Vehicle>                stolenByNOD, stolenByGDI; // stolen vehicles by team
var private float                         ProductionDelay;
var private array<ProductionPlacePair>    ProductionPlaces; // chached array for building places and rotation
var private array<ProductionPlacePair>    Paths_NOD, Paths_GDI;
var private int                           curPathNod, curPathGDI;
var private array<VQueueElement>          GDI_Queue, NOD_Queue;
var private UTVehicle                     lastSpawnedVehicle;


function Initialize(GameInfo Game, array<TeamInfo> T)
{

}

function vehChangedTeam(UTVehicle V)
{
   if (V.GetTeamNum() == 0)
   {
      if (stolenByGDI.Find(V) >= 0)
         stolenByGDI.RemoveItem(V);
      if (v.default.Team != 0)
         stolenByNOD.AddItem(V);
   }
   else
   {
      if (stolenByNOD.Find(V) >= 0)
         stolenByNOD.RemoveItem(V);
      if (v.default.Team != 1)
         stolenByGDI.AddItem(V);
   }
}

defaultproperties
{
   ProductionDelay                  = 5.5f
   bOnlyDirtyReplication            = true
   bSkipActorPropertyReplication    = true
   bAlwaysRelevant                  = true
}