class Rx_BuildingObjective extends Rx_GameObjective
	placeable;

var()	Rx_Building	myBuilding;
var int DamageCapacity;
var float LastWarnTime;
var NavigationPoint InfiltrationPoint;
var bool bAlreadyReported;

replication
{
   if (bNetInitial && (Role==ROLE_Authority))
      myBuilding;
}


simulated function PostBeginPlay()
{
	local Rx_Building BI, NearestBuilding;
	local int NearestBuildingDistance; 
	local array<NavigationPoint> NavPoints;
	local NavigationPoint N,BestN;
	local float Dist, BestDist;
	
	NearestBuildingDistance = -1; 
	//Failed to find a building objective
	if(ROLE == ROLE_Authority && myBuilding == none){
		foreach WorldInfo.AllActors(class'Rx_Building', BI){
			if(NearestBuildingDistance == -1 || VSizeSq(location-BI.location) < NearestBuildingDistance){
				NearestBuildingDistance = VSizeSq(location-BI.location);
				NearestBuilding=BI; 
			}
		}
	myBuilding=NearestBuilding; 
	}		
	
	DefenderTeamIndex = myBuilding.ScriptGetTeamNum();
	DamageCapacity = myBuilding.GetMaxArmor();
	if(Rx_Building_GDI_InfantryFactory(myBuilding) != None) {
		bFirstObjective = true;
	}
	myBuilding.myObjective = self;

	BestDist = 10000000;

	class'NavigationPoint'.static.GetAllNavInRadius(myBuilding.GetMCT(),myBuilding.GetMCT().location,1000.0,NavPoints);
	
		Foreach NavPoints(N)
		{
			if(N.PathList.Length <= 0)
				continue;
 
			Dist = VSizeSq(myBuilding.GetMCT().location - N.location);

			if(Dist <= BestDist)
			{
				BestDist = Dist;
				BestN = N;
			}	
		}

	InfiltrationPoint = BestN;



	super.PostBeginPlay();
}

/* returns objective's progress status 1->0 (=disabled) */
simulated function float GetObjectiveProgress()
{
	if ( bIsDisabled )
		return 0;
	return myBuilding.GetHealth()/myBuilding.GetMaxHealth();
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	myBuilding.Health = myBuilding.GetMaxHealth();
	super.Reset();
}

function bool NearObjective(Pawn P)
{
	if ( P.CanAttack(myBuilding) )
		return true;
	return super.NearObjective(P);
}

function AIReported()
{
	if(!IsCritical())
	{
		bAlreadyReported = true;
		SetTimer(15.0,false,'ClearAIReport');
	}
}

function ClearAIReport()
{
	bAlreadyReported = false;
}

function bool Shootable()
{
	return true;
}


simulated function bool NeedsHealing()
{

		return (!bIsDisabled && myBuilding.GetArmor() < myBuilding.GetMaxArmor());
}

function Actor GetShootTarget(UTBot B)
{	
	local Rx_BuildingAttachment MCT;
	local Rx_Weapon_DeployedC4 C4;

	MCT = myBuilding.GetMCT();

	if(myBuilding.IsA('Rx_Building_Techbuilding'))
	{
		return MCT;
	}

	if(B.GetTeamNum() == myBuilding.GetTeamNum())
	{

		if(isCritical() && !B.LineOfSightTo(MCT))
			return myBuilding;

		if (Vehicle(B.Pawn) == none && (IsCritical() || B.LineOfSightTo(MCT)))
		{
			if(IsCritical())
				return MCT;
			
			else
			{
				foreach VisibleCollidingActors(class 'Rx_Weapon_DeployedC4', C4, 300, MCT.Location)
				{	
					if(C4 != None && C4.TeamNum != B.GetTeamNum())
						return C4;
				}
			}
		}
	}
	else if(B.LineOfSightTo(MCT))
		return MCT;

	return myBuilding;
	
}

