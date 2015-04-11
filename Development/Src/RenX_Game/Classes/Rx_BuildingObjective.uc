class Rx_BuildingObjective extends UTGameObjective
	placeable;

var()	Rx_Building	myBuilding;
var int DamageCapacity;
var float LastWarnTime;

replication
{
   if (bNetInitial && (Role==ROLE_Authority))
      myBuilding;
}


simulated function PostBeginPlay()
{  
	DefenderTeamIndex = myBuilding.ScriptGetTeamNum();
	DamageCapacity = myBuilding.HealthMax;
	if(Rx_Building_Barracks(myBuilding) != None) {
		bFirstObjective = true;
	}
	myBuilding.myObjective = self;
	super.PostBeginPlay();
}

/* returns objective's progress status 1->0 (=disabled) */
simulated function float GetObjectiveProgress()
{
	if ( bIsDisabled )
		return 0;
	return myBuilding.GetHealth()/DamageCapacity;
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	myBuilding.Health = DamageCapacity;
	super.Reset();
}

function bool NearObjective(Pawn P)
{
	if ( P.CanAttack(myBuilding) )
		return true;
	return super.NearObjective(P);
}

function bool Shootable()
{
	return true;
}

simulated function bool NeedsHealing()
{
	return (!bIsDisabled && myBuilding.GetHealth() < DamageCapacity);
}

function Actor GetShootTarget()
{
	return myBuilding;
}

simulated event bool IsCritical()
{
	return false; // make true when it needs immediate defense
}

event actor GetBestViewTarget()
{
	return myBuilding;
}

/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(UTBot B)
{
	
	if ( !B.Pawn.bStationary && B.Pawn.Weapon != None && B.Pawn.TooCloseToAttack(GetShootTarget()) )
	{
		B.GoalString = "Back off from objective";
		B.RouteGoal = B.FindRandomDest();
		B.MoveTarget = B.RouteCache[0];
		B.SetAttractionState();
		return true;
	}
	else if ( B.CanAttack(GetShootTarget()) )
	{
		
		if (KillEnemyFirstBeforeAttacking(B))
			return false;		
		
		B.GoalString = "Attack Objective";
		B.DoRangedAttackOn(GetShootTarget());
		return true;
	}
	
	if(B.Enemy != None) {
		return false;
	}	

	MarkShootSpotsFor(B.Pawn);
	return super.TellBotHowToDisable(B);
}

