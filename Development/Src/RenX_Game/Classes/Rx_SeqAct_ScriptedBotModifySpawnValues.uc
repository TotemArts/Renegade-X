class Rx_SeqAct_ScriptedBotModifySpawnValues extends SequenceAction;

var(Spawner) Array<Actor> SpawnPoints;					// Places where bots can spawn
var(Spawner) int SpawnNumber;							// The number of spawn until spawner is disabled. set to 0 or lower for infinite
var(Spawner) int MaxSpawn;								// Maximum amount of existing bots. Set to 0 for indefinite amount
var(Spawner) bool bModifyTypes;
var(Spawner) Array<class<Rx_FamilyInfo> > CharTypes;	// Type of squad to spawn
var(Spawner) Array<class<Rx_Vehicle> > VehicleTypes;		// Type of Vehicles the squad will spawn with
var(Spawner) float SpawnInterval;						// How often the spawn occurs
var(Spawner) bool bCheckPlayerLOS;
var(Combat) bool bInvulnerableBots;
var(Combat) float DamageDealtModifier;					// Determines the multiplier of this bot's damage
var(Combat) float DamageTakenModifier;					// Determines the multiplier of the damage this bot takes from others
var(Combat) float Skill;


defaultproperties
{
	ObjName="Modify Spawner Values"
	ObjCategory="Ren X Scripted Bots"
	
	
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawner Object")

	HandlerName = "OnModifySpawn"

	DamageDealtModifier = 1.f
	DamageTakenModifier = 1.f
	Skill = 5.f
}