simulated event bool IsCritical()
{
	if(myBuilding.GetArmor() < myBuilding.GetMaxArmor()/2)
		return true;

	return false;
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

	if(Rx_Bot(B).BaughtVehicle != None)
		return false;

	if(myBuilding.IsA('Rx_Building_Techbuilding'))
	{	
		if (myBuilding.GetTeamNum() == B.GetTeamNum() && myBuilding.GetHealth() >= myBuilding.GetMaxHealth())
		{
			UTTeamGame(WorldInfo.Game).FindNewObjectives(self);
			return false;
		}
		else 
		{
			TellBotHowToHeal(B);
			return true;
		}
		
	}
	if(myBuilding.GetTeamNum() == B.GetTeamNum())
	{
		return TellBotHowToHeal(B);
	}
	
	if (myBuilding.GetTeamNum() != B.GetTeamNum() && Vehicle(B.Pawn) == None 
		&& (Rx_Weapon(B.Pawn.InvManager.FindInventoryType(Class'Rx_Weapon_TimedC4', true)).HasAnyAmmo() 
		|| Rx_Weapon(B.Pawn.Weapon).bOkAgainstBuildings))
	
	{
		Rx_Bot(B).bInfiltrating = true;
		if(Rx_Bot(B).FindInfiltrationPath())
		{
			if(B.LineOfSightTo(myBuilding.GetMCT()) && B.CanAttack(myBuilding.GetMCT()))
			{
				Rx_Bot(B).AssaultMCT();
			}
			return true;
		}	

		return false;
	
	}
	else if(Vehicle(B.Pawn) != None)
	{
		if(B.CanAttack(myBuilding))
		{
			if(B.Enemy == None || KillEnemyFirstBeforeAttacking(B))
			{
				B.DoRangedAttackOn(myBuilding);
			}
			
			else
			{

				return false;
			}
			
			return true;
		}
		else
		{
			if(B.Enemy != None)
			{
				if(!KillEnemyFirstBeforeAttacking(B))
					return Rx_Bot(B).FindVehicleAssaultPath();
				else
					return false;
			}
		}
	}

	else if ( !B.Pawn.bStationary && B.Pawn.Weapon != None && B.Pawn.TooCloseToAttack(GetShootTarget(B)) )
	{
		Rx_Bot(B).bInfiltrating = false;
		B.GoalString = "Back off from objective";
		B.RouteGoal = B.FindRandomDest();
		B.MoveTarget = B.RouteCache[0];
		B.SetAttractionState();
		return true;
	}
	else if ( B.CanAttack(GetShootTarget(B)) )
	{
		Rx_Bot(B).bInfiltrating = false;

		if (KillEnemyFirstBeforeAttacking(B))
			return false;		
		
		B.GoalString = "Attack Objective";

		B.DoRangedAttackOn(GetShootTarget(B));
		return true;
	}

	Rx_Bot(B).bInfiltrating = false;
	
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

	if (Rx_Bot(B).IsHealing(False) && (B.Focus == myBuilding.GetMCT() || Rx_Weapon_Deployable(B.Focus) != None))
	{
		Rx_Bot(B).GoToState('Defending','Healing');
		return true;
	}

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

	if(Rx_Building_Techbuilding(myBuilding) != None && Rx_Bot(B).HasRepairGun())
	{
		B.SwitchToBestWeapon();
		if(B.CanAttack(myBuilding.GetMCT()))
			B.DoRangedAttackOn(myBuilding.GetMCT());

		return true;
	}


//DEPRECATED	-	The Bot knows exactly what to do in their Defending state
/*
	if (UTWeapon(B.Pawn.Weapon) != None && UTWeapon(B.Pawn.Weapon).CanHeal(myBuilding))
	{
		
		if (!B.Pawn.CanAttack(GetShootTarget(B)))
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
		B.Focus = GetShootTarget(B);
		B.GoalString = "Heal "$myBuilding;
		B.DoRangedAttackOn(GetShootTarget(B));
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

			if(InfiltrationPoint != None)
			{
				B.FindBestPathToward(InfiltrationPoint,true,true);
				B.GoalString = "Move closer to "$B.DefensePoint$" for healing";
				B.SetAttractionState();
				return true;
			}

			if (!B.Pawn.CanAttack(GetShootTarget(B)))
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
			B.DoRangedAttackOn(GetShootTarget(B));
			return true;
		}
		if (B.FindInventoryGoal(0.0005)) // try to find a weapon to heal the objective
		{
			B.GoalString = "Find weapon or ammo to heal "$myBuilding;
			B.SetAttractionState();
			return true;
		}

	}
*/
	if (OldVehicle != None)
	{
		OldVehicle.UsedBy(B.Pawn);
	}

	if(Rx_Bot(B).HasRepairGun() && B.GetOrders() == 'DEFEND')
	{
		B.MoveToDefensePoint();
		return true;
	}

	return false;
}

private function bool FindClosestDefensePointForHealing(UTBot B) {
	
	local UTDefensePoint DefensePoint, BestPoint;
	local float ShortestDist;
	
	BestPoint = B.DefensePoint;
	
	if(BestPoint != None && BestPoint.DefendedObjective == Self && Rx_Weapon(B.Pawn.Weapon).CanAttackFromPosition(BestPoint.location, GetShootTarget(B))) {
		ShortestDist = VSizeSq(BestPoint.location - B.location);
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
			|| !Rx_Weapon(B.Pawn.Weapon).CanAttackFromPosition(DefensePoint.location, GetShootTarget(B))) {
			continue;
		}
		
		if(ShortestDist == 0 || VSizeSq(DefensePoint.location - B.location) < ShortestDist) {
			BestPoint = DefensePoint;
			ShortestDist = VSizeSq(DefensePoint.location - B.location);
		} 	
	}
	
	if(BestPoint == None) {
		return false;
	}
	
	if(FRand() > 0.7) {
		DefensePoint = BestPoint.NextDefensePoint;
		if(DefensePoint != None && DefensePoint.DefendedObjective == Self
			&& Rx_Weapon(B.Pawn.Weapon).CanAttackFromPosition(DefensePoint.location, GetShootTarget(B))) {
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

function float CalcDefensePriority(Controller C)
{
	local float Distance, DistanceMod, ArmorMod, HealthMod, DefendersMod;

	if(myBuilding.IsDestroyed())			// There really is no need to defend a destroyed building :v
		return 0;

	DefendersMod = 750 / (1 + GetNumDefenders()); // We don't wanna run into null number
	ArmorMod = 1000 + (10 *(myBuilding.GetMaxArmor() - myBuilding.GetArmor()));
	
	if(C.Pawn == None)
		Distance = 0;
	else
		Distance = VSizeSq(C.Pawn.Location - InfiltrationPoint.Location);
	
	DistanceMod = 1000000 + Distance;
	
	if (C.Enemy != None && VSizeSq(C.Enemy.Location - InfiltrationPoint.Location) < Distance)
	{

		DistanceMod *= 5;
	}

	if(DefensePriority == 0)
	{
		DefensePriority = 1;
	}

	if(myBuilding.GetMaxArmor() > myBuilding.GetArmor())
		return (ArmorMod + DistanceMod + DefendersMod) * (DefensePriority + 1) / 5;

	if(myBuilding.GetHealth() <= myBuilding.GetMaxHealth())
		return (DistanceMod + DefendersMod) * (DefensePriority + 1) / 5;

	HealthMod = 3000 / GetObjectiveProgress();
	
	return (HealthMod + DistanceMod + DefendersMod) * (DefensePriority + 1) / 5;

}

function DisableBuildingObjective() 
{
	bIsDisabled = true;
	UTTeamGame(WorldInfo.Game).FindNewObjectives(self);	
}

function bool IsDisabled() {
	return bIsDisabled;
}

event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	if(myBuilding.GetArmor() >= myBuilding.GetMaxArmor()) {
		if(UTBot(Healer) != None) {
			UTTeamGame(WorldInfo.Game).Teams[UTBot(Healer).GetTeamNum()].AI.PutOnDefense(UTBot(Healer));
		}
	}
	return true;
}

function int HealthDiff() {
	return DamageCapacity - myBuilding.GetArmor();
}

function DisableUnderAttack() {
	bUnderAttack = false;	
}

function bool KillEnemyFirstBeforeHealing(UTBot B)
{
	//local float Dist;
	
	if(B.Enemy == None || !B.Pawn.CanAttack(B.Enemy)) 
	{
		return false;
	}
	
	//Dist = VSize(B.Enemy.Location - B.Location);
	
	if( B.Enemy.Controller != None && !bUnderAttack 
			&& myBuilding.GetArmor() > DamageCapacity * 0.7) 
	{
		if(Rx_Weapon_RepairGun(B.Pawn.Weapon) != None) 
		{ 
			B.SwitchToBestWeapon(true);
		}
		return true;	
	}
	
	if ( myBuilding.GetArmor() < myBuilding.GetMaxArmor() * 0.5 ) 
	{
		return false;
	}
	else if (B.Enemy.Controller != None 
				&& ((B.Enemy.Controller.Focus == B.Pawn) || (B.LastUnderFire > WorldInfo.TimeSeconds - 1.5))
				&& B.Enemy.CanAttack(B.Pawn) ) 
	{
		if(Rx_Weapon_RepairGun(B.Pawn.Weapon) != None) 
		{ 
			B.SwitchToBestWeapon(true);
		}
		return true;
	}
	
	return false;
}

function bool KillEnemyFirstBeforeAttacking(UTBot B)
{
	
	//use bUnderAttack aswell ?
	if(B.Enemy.Health <= 0 || !B.CanAttack(B.Enemy))
		return false;

	if(Rx_Vehicle(B.Pawn) != None) 
	{
		if(!Rx_Vehicle(B.Pawn).bOkAgainstBuildings) 
		{
			return (B.CanAttack(B.Enemy));
		}
		else if(B.CanAttack(myBuilding))
		{
			if(myBuilding.GetArmor() < myBuilding.GetMaxArmor() * 0.4 && myBuilding.GetHealth() < myBuilding.GetMaxHealth() * 0.25)
				return false;

			else if(Vehicle(B.Enemy) != None)
			{
				if(B.Enemy.Weapon != None && Rx_Vehicle_Weapon(B.Enemy.Weapon).bOkAgainstArmoredVehicles)
					return true;
			}
			else if(Rx_Weapon(B.Enemy.Weapon) != None && Rx_Weapon(B.Enemy.Weapon).bOkAgainstVehicles)
				return true;

		}

		return false;
	} 
	else if(!Rx_Weapon(B.Pawn.Weapon).bOkAgainstBuildings || Rx_Weapon(B.Pawn.Weapon).IsA('Rx_Weapon_Deployable')) 
	{
		return true;
	}
	
	else if (B.Enemy != None && B.Enemy.Controller != None) 
	{
		if(((B.Enemy.Controller.Focus == B.Pawn) || (B.LastUnderFire > WorldInfo.TimeSeconds - 1.5)) && B.Enemy.CanAttack(B.Pawn) ) 
		{
			if(Rx_Weapon_RepairGun(B.Pawn.Weapon) != None) 
			{ 
				B.SwitchToBestWeapon(true);
			}		
			return true;
		} 
		else if(Rx_Weapon_RepairGun(B.Enemy.Weapon) != None && B.CanAttack(B.Enemy)) 
		{
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