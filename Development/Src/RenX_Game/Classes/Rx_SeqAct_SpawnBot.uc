//Custom SeqAct in Kismet for spawning RenX Bots with specific Infantry Classes (and inventory) in Ren X. Made by j0g32. www.renegade-x.com
// Custom SeqAct in Kismet for spawning RenX Bots with specific Infantry Classes (and inventory) in Ren X. Made by j0g32. www.renegade-x.com

class Rx_SeqAct_SpawnBot extends SeqAct_Latent; // extends SequenceAction

var() bool	bEnabled;

var() byte	TeamNum;		// Team: 0=GDI, 1=Nod


var() array<class<Rx_FamilyInfo> >  ClassList;	// Add infantry classes to the Squad - will all spawn everytime

var() float SpawnWaveDelay;	// Time between spawning squads/waves
var() int	MaxNumSquads;	// Maximum number of Squads that can be active at the same time
var  int	NumActiveSquads;	// Number of active (spawned) Squads
//var	bool	bActive;	// is TRUE until MAXNumSqwuad reached. // already defined

//var	 array<Rx_Pawn>  PawnList;

struct Squad
{
	//var	int SquadIndex;					// can derived dynamically?
	var	 array<Rx_Pawn>  SquadPawnList;
};

var	array<Squad>	SquadList;	// 2-dimensional array of squads and squad members therein


var vector  SpawnLocation;
var rotator SpawnRotation;

var() Actor SpawnPoint;

var float RadiusForRandomSpawn;		// Radius [uu] around SpawnPoint, since units cannot spawn in the exact same location



event Activated()
{
	
	if(InputLinks[0].bHasImpulse)		// Spawn Squad/Bot
	{	
		bActive=true;
		Kismet_AddSquad();
	}
	else if(InputLinks[1].bHasImpulse)	// Enable
		bEnabled=true;
	else /*if(InputLinks[2].bHasImpulse)*/	// Disable
		bEnabled=false;
}


event bool Update(float DT)
{
	if(NumActiveSquads<MaxNumSquads)
	return true;
	
	OutputLinks[1].bHasImpulse = true;
	return false;
}



function Kismet_AddSquad()
{
	bActive=true;
	SquadList[Squadlist.Length]=Kismet_SpawnSquad();
}



function Squad Kismet_SpawnSquad()
{

	/** VARIABLES **/
	
	local int i;
	local Rx_Pawn NewPawn;
	local Squad NewSquad;
	local SeqVar_Object ObjVar;		// local needed for attached spawnpoints
	
	local array<SequenceObject> ObjectList;	// needed to create Kismet references (objectlist)
	local SeqVar_ObjectList SeqVar_ObjectList;	// the variable (list) that will be output to Kismet

	
	/** ACTIONS **/
	
	if(!bEnabled)
	{
		//GetWorldInfo().Game.ClearTimer('Kismet_SpawnSquad'); // stop any active timers?
		bActive=false;
		return NewSquad;		//exit the Squad Spawn function (whenever it is called)
	}
	
	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "SpawnPoint")		
	{
		SpawnPoint=Actor(ObjVar.GetObjectValue()); // Get SpawnPoint Actor from Kismet References
	}
	
	
	// override SpawnLocation/Rotation vectors with those of SpawnPoint Actor
	if(SpawnPoint!=None)
	{
		SpawnLocation=SpawnPoint.Location;
		SpawnRotation=SpawnPoint.Rotation;
	}
	
	if(NumActiveSquads<MaxNumSquads) // only (try) to spawn if you have "slots" available
	{
		
		RadiusForRandomSpawn = ((ClassList.Length)^0.5)*64;		// Radius = sqrt(length) * 
	
		for(i=0; i<ClassList.Length; i++)
		{
			NewPawn=Kismet_SpawnBot(SpawnLocation, RadiusForRandomSpawn, ClassList[i]);		// Spawn new Bot and assign to local
			NewSquad.SquadPawnList[i]=NewPawn;
			
			/* Get the object list seq var */
			GetLinkedObjects(ObjectList, class'SeqVar_ObjectList', false);

			if (ObjectList.Length > 0)
			{
				SeqVar_ObjectList = SeqVar_ObjectList(ObjectList[0]);

				if (SeqVar_ObjectList != None)
				{
					SeqVar_ObjectList.ObjList.AddItem(NewPawn);		// Add the new pawn to the list.
				}
			}
			
		}

		NumActiveSquads++;
		ActivateOutputLink(0);

		if(NumActiveSquads==MaxNumSquads)
		{
			GetWorldInfo().Game.ClearAllTimers(self);
			ActivateOutputLink(1);	// All Squads have been succesfully spawned
			bActive=false;		// deactivate for Update
		}
		else
		{
			GetWorldInfo().Game.SetTimer(SpawnWaveDelay, true, 'Kismet_AddSquad', self);		// repeat timer
		}
		return NewSquad;
	}
}



function Rx_Pawn Kismet_SpawnBot(vector spawnLoc, float radForRandomSpawn, class<Rx_FamilyInfo> NewClass)
{
		
	local vector NewSpawnLocation;
	local Rx_Pawn NewPawn;
		
	NewPawn=None;
		
	while(NewPawn==None)
	{
		NewSpawnLocation = spawnLoc;
		NewSpawnLocation.X = spawnLoc.X + radForRandomSpawn*(FRand()-0.5)*2;
		NewSpawnLocation.Y = spawnLoc.Y + radForRandomSpawn*(FRand()-0.5)*2;

		NewPawn = GetWorldInfo().Game.spawn(class'Rx_Pawn',,,NewSpawnLocation,SpawnRotation);
	}
			

	GetWorldInfo().Game.spawn(class'Rx_Bot').possess(NewPawn, false);		// spawn controller and assign it, no reference.
	AIController(NewPawn.Controller).SetTeam(TeamNum);
	
	if(NewPawn != None && NewClass != None)
			Rx_PRI(NewPawn.PlayerReplicationInfo).SetChar(NewClass, NewPawn);

	return NewPawn;
			
}
		

defaultproperties
{
	ObjName="Spawn RenX Bot"
	ObjCategory="Ren X"
	
	InputLinks(0)=(LinkDesc="Spawn Squad/Bot")
	InputLinks(1)=(LinkDesc="Enable")
	InputLinks(2)=(LinkDesc="Disable")
	
	OutputLinks(0)=(LinkDesc="Squad/Bot spawned")
	OutputLinks(1)=(LinkDesc="All Squads/Bots spawned")
	//OutputLinks(2)=(LinkDesc="Squad/Bot eliminated")
	//OutputLinks(3)=(LinkDesc="All Squads/Bots eliminated")
	
	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawn Point",PropertyName=SpawnPoint,bWriteable=false)
	VariableLinks(1)=(ExpectedType=class'SeqVar_ObjectList',LinkDesc="BotPawns spawned",/*PropertyName=ObjectList,*/bWriteable=true)
	
	
	bCallHandler=false
	bAutoActivateOutputLinks=false
	
	
	bEnabled=true
	SpawnWaveDelay=3.0
	MaxNumSquads=1
}
