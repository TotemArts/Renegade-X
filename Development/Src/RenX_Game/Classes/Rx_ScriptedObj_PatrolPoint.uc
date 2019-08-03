class Rx_ScriptedObj_PatrolPoint extends Rx_GameObjective
	placeable;

var(ScriptedPatrol) Array<Actor> PatrolPoints;
var(ScriptedPatrol) bool bWalkingPatrol;
var(ScriptedPatrol) bool bUseSpecificStart;
var(ScriptedPatrol) int StartNum;