/* TellBotHowToHeal()
tell bot what to do to heal me
return true if valid/useable instructions were given
*/
function bool TellBotHowToHeal(UTBot B)
{
	local UTVehicle OldVehicle;

	if (DefenderTeamIndex != B.GetTeamNum() || !NeedsHealing())
	{
		return false;
	}
	
	if (KillEnemyFirstBeforeHealing(B))
		return false;		

	if (B.Squad.SquadObjective == None)
	{
		if (Vehicle(B.Pawn) != None)
		{
			return false;
		}
		// @hack - if bot has no squadobjective, need this for SwitchToBestWeapon() so bot's weapons' GetAIRating()
		// has some way of figuring out bot is trying to heal me
		B.DoRangedAttackOn(myBuilding);
	}

	OldVehicle = UTVehicle(B.Pawn);
	if (OldVehicle != None)
	{
		if (!OldVehicle.bKeyVehicle && (B.Enemy == None || (!B.LineOfSightTo(B.Enemy) && WorldInfo.TimeSeconds - B.LastSeenTime > 3)))
		{
			OldVehicle.DriverLeave(false);
		}
		else
		{
			OldVehicle = None;
		}
	}

	if (UTWeapon(B.Pawn.Weapon) != None && UTWeapon(B.Pawn.Weapon).CanHeal(myBuilding))
	{
		
		if (!B.Pawn.CanAttack(GetShootTarget()))
		{
			// need to move to somewhere else near objective
			if(FindClosestDefensePointForHealing(B)) {
				B.GoalString = "Move closer to "$B.DefensePoint$" for healing";
				B.SetAttractionState();
				return true;
			} else if ( B.FindBestPathToward(self, false, true) ) {
				B.GoalString = "Move closer to "$self$" for healing";
				B.SetAttractionState();
				return true;
			} else {
				return false;
			}
		}
		B.GoalString = "Heal "$myBuilding;
		B.DoRangedAttackOn(GetShootTarget());
		return true;
	}
	else
	{
		B.Pawn.InvManager.NextWeapon();
		if(Rx_Weapon_RepairGun(B.Pawn.Weapon) == None) {
			B.Pawn.InvManager.NextWeapon();
		}
		if (UTWeapon(B.Pawn.InvManager.PendingWeapon) != None && UTWeapon(B.Pawn.InvManager.PendingWeapon).CanHeal(myBuilding))
		{
			if (!B.Pawn.CanAttack(GetShootTarget()))
			{
				// need to move to somewhere else near objective
				if(FindClosestDefensePointForHealing(B)) {
					B.GoalString = "Move closer to "$B.DefensePoint$" for healing";
					B.SetAttractionState();
					return true;
				} else if ( B.FindBestPathToward(self, false, true) ) {
					B.GoalString = "Move closer to "$self$" for healing";
					B.SetAttractionState();
					return true;
				} else {
					return false;
				}
			}
			B.GoalString = "Heal "$myBuilding;
			B.DoRangedAttackOn(GetShootTarget());
			return true;
		}
		if (B.FindInventoryGoal(0.0005)) // try to find a weapon to heal the objective
		{
			B.GoalString = "Find weapon or ammo to heal "$myBuilding;
			B.SetAttractionState();
			return true;
		}
	}

	if (OldVehicle != None)
	{
		OldVehicle.UsedBy(B.Pawn);
	}

	return false;
}

private function bool FindClosestDefensePointForHealing(UTBot B) {
	
	local UTDefensePoint DefensePoint, BestPoint;
	local float ShortestDist;
	
	BestPoint = B.DefensePoint;
	
	if(BestPoint != None && BestPoint.DefendedObjective == Self && Rx_Weapon(B.Pawn.Weapon).CanAttackFromPosition(BestPoint.location, GetShootTarget())) {
		ShortestDist = VSize(BestPoint.location - B.location);
	} else {
		ShortestDist = 0;
	}
	for (DefensePoint = DefensePoints; DefensePoint != None; DefensePoint = DefensePoint.NextDefensePoint) {
	
		/**
		if(DefensePoint == None) {
			break;
		}
		*/
		if(DefensePoint.DefendedObjective != Self 
			|| !Rx_Weapon(B.Pawn.Weapon).CanAttackFromPosition(DefensePoint.location, GetShootTarget())) {
			continue;
		}
		
		if(ShortestDist == 0 || VSize(DefensePoint.location - B.location) < ShortestDist) {
			BestPoint = DefensePoint;
			ShortestDist = VSize(DefensePoint.location - B.location);
		} 	
	}
	
	if(BestPoint == None) {
		return false;
	}
	
	if(FRand() > 0.7) {
		DefensePoint = BestPoint.NextDefensePoint;
		if(DefensePoint != None && DefensePoint.DefendedObjective == Self
			&& Rx_Weapon(B.Pawn.Weapon).CanAttackFromPosition(DefensePoint.location, GetShootTarget())) {
			BestPoint = DefensePoint;		
		}
	}
	return B.FindBestPathToward(BestPoint, false, true);
}

function TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (Damage <= 0 || bIsDisabled)
		return;

	if ( myBuilding.GetHealth() < 1 ) 
	{
		DisableBuildingObjective();
	}
	else
	{
		if ( WorldInfo.TimeSeconds - LastWarnTime > 0.5 )
		{
			LastWarnTime = WorldInfo.TimeSeconds;
			if ( (InstigatedBy != None) && (DefenseSquad != None) )
				UTTeamInfo(DefenseSquad.Team).AI.CriticalObjectiveWarning(self, instigatedBy.Pawn);
		}
		bUnderAttack = true;
		SetTimer(3.0, false, 'DisableUnderAttack');
	}
	//DefensePriority++
}

function DisableBuildingObjective() {
	bIsDisabled = true;
	UTTeamGame(WorldInfo.Game).FindNewObjectives(self);	
}

function bool IsDisabled() {
	return bIsDisabled;
}

event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	if(myBuilding.GetHealth() >= myBuilding.GetMaxHealth()) {
		if(UTBot(Healer) != None) {
			UTTeamGame(WorldInfo.Game).Teams[UTBot(Healer).GetTeamNum()].AI.PutOnDefense(UTBot(Healer));
		}
	}
	return true;
}

function int HealthDiff() {
	return DamageCapacity - myBuilding.GetHealth();
}

function DisableUnderAttack() {
	bUnderAttack = false;	
}

function bool KillEnemyFirstBeforeHealing(UTBot B)
{
	//local float Dist;
	
	if(B.Enemy == None || UTVehicle(B.Enemy) != None || !B.Pawn.CanAttack(B.Enemy)) {
		return false;
	}
	
	//Dist = VSize(B.Enemy.Location - B.Location);
	
	if( B.Enemy.Controller != None && !bUnderAttack 
			&& myBuilding.GetHealth() > DamageCapacity * 0.7) {
		if(Rx_Weapon_RepairGun(B.Pawn.Weapon) != None) { 
			B.SwitchToBestWeapon(true);
		}
		return true;	
	}
	
	if ( myBuilding.GetHealth() < DamageCapacity * 0.2 ) {
		return false;
	}
	else if (B.Enemy.Controller != None 
				&& ((B.Enemy.Controller.Focus == B.Pawn) || (B.LastUnderFire > WorldInfo.TimeSeconds - 1.5))
				&& B.Enemy.CanAttack(B.Pawn) ) {
		if(Rx_Weapon_RepairGun(B.Pawn.Weapon) != None) { 
			B.SwitchToBestWeapon(true);
		}
		return true;
	}
	
	return false;
}

function bool KillEnemyFirstBeforeAttacking(UTBot B)
{
	
	//use bUnderAttack aswell ?
	
	if(Rx_Vehicle(B.Pawn) != None) {
		if(!Rx_Vehicle(B.Pawn).bOkAgainstBuildings) {
			return true;
		}
	} else if(!Rx_Weapon(B.Pawn.Weapon).bOkAgainstBuildings) {
		return true;
	}
	
	if ( myBuilding.GetHealth() < DamageCapacity * 0.2  && UTVehicle(B.Pawn) != None)
	{
		return false;
	}
	else if (B.Enemy != None && B.Enemy.Controller != None) {
		if(((B.Enemy.Controller.Focus == B.Pawn) || (B.LastUnderFire > WorldInfo.TimeSeconds - 1.5)) && B.Enemy.CanAttack(B.Pawn) ) {
			if(Rx_Weapon_RepairGun(B.Pawn.Weapon) != None) { 
				B.SwitchToBestWeapon(true);
			}		
			return true;
		} else if(Rx_Weapon_RepairGun(B.Enemy.Weapon) != None && B.CanAttack(B.Enemy)) {
			return true;	
		}
	}
	
	return false;
}

defaultproperties
{

	BaseRadius=+3000.0
	bStatic=false
	bNoDelete=false
	bFirstObjective=false
	bCollideWhenPlacing=true
	//Components.Remove(CollisionCylinder)
	bMustBeReachable = true
	//bNotBased = false
	bMustTouchToReach = false
	bDestinationOnly = false
	bSourceOnly = false
	bBlocked = false
}