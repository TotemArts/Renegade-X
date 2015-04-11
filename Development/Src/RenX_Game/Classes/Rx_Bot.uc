/*********************************************************
*
* File: RxBot.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile: 
*
*********************************************************
*  
*********************************************************/
class Rx_Bot extends UTBot;

var class<Rx_BotCharInfo> CharInfoClass;
var int TargetMoney;
var int DeathsTillTargetMoneySwitch;
var int BaughtVehicleIndex; // vehicle i just baught and want to get in to
var Rx_Vehicle BaughtVehicle; // vehicle i just baught and want to get in to
var name OrdersBeforeBaughtVehicle;
var UTVehicle shouldWaitVehicle;
var bool bWaitingAtAreaSpot;
var Rx_AreaObjective ClosestNextRO;
var Rx_BuildingObjective ClosestEnemyBO;
var Rx_Sentinel_Obelisk_Laser_Base Obelisk;
var Rx_Sentinel_AGT_Rockets_Base AGT;
var float ReevaluateAreaObjectiveTime;
var bool bStrafingDisabled;
var bool bAttackingEnemyBase;
var bool bInvalidatePreviousSO; // set after death so that bot forgets about its previous SquadObjective and picks a new one on next occasion
var int WaitingInAreaCount;
var int CantAttackCheckCount;
var bool bCheckIfBetterSoInCurrentGroup;
var Actor tempActor;
var float lastFindStrafeDestTime;

/** Relative locations within target's bounding cylinder to try to aim at when failed to aim at the target's location. */

function Initialize(float InSkill, const out CharacterInfo BotInfo)
{
	local UTPlayerReplicationInfo PRI;

	super.Initialize(InSkill, BotInfo);
	//super.Initialize(4.0, BotInfo);

	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	PRI.CharClassInfo = CharInfoClass.static.FindFamilyInfo("Soldier_SINGLEPLAYER");
	setStrafingDisabled(true);
	SetTimer(0.5,true,'ConsiderStartSprintTimer');
}

function PawnDied(Pawn P)
{
	if ( Pawn != P )
		return;
	Super.PawnDied(P);
	bAttackingEnemyBase = false;
	bInvalidatePreviousSO = true;
}

function bool ShouldFireAgain()
{
	local Rx_Weapon_Reloadable RxWeap;
	local float Rand;

	RxWeap = Rx_Weapon_Reloadable(Pawn.Weapon);
	if( RxWeap != none )
	{
		if( RxWeap.CurrentlyReloading )
		{
			if(Pawn.IsFiring())
				StopFiring();
			return false;
		}
		if(RxWeap.RecoilSpreadIncreasePerShot != 0.0) {
			if(Enemy != None && RxWeap.Recoilspread > 0.0 && VSize(Enemy.location - Pawn.location) > 200) {
				Rand = FRand();
				if(Rand < 0.1 || (Rand > 0.6 && RxWeap.CurrentSpread >= RxWeap.MaxSpread)) {
					if(Pawn.IsFiring())
						StopFiring();
					return false;
				}
			}
		}
	} else if(Rx_Vehicle_Weapon_Reloadable(Pawn.Weapon) != None && Rx_Vehicle_Weapon_Reloadable(Pawn.Weapon).CurrentlyReloading)
	{
		if(Pawn.IsFiring())
			StopFiring();
		return false;	
	}
	return super.ShouldFireAgain();
}

event NotifyFallingHitWall( vector HitNormal, actor HitActor)
{
	bNotifyFallingHitWall = false;
}

function bool TryWallDodge(vector HitNormal, actor HitActor)
{
	// no wall dodging in our game
}

function ResetSkill()
{
	super.ResetSkill();
	DodgeToGoalPct = 0; // since our dodges dont get you to a goal faster the bots should not try to do that
}

function bool TryToDuck(vector duckDir, bool bReversed)
{
	local Rx_Pawn rxPawn;
	if(Rx_Pawn(Pawn) != None) {
		rxPawn = Rx_Pawn(Pawn);
		if(rxPawn.bDodging || !rxPawn.bDodgeCapable || rxPawn.Physics != Phys_Walking) {
			if ( Stopped() )
				GotoState('TacticalMove');
			return false;
		}
	}
	return super.TryToDuck(duckDir, bReversed);
}

function bool CanImpactJump() {
	return false;
}

function TimedFireWeaponAtFocus()
{
	bResetCombatTimer = false;
	if (Focus == None || FireWeaponAt(Focus))
	{
		if (!bResetCombatTimer)
		{
			SetCombatTimer();
		}
	}
	else if (!bResetCombatTimer)
	{
		SetTimer(0.1, true);
	}
}

state RangedAttack
{

	function bool WeaponFireAgain(bool bFinishedFire)
	{
		local bool ret;
		ret = global.WeaponFireAgain(bFinishedFire);
		if(!ret && UTVehicle(Pawn) != None && !bPreparingMove 
			&& NavigationPoint(RouteGoal) != None 
			&& (WorldInfo.TimeSeconds - lastFindStrafeDestTime > 1 + Rand(2))
			&& (Pawn.ReachedDestination(RouteGoal) 
				|| (Pawn.Acceleration == vect(0,0,0) 
					&& Rx_Vehicle_Weapon_Reloadable(Pawn.Weapon) != None
					&& !Rx_Vehicle_Weapon_Reloadable(Pawn.Weapon).CurrentlyReloading 
					&& VSize(pawn.Velocity) < 5.0 
					&& MoveTimer < 23))) 
		{
			if (FindStrafeDest())
			{
				GotoState(,'FindStrafeDest');
			}			
		}
		return ret;
	}

    function StopFiring()
    {
		if ( !(Pawn != None && Focus != None && Pawn(Focus) != None && Pawn(Focus).Health <= 0)
					 && Pawn.RecommendLongRangedAttack() && Pawn.IsFiring() ) {
            return;
        }
        Global.StopFiring();
        if ( bHasFired )
        {
            if ( IsSniping() && !WorldInfo.bUseConsoleInput )
            {
                Pawn.bWantsToCrouch = (Skill > 2);
            }
            else
            {
                bHasFired = false;
                WhatToDoNext();
            }
        }
    }
	
	function bool FindStrafeDestForHealingPlayer() {
		local float Dist;
		local int Start, i;
		local NavigationPoint Nav;
		local Rx_Weapon RxWeap;

		if (!Pawn.bCanStrafe || Pawn.Weapon == None)
		{
			return false;
		}

		RxWeap = Rx_Weapon(Pawn.Weapon);
		// get on path network if not already
		if (!Pawn.ValidAnchor())
		{
			Pawn.SetAnchor(Pawn.GetBestAnchor(Pawn, Pawn.Location, true, true, Dist));
			if (Pawn.Anchor == None)
			{
				// can't get on path network
				return false;
			}
			else
			{
				if (Dist > Pawn.CylinderComponent.CollisionRadius)
				{
					if ( RxWeap.CanAttackFromPosition(Pawn.Anchor.location, Focus) )
					{
						if(Pawn.Anchor != MoveTarget)
							MoveTarget = Pawn.Anchor;
						return true;
					}
					else
					{
						// can't shoot target from best anchor
						return false;
					}
				}
			}
		}
		else if (Pawn.Anchor.PathList.length > 0)
		{
			// pick a random point linked to anchor that we can shoot target from
			Start = Rand(Pawn.Anchor.PathList.length);
			i = Start;
			do
			{
				if (!Pawn.Anchor.PathList[i].IsBlockedFor(Pawn))
				{
					Nav = Pawn.Anchor.PathList[i].GetEnd();
					if (Nav != Focus && !Nav.bSpecialMove && !Nav.IsA('Teleporter'))
					{
						// allow points within range, that aren't significantly backtracking unless allowed,
						// and that we can still hit target from
						Dist = VSize(Nav.Location - Focus.Location);
						if ( RxWeap.CanAttackFromPosition(Nav.location, Focus) )
						{
							if(Pawn.Anchor != Nav)
								MoveTarget = Nav;
							return true;
						}
					}
				}
				i++;
				if (i == Pawn.Anchor.PathList.length)
				{
					i = 0;
				}
			} until (i == Start);
		}

		return false;
	}
	
	
	function bool FindStrafeDest()
	{
		local float Dist, TargetDist, MaxRange;
		local int Start, i;
		local bool bAllowBackwards;
		local NavigationPoint Nav;
		local UTWeapon UTWeap;
		local bool bOkStrafeSpot;
		
		lastFindStrafeDestTime = WorldInfo.TimeSeconds;
		if(Vehicle(Pawn) == None) {
			return super.FindStrafeDest();
		}
		if(Vehicle(Pawn) != None) {
			StrafingAbility = 1;	
		} else if(IsHealing(false)) {
			return FindStrafeDestForHealingPlayer();
		} else {
			return super.FindStrafeDest();
		}
		if (!Pawn.bCanStrafe || Pawn.Weapon == None || Skill + StrafingAbility < 1.5 + 3.5 * FRand())
		{
			// can't strafe, no weapon to check distance with or not skilled enough
			return false;
		}

		UTWeap = UTWeapon(Pawn.Weapon);
		MaxRange = (UTWeap != None ? UTWeap.GetOptimalRangeFor(Focus) : Pawn.Weapon.MaxRange());
		// get on path network if not already
		if (!Pawn.ValidAnchor())
		{
			Pawn.SetAnchor(Pawn.GetBestAnchor(Pawn, Pawn.Location, true, true, Dist));
			if (Pawn.Anchor == None)
			{
				// can't get on path network
				return false;
			}
			else
			{
				Dist = VSize(Pawn.Anchor.Location - Focus.Location);
				bOkStrafeSpot = Dist <= MaxRange;
				if(bOkStrafeSpot) {
					bOkStrafeSpot = FastTrace(Focus.Location, Pawn.Anchor.Location);
				}
				if(bOkStrafeSpot && UTVehicle(Pawn) != None) {
					if(VolumePathNode(Pawn.Anchor) != None && !UTVehicle(Pawn).bCanFly) {
						bOkStrafeSpot = false;
					} else {
						bOkStrafeSpot = NavBlockedByVeh(Pawn.Anchor);
					}
				}
				if (bOkStrafeSpot )
				{
					if(Pawn.Anchor != MoveTarget)
						MoveTarget = Pawn.Anchor;
					return true;
				}
				else
				{
					// can't shoot target from best anchor
					//`log("Failed to move cause Anchor failed. Have"@Pawn.Anchor.PathList.length@"Paths"); 
				}
			}
		} 
		
		if (Pawn.Anchor.PathList.length > 0)
		{
			TargetDist = VSize(Focus.Location - Pawn.Location);
			// consider backstep opposed to always charging if enemy objective, depending on combat style and weapon
			if (!WorldInfo.GRI.OnSameTeam(Focus, self))
			{
				bAllowBackwards = (CombatStyle + (UTWeap != None ? UTWeap.SuggestAttackStyle() : 0.0) <= 0.0);
				//bAllowBackwards = false;
				//loginternal(bAllowBackwards);
			}
			// pick a random point linked to anchor that we can shoot target from
			Start = Rand(Pawn.Anchor.PathList.length);
			i = Start;
			do
			{
				if (!Pawn.Anchor.PathList[i].IsBlockedFor(Pawn))
				{
					Nav = Pawn.Anchor.PathList[i].GetEnd();
					if (Nav != Focus && !Nav.bSpecialMove && !Nav.IsA('Teleporter'))
					{
						// allow points within range, that aren't significantly backtracking unless allowed,
						// and that we can still hit target from
						Dist = VSize(Nav.Location - Focus.Location);
						
						//======================
						bOkStrafeSpot = FastTrace(Focus.Location, Nav.Location);
						bOkStrafeSpot = !Nav.bBlocked;
						if(bOkStrafeSpot && Rx_BuildingObjective(Squad.SquadObjective) == None && NavCanBeHitByAO(Nav)) {
							bOkStrafeSpot = false;	
						}
						
						if(bOkStrafeSpot && UTVehicle(Pawn) != None) {
							if(VolumePathNode(Nav) != None && !UTVehicle(Pawn).bCanFly) {
								bOkStrafeSpot = false;
							} else {							
								bOkStrafeSpot = NavBlockedByVeh(Nav);
							}
						}
						if ( (Dist <= MaxRange || Dist < TargetDist) && (bAllowBackwards || Dist <= TargetDist + 100.0) &&
							bOkStrafeSpot )
						{
							if(Pawn.Anchor != Nav)
								MoveTarget = Nav;
							return true;
						}
					}
				}
				i++;
				if (i == Pawn.Anchor.PathList.length)
				{
					i = 0;
				}
			} until (i == Start);
		}

		return false;
	}

Begin:
	bHasFired = false;
	
	if(Focus != Enemy && Rx_Vehicle(Focus) != None && !Rx_Vehicle(Focus).NeedsHealing() && isHealing(true)) {
		sleep(0.2);
		SetCombatTimer();
        StopFiring();
		LatentWhatToDoNext();
	}
	
	if ( (Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon 
			|| (Rx_Weapon_RepairGun(Pawn.Weapon) == None && IsHealing(true)) )
		SwitchToBestWeapon();		
	GoalString = GoalString@"Ranged attack";
	Sleep(0.0);
	if ( (Focus == None) || Focus.bDeleteMe )
		LatentWhatToDoNext();
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	if ( Pawn.NeedToTurn(GetFocalPoint()) )
	{
		FinishRotation();
	}
	bHasFired = true;
	if(CantAttackCheckCount > 10) {
		CantAttackCheckCount = 0;
	} else {
		if ( Focus == Enemy )
			TimedFireWeaponAtEnemy();
		else if (Focus != None && (Rx_Building(Focus) != None || UTVehicle(Focus) != None)) 
			TimedFireWeaponAtFocus();
		else
			FireWeaponAt(Focus);	
	}	
	Sleep(0.1);
	if ( ((Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon) || (Focus == None) || ((Focus != Enemy) 
			&& (UTGameObjective(Focus) == None) 
			&& (Rx_Building(Focus) == None)
			&& (Enemy != None) && LineOfSightTo(Enemy)) )
		LatentWhatToDoNext();
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	if (FindStrafeDest())
	{
FindStrafeDest:	
		GoalString = GoalString $ ", strafe to" @ MoveTarget;
		if(UTVehicle(Pawn) != None) {
			MoveToward(MoveTarget, Focus,, false, false);
		} else {
			MoveToward(MoveTarget, Focus,, true, false);
		}
		StopMovement();
	}
	else
	{
		Sleep(FMax(Pawn.RangedAttackTime(),0.2 + (0.5 + 0.5 * FRand()) * 0.4 * (7 - Skill)));
	}
LatentWhatToDoNextRangedAttack:	
	LatentWhatToDoNext();
	if ( bSoaking )
		SoakStop("STUCK IN RANGEDATTACK!");
	GoalString = "STUCK IN RANGEDATTACK!";
}

simulated function Actor GetFocus() {
	return Focus;
}

function bool NavBlockedByVeh(NavigationPoint Nav)
{
	local UTVehicle veh;
	local bool bOkStrafeSpot;
	
	bOkStrafeSpot = true;
	if(UTVehicle(Pawn) != None && Nav.bBlockedForVehicles) {
		return false;
	}
	ForEach CollidingActors(class'UTVehicle', veh, 500, Nav.location)
	{
		if(veh != Pawn) {
			if(VSize(veh.location - Nav.location) < VSize(Pawn.location - veh.location)) {
				
				// wenn veh sich von nav wegbewegt und gleichzeitig nicht auf mich zufährt
				if(VSize(veh.velocity) > 80 
						&& ( (veh.Throttle > 0.5 && class'Rx_Utils'.static.OrientationToB(veh,Nav) < 0.4) 
								|| (veh.Throttle < -0.5 && class'Rx_Utils'.static.OrientationToB(veh,Nav) > 0.4) )) {
					//DrawDebugLine(Pawn.location,veh.location,255,0,0,true);
					//DrawDebugLine(Pawn.location,Nav.location,0,255,0,true);	
					continue;
				}
				bOkStrafeSpot = false; // so that we dont ramm into vehicles
				
				//DrawDebugLine(Pawn.location,veh.location,255,0,0,true);
				//DrawDebugLine(Pawn.location,Nav.location,0,255,0,true);
				//DrawDebugSphere(veh.location,700,10,255,0,0,true);
				break;
			}
		}
	}
	return bOkStrafeSpot;
} 

function bool CanAttack(Actor Other)
{
	local bool ret;
	ret = super.CanAttack(Other);
	if(!ret) {
		CantAttackCheckCount++;
	} else {
		CantAttackCheckCount = 0;
	}
	return ret;
}

function bool NavCanBeHitByAO(Navigationpoint Nav) 
{
	if(GetTeamNum() == TEAM_GDI) {
		if(Obelisk == None) GetObelisk();
		if(Obelisk != None) {
			if(FastTrace(Obelisk.location, Nav.Location)) {
				return true;
			}
		}
	} else if(GetTeamNum() == TEAM_NOD) {
		if(AGT == None) GetAGT();
		if(AGT != None) {
			if(FastTrace(AGT.location, Nav.Location)) {
				return true;
			}
		}
	}
	return false;
}

function bool DefendedBuildingNeedsHealing() {

	if(DefensePoint != None && DefensePoint.DefendedObjective != None 
		&& Rx_BuildingObjective(DefensePoint.DefendedObjective) != None 
		&& Rx_BuildingObjective(DefensePoint.DefendedObjective).NeedsHealing()) {
		
		return true;
	}
	return false;
}

state Defending
{
	function BeginState(Name PreviousStateName)
	{
		bShortCamp = (Vehicle(Pawn) == None);
		super.BeginState(PreviousStateName);
		if(DefendedBuildingNeedsHealing() && HasRepairGun()) {
			Rx_BuildingObjective(DefensePoint.DefendedObjective).TellBotHowToHeal(Self);			
		}
	}
	
	function SetRouteGoal()
	{
		bShortCamp = (Vehicle(Pawn) == None);
		super.SetRouteGoal();
	}	
}

function MoveToDefensePoint()
{
	if(IsInState('Defending')) { 
		if(DefendedBuildingNeedsHealing() && HasRepairGun()) {
			Rx_BuildingObjective(DefensePoint.DefendedObjective).TellBotHowToHeal(Self);			
		}
	}
	GotoState('Defending', 'Begin');
}

function bool ShouldDefendPosition()
{
    if(bStrafingDisabled && Pawn.Anchor == None) {
    	return false;
    }
    
    if(IsHealing(false)) {
    	DoRangedAttackOn(Focus);
		return true;
    }
    
    if(DefensePoint != None && Rx_BuildingObjective(Squad.SquadObjective).NeedsHealing() && HasRepairGun()) {
    	MoveToDefensePoint();
    	return true;
    }
    
    return super.ShouldDefendPosition();
}

function bool IsHealing(bool bOrAboutToHeal) {
    if(IsInState('RangedAttack') || bOrAboutToHeal) {
    	if(!bOrAboutToHeal && bStoppedFiring) {
    		return false;
    	}
    	if(Rx_Building(Focus) != None && Rx_Building(Focus).GetTeamNum() == GetTeamNum() 
    			&& Rx_Building(Focus).myObjective.NeedsHealing()) {
    		return true;
    	} else if(Rx_BuildingObjective(Focus) != None && Rx_BuildingObjective(Focus).GetTeamNum() == GetTeamNum() 
    			&& Rx_BuildingObjective(Focus).NeedsHealing()) {
    		return true;
    	} else  if(UTVehicle(Focus) != None && (UTVehicle(Focus).GetTeamNum() == GetTeamNum() || UTVehicle(Focus).GetTeamNum() == 255)) {
    		if(Rx_Vehicle(Focus).NeedsHealing() || bOrAboutToHeal) {
    			return true;
			}
    	}
    }
    return false;
}

function bool CanStakeOut()
{
	if(Pawn.Weapon != None && Rx_Weapon_RepairGun(Pawn.Weapon) != None) {
		return false;
	}
	return super.CanStakeOut();
}

exec function SwitchToBestWeapon(optional bool bForceNewWeapon)
{
	if(Rx_Weapon_RepairGun(Pawn.InvManager.GetBestWeapon(false)) != None) {
	
		if(IsHealing(true)) {
			if(Rx_Weapon_RepairGun(Pawn.Weapon) != None) {
				return;
			} else {
				super.SwitchToBestWeapon(true);
			}	
		}
		
		if(Rx_Weapon_RepairGun(Pawn.Weapon) != None) {
			if(Enemy != None) {
				super.SwitchToBestWeapon(true);	
			}
		}
		return;
	}
	super.SwitchToBestWeapon(bForceNewWeapon);
}

function bool HasRepairGun()
{
	local class<UTFamilyInfo> FamInfo;

	FamInfo = Rx_Pri(PlayerReplicationInfo).CharClassInfo;
	
	if( Rx_Game(WorldInfo.Game).PurchaseSystem.DoesHaveRepairGun( FamInfo ) ) 
	{
		return true;
	}

	return false;
	
}

/** called when a ReachSpec the AI wants to use is blocked by a dynamic obstruction
 * gives the AI an opportunity to do something to get rid of it instead of trying to find another path
 * @note MoveTarget is the actor the AI wants to move toward, CurrentPath the ReachSpec it wants to use
 * @param BlockedBy the object blocking the path
 * @return true if the AI did something about the obstruction and should use the path anyway, false if the path
 * is unusable and the bot must find some other way to go
 */
event bool HandlePathObstruction(Actor BlockedBy){
	//loginternal("HandlePathObstruction");
	return super.HandlePathObstruction(BlockedBy);
}

function int GetCredits() {
	return Rx_Pri(PlayerReplicationInfo).GetCredits();	
}

function int GetNewTargetMoney() {	
	if(GetOrders() == 'Defend') {
		if (FRand() <= 0.6) {
			return 350;
		}
		if (FRand() <= 0.6) {
			return 500;
		}
		if (FRand() <= 0.6) {
			return 750;
		}
		return 225;
	}
	if(GetTeamNum() == TEAM_GDI) {
		return GetNewTargetMoneyGDI();
	} else {
		return GetNewTargetMoneyNod();
	}
}

function int GetNewTargetMoneyGDI() {	
	local float Rand;
	local int CurrentCredits;
	
	CurrentCredits = Rx_Pri(PlayerReplicationInfo).GetCredits();
	Rand = FRand();
	
	if (Rand <= 0.5) {
		if (CurrentCredits < 225) {
			return 225;	
		} else if (CurrentCredits < 500) {
			return 500;
		} else {
			return 900;
		}
	} else if (Rand < 0.8) {
		if (CurrentCredits < 225) {
			return 225;	
		} else if (CurrentCredits < 500) {
			return 750;
		} else {
			return 900;
		}	
	} else {
		if (CurrentCredits < 225) {
			return 500;	
		} else if (CurrentCredits < 500) {
			return 900;
		} else {
			if(FRand() <= 0.5) {
				return 1500;
			}
			return 900;
		}
	}
}

function int GetNewTargetMoneyNod() {	
	local float Rand;
	local int CurrentCredits;
	
	CurrentCredits = Rx_Pri(PlayerReplicationInfo).GetCredits();
	Rand = FRand();
	if (Rand < 0.5) {
		if (CurrentCredits < 225) {
			return 225;	
		} else if (CurrentCredits < 500) {
			return 500;
		} else {
			return 600;
		}
	} else if (Rand < 0.8) {
		if (CurrentCredits < 225) {
			return 225;	
		} else if (CurrentCredits < 500) {
			return 750;
		} else {
			return 900;
		}	
	} else {
		if (CurrentCredits < 225) {
			return 500;	
		} else if (CurrentCredits < 500) {
			return 800;
		} else {
			return 900;
		}
	}
}

function SetBaughtVehicle(int vehIndex) {
	BaughtVehicleIndex = vehIndex;
	if(BaughtVehicleIndex == -1) {
		BaughtVehicle = None;
	}
	OrdersBeforeBaughtVehicle = GetOrders();
}

function bool AssignSquadResponsibility()
{
	if(Rx_Vehicle(Pawn) != None && Enemy != None && !Rx_Vehicle(Pawn).ValidEnemyForVehicle(Enemy)) {
		//loginternal("LoseEnemy");
		Enemy = None;
		//LoseEnemy();
	}	

    if(bStrafingDisabled && Pawn.Anchor == None) {
    	return false;
    }	
	if(BaughtVehicleIndex != -1) {
		if(GoToBaughtVehicle()) {
			return true;
		}
	} 
	
	if(UTVehicle(Pawn) == None && HasRepairGun()) {
		if(RepairCloseVehicles()) {
			return true;		
		}
	}
	return super.AssignSquadResponsibility();
}

function bool GoToBaughtVehicle() {
	local Rx_BuildingObjective BO;

	if(Squad != None && BaughtVehicle != None) {
		if(Rx_SquadAi(Squad).GotoVehicle(BaughtVehicle, self))
			return true;
	}
	
	if(GetTeamNum() == TEAM_GDI) {	
		BO = Rx_Game(WorldInfo.Game).GetPurchaseSystem().WeaponsFactory.myObjective;
	} else {
		BO = Rx_Game(WorldInfo.Game).GetPurchaseSystem().AirTower.myObjective;
	}
	if ( BO.DefenseSquad == None )
		BO.DefenseSquad = Rx_TeamInfo(PlayerReplicationInfo.Team).AI.AddSquadWithLeader(self, BO);
	else
		BO.DefenseSquad.AddBot(self);
		
	if(bStrafingDisabled && Pawn.Anchor == None) {
		WanderOrCamp();
		return true;	
	}
	self.GotoState('Defending');	
	return true;
}

function bool RepairCloseVehicles() {
	local float NewDist,BestDist;
	local UTVehicle V,VehToHeal;
	local bool bVisible, bDefending, bShouldRepVehs;
	local int BuildingHealtDiff;
	
	local vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	local actor HitActor;
	local float TraceDist;	
		
	bShouldRepVehs = true;
	if(GetOrders() == 'DEFEND') {
		bDefending = true;
		if(Squad != None && Rx_BuildingObjective(Squad.SquadObjective) != None 
			&& Rx_BuildingObjective(Squad.SquadObjective).NeedsHealing()) {
			BuildingHealtDiff = Rx_BuildingObjective(Squad.SquadObjective).HealthDiff();
			if(BuildingHealtDiff >= 500 || Rx_BuildingObjective(Squad.SquadObjective).bUnderAttack) {
				bShouldRepVehs = false;	
			}	
		}
	}
	
	VehToHeal = None;
	if(bShouldRepVehs) {
		for ( V=UTGame(WorldInfo.Game).VehicleList; V!=None; V=V.NextVehicle )
		{
			if(VehToHeal != None && Rx_Vehicle_Harvester(V) != None)
				continue; // prefer non harvesters
			if(V.GetTeamNum() != GetTeamNum()) {
				continue;
			}
			if(bDefending 
				&& VSize(V.location - Rx_BuildingObjective(Squad.SquadObjective).GetShootTarget().location) > 2500 ) {
				continue;
			}
			
			NewDist = VSize(Pawn.Location - V.Location);
			if (BestDist == 0.0 || NewDist < BestDist 
				|| (Rx_Vehicle_Harvester(VehToHeal) != None && Rx_Vehicle_Harvester(V) == None) )
			{
				bVisible = V.FastTrace(V.Location, Pawn.Location + Pawn.GetCollisionHeight() * vect(0,0,1));
				if(!bVisible) {
					continue;
				}
				if(V.Health >= V.HealthMax) {
					if(bDefending) {
						continue;
					} else {
						NewDist *= 3;
					}
				}					
				if (BestDist == 0.0 || NewDist < BestDist || (Rx_Vehicle_Harvester(VehToHeal) != None && Rx_Vehicle_Harvester(V) == None)) {
				
					TraceDist = 1.5 * V.GetCollisionHeight();
					HitActor = Trace(HitLocation, HitNormal, V.Location - TraceDist*vect(0,0,1), V.Location, false,, HitInfo, TRACEFLAG_PhysicsVolumes);				
					if(HitActor != None && HitActor.isA('Rx_Volume_Tiberium')) {
						continue; // dont heal it when its on tiberium
					}
				
					VehToHeal = V;
					BestDist = NewDist;
				}
			}
		}		
		
		if(VehToHeal != None) {
			if (!Pawn.CanAttack(VehToHeal)) {
				RouteGoal = VehToHeal;
				if(FindBestPathToward(VehToHeal, false, false)) {
					GoalString = self$"moving closer to "$VehToHeal$" for healing";
					if(StartMoveToward(VehToHeal)) {
						return true;
					}
				} else {
					return false;
				}
			} else {
				DoRangedAttackOn(VehToHeal);
				return true;
			}
		}
	}
	return false;		
}

function class<UTFamilyInfo> BotBuy(Rx_Bot Bot, bool bJustRespawned)
{
	local int PickedVehicle;
	local int PickedChar;
	local class<Rx_FamilyInfo> PickedCharClass;
	local Rx_PurchaseSystem PurchaseSystem;
	
	PurchaseSystem = Rx_Game(WorldInfo.Game).GetPurchaseSystem();
	
	if(Bot.TargetMoney == 0 || (Bot.DeathsTillTargetMoneySwitch == 0 && Bot.GetCredits() < Bot.TargetMoney)) {
		Bot.TargetMoney = Bot.GetNewTargetMoney();
		if(FRand() < 0.7) 
			Bot.DeathsTillTargetMoneySwitch = 3;
		else
			Bot.DeathsTillTargetMoneySwitch = 2;		
	} 
	if(Bot.GetCredits() >= Bot.TargetMoney) {
		PickedVehicle = -1;
		if(Bot.GetOrders() == 'ATTACK' && Bot.GetCredits() >= 350 && !PurchaseSystem.AreVehiclesDisabled(GetTeamNum(), None) && FRand() <= 0.8) {
			if(Bot.GetTeamNum() == TEAM_GDI) {
				PickedVehicle = GetGdiVehicle();	
			} else {
				PickedVehicle = GetNodVehicle();
			}
		} else 
		if(Bot.GetOrders() == 'DEFEND' && Bot.GetCredits() >= 350 && FRand() <= 0.4) {
			PickedChar = 14;	
		} else if(Bot.GetCredits() >= 15000) {
			PickedChar = 4 + Rand(9);	
		} else if(Bot.GetCredits() >= 800) {
			PickedChar = 10 + Rand(3);
		} else if(Bot.GetCredits() >= 800) {
			PickedChar = 7 + Rand(3);
		} else if(Bot.GetCredits() >= 750) {
			PickedChar = 7 + Rand(3);
		} else if(Bot.GetCredits() >= 500) {
			PickedChar = 7 + Rand(3);
		} else if(Bot.GetCredits() >= 225) {
			PickedChar = 4 + Rand(3);
		}
		
		if(PurchaseSystem.AreHighTierPayClassesDisabled(GetTeamNum())) {
			PickedChar = Rand(4);	
		}
		
		if(PickedVehicle != -1) {
			if(PurchaseSystem.PurchaseVehicle(Rx_Pri(Bot.PlayerReplicationInfo), Bot.GetTeamNum(), PickedVehicle)) {	
				Bot.SetBaughtVehicle(PickedVehicle);
				if(Bot.GetCredits() >= 15000) {
					PickedChar = 4 + Rand(9);	
				} else if(!PurchaseSystem.AreHighTierPayClassesDisabled(GetTeamNum()) && FRand() < 0.25) {
					if(Bot.GetCredits() >= 1000) {
						PickedChar = 10 + Rand(3);	
					} else if(Bot.GetCredits() >= 800) {
						PickedChar = 7 + Rand(3);
					} else if(Bot.GetCredits() >= 750) {
						PickedChar = 7 + Rand(3);
					} else if(Bot.GetCredits() >= 500) {
						PickedChar = 7 + Rand(3);
					} else if(Bot.GetCredits() >= 225) {
						PickedChar = 4 + Rand(3);
					}		
				} else if(FRand() < 0.5) {
					PickedChar = 3;
				}
			}
		} 
		
		if(PickedChar != 0) {
			if(Bot.GetTeamNum() == TEAM_GDI) {
				PickedCharClass = PurchaseSystem.GDIInfantryClasses[PickedChar];
				Rx_Pri(Bot.PlayerReplicationInfo).RemoveCredits(PurchaseSystem.GDIInfantryPrices[PickedChar]);
			} else {
				PickedCharClass = PurchaseSystem.NODInfantryClasses[PickedChar];
				Rx_Pri(Bot.PlayerReplicationInfo).RemoveCredits(PurchaseSystem.NODInfantryPrices[PickedChar]);
			}
			Bot.TargetMoney = 0;
			`LogRxPub("GAME" `s "Purchase;" `s "character" `s PickedCharClass.name `s "by" `s `PlayerLog(Bot.PlayerReplicationInfo));
			return PickedCharClass;
		}
	} else if(Bot.GetCredits() > 0) {
		Bot.DeathsTillTargetMoneySwitch--;
	} 
	if(bJustRespawned) {
		return PurchaseSystem.GetStartClass(Bot.Pawn.GetTeamNum());
	} else {
		return UTPlayerReplicationInfo(Bot.PlayerReplicationInfo).CharClassInfo;
	}
}

function int GetGdiVehicle() {

	local int PickedVehicle;

	if(GetCredits() >= 15000) {
		if(!Rx_MapInfo(WorldInfo.GetMapInfo()).bAircraftDisabled && FRand() < 0.3)
			return 6;	
		else
			return Rand(5);
	}
	
	if(GetCredits() >= 1500 && FRand() <= 0.20) {
		PickedVehicle = 4; // Mammoth
	} else if(GetCredits() >= 900 && !Rx_MapInfo(WorldInfo.GetMapInfo()).bAircraftDisabled && FRand() <= 0.6) {
		PickedVehicle = 6; // Orca
	} else if(GetCredits() >= 800 && FRand() <= 0.6) {
		PickedVehicle = 3; // MedTank
	} else if(GetCredits() >= 450 && FRand() <= 0.6) {
		PickedVehicle = 2; // MRLS
 	} else if(GetCredits() >= 500 && FRand() <= 0.5) {
		PickedVehicle = 1; // APC
	} else if(GetCredits() >= 350) {
		PickedVehicle = 0; // Humvee
	}
	return PickedVehicle;
}

function int GetNodVehicle() {

	local int PickedVehicle;

	if(GetCredits() >= 15000) {
		if(!Rx_MapInfo(WorldInfo.GetMapInfo()).bAircraftDisabled && FRand() < 0.3)
			return 7;	
		else	
			return Rand(6);
	}
	if(GetCredits() >= 900 && FRand() <= 0.4) {
		PickedVehicle = 5; // StealhTank
 	} else if(GetCredits() >= 900 && !Rx_MapInfo(WorldInfo.GetMapInfo()).bAircraftDisabled && FRand() <= 0.6) {
		PickedVehicle = 7; // Apache		
	} else if(GetCredits() >= 600 && FRand() <= 0.6) {
		PickedVehicle = 4; // LightTank
	} else if(GetCredits() >= 450 && FRand() <= 0.6) {
		PickedVehicle = 2; // Artillery
	} else if(GetCredits() >= 800 && FRand() <= 0.4) {
		PickedVehicle = 3; // FlameTank
	} else if(GetCredits() >= 500 && FRand() <= 0.5) {
		PickedVehicle = 1; // APC
	} else if(GetCredits() >= 300) {
		PickedVehicle = 0; // Buggy
	}
	return PickedVehicle;
}

function LeftVehicle(){

}
function EnteredVehicle(){
	
	if(BaughtVehicleIndex != -1) {
		if(OrdersBeforeBaughtVehicle != GetOrders()) {
			if(OrdersBeforeBaughtVehicle == 'ATTACK') { // because while waiting for the veh orders are set to DEFEND
				Rx_TeamInfo(PlayerReplicationInfo.Team).AI.PutOnOffense(self);	
			} else if(OrdersBeforeBaughtVehicle == 'FREELANCE') {
				// todo
			}
		}
		BaughtVehicleIndex = -1;
		BaughtVehicle = None;
	} else if(GetOrders() == 'Defend') {
		Rx_TeamInfo(PlayerReplicationInfo.Team).AI.PutOnOffense(self);
		Rx_TeamAi(Rx_TeamInfo(PlayerReplicationInfo.Team).AI).NumBotsToSwitchToDefense++;
	} else if(Rx_AreaObjective(squad.SquadObjective) != None && Rx_AreaObjective(squad.SquadObjective).bBlockedForVehicles){
		Rx_TeamInfo(PlayerReplicationInfo.Team).AI.PutOnOffense(self);
	}
}

function ResetVehStationary() {
	shouldWaitVehicle.bStationary = false;
}

function setShouldWait(UTVehicle shouldWaitVeh){
	SetTimer(Rand(2) + 1,false,'ResetVehStationary');
	shouldWaitVehicle = shouldWaitVeh;
}

event SeePlayer(Pawn Seen)
{
	if (IsStealthed(Seen))
		return;
	
	if(Rx_Pawn(Seen) != None && Rx_Pawn(Seen).IsInvisible()) {
		return;
	} else if(Rx_Vehicle_StealthTank(Seen) != None && Rx_Vehicle_StealthTank(Seen).IsInvisible()) {
		return;
	}
	super.SeePlayer(Seen);
}

function bool IsStealthed(Pawn Seen)
{
	if ((Seen.IsInState('Stealthed') || Seen.IsInState('BeenShot')) && VSize(pawn.location - Seen.location) > 100)
		return true;
	return false;	
}

function bool LostContact(float MaxTime)
{
	local bool ret;
	
	ret = super.LostContact(MaxTime);
	if(ret) return true;

	if(IsStealthed(Enemy))
		return true;

	return false;
}

function Rotator GetAdjustedAimFor( Weapon W, vector StartFireLoc )
{
	return super.GetAdjustedAimFor(W,StartFireLoc);
}

function WaitAtAreaTimer() 
{
	bWaitingAtAreaSpot = false;
	ClosestNextRO = None; // invalidate, since bot moves to another point/area now
	ClosestEnemyBO = None; // invalidate, since bot moves to another point/area now
	ClearTimer('LookarroundWhileWaitingInAreaTimer');		
	if(WaitingInAreaCount++ > 4) {
		WaitingInAreaCount = 0;
		bCheckIfBetterSoInCurrentGroup = true;
		Rx_TeamInfo(PlayerReplicationInfo.Team).AI.PutOnOffense(self);
		bCheckIfBetterSoInCurrentGroup = false;
	}
	WhatToDoNext();
}

function LookarroundWhileWaitingInAreaTimer() 
{
	local int i,j;
	local NavigationPoint Nav,PickedFocusNav;
	local array<NavigationPoint> out_NavList;
	local UTGameObjective CurrentSO;
	local Rx_ObservedPoint ObservePoint;
	
	if(Pawn == None) {
		return;
	}
	if(FRand() < 0.7 || !Pawn.ValidAnchor() || Pawn.Anchor == None || Pawn.Anchor.PathList.length == 0) {
		
		/**
		if(ClosestNextRO == None) {
			ClosestNextRO = Rx_TeamAI(Rx_TeamInfo(PlayerReplicationInfo.Team).AI).GetClosestNextAreaObjective(self,true);
		}
		if(ClosestNextRO != None)
			ClosestObjective = ClosestNextRO;
		else {
			if(ClosestEnemyBO == None) {
				ClosestEnemyBO = Rx_TeamAI(Rx_TeamInfo(PlayerReplicationInfo.Team).AI).GetClosestEnemyBuildingObjective(self);
			}
			ClosestObjective = ClosestEnemyBO;
		}
		*/
		
		if(Squad != None)
			CurrentSO = UTGameObjective(Squad.SquadObjective);
		if(Rx_AreaObjective(CurrentSO) == None) {
			return;
		}	
		
		if(GetTeamNum() == TEAM_GDI) {
			if(Rx_AreaObjective(CurrentSO).ObservePointsGDI.length > 0) {
				i = Rand(Rx_AreaObjective(CurrentSO).ObservePointsGDI.length);
				ObservePoint = Rx_AreaObjective(CurrentSO).ObservePointsGDI[i];
				if(ObservePoint.Importance < 1.0 && Rx_AreaObjective(CurrentSO).ObservePointsGDI.length > 1
						&& FRand() > ObservePoint.Importance) {
					if(Rx_AreaObjective(CurrentSO).ObservePointsGDI.length-1 > i) {
						ObservePoint = Rx_AreaObjective(CurrentSO).ObservePointsGDI[i+1];
					} else {
						ObservePoint = Rx_AreaObjective(CurrentSO).ObservePointsGDI[i-1];
					}
				}
			}
		} else {
			if(Rx_AreaObjective(CurrentSO).ObservePointsNod.length > 0) {
				i = Rand(Rx_AreaObjective(CurrentSO).ObservePointsNod.length);
				ObservePoint = Rx_AreaObjective(CurrentSO).ObservePointsNod[i];
				if(ObservePoint.Importance < 1.0 && Rx_AreaObjective(CurrentSO).ObservePointsNod.length > 1
						&& FRand() > ObservePoint.Importance) {
					if(Rx_AreaObjective(CurrentSO).ObservePointsNod.length-1 > i) {
						ObservePoint = Rx_AreaObjective(CurrentSO).ObservePointsNod[i+1];
					} else {
						ObservePoint = Rx_AreaObjective(CurrentSO).ObservePointsNod[i-1];
					}
				}
			}
		}
		
		if(ObservePoint != None) {
			class'NavigationPoint'.static.GetAllNavInRadius(Pawn,Pawn.location,1600.0,out_NavList);
			i = Rand(out_NavList.length);
			Foreach out_NavList(Nav) {
				if(j++ >= i) {
					if(VSize(Nav.location - Pawn.location) >= 800 && FastTrace(Nav.location, Pawn.location)
							&& class'Rx_Utils'.static.OrientationOfLocAndRotToB(Pawn.location,rotator(Nav.location-Pawn.location),ObservePoint) > 0.3) {
						//DrawDebugLine(Pawn.location,Nav.location,0,0,255,true);
						//loginternal(class'Rx_Utils'.static.OrientationOfLocAndRotToB(Pawn.location,rotator(Nav.location-Pawn.location),ObservePoint));
						//DrawDebugSphere(Pawn.location,1600,10,0,0,255,true);
						PickedFocusNav = Nav;
						break;	
					}
				}
			}
			if(PickedFocusNav == None && i > 0) {
				j = 0;
				Foreach out_NavList(Nav) {
					if(j++ < i) {
						if(VSize(Nav.location - Pawn.location) >= 800 && FastTrace(Nav.location, Pawn.location)
								&& class'Rx_Utils'.static.OrientationOfLocAndRotToB(Pawn.location,rotator(Nav.location-Pawn.location),ObservePoint) > 0.3) {
							PickedFocusNav = Nav;
							//DrawDebugLine(Pawn.location,Nav.location,0,0,255,true);
							//loginternal(class'Rx_Utils'.static.OrientationOfLocAndRotToB(Pawn.location,rotator(Nav.location-Pawn.location),ObservePoint));
							//DrawDebugSphere(Pawn.location,1600,10,0,0,255,true);
							//DebugFreezeGame(Pawn); 						
							break;	
						}
					}
				}			
			}
		} 
	}
	
	if(PickedFocusNav == None) {
		if(Pawn.Anchor != None) {
			i = Rand(Pawn.Anchor.PathList.length);
			PickedFocusNav = Pawn.Anchor.PathList[i].GetEnd();
		}
	}
	if(PickedFocusNav != None) {
		Focus = PickedFocusNav;	
	}
	SetTimer(1.0 + Rand(5),false,'LookarroundWhileWaitingInAreaTimer');
}

function ChooseAttackMode()
{
	if(Enemy != None && GetOrders() == 'Attack' && Rx_BuildingObjective(Squad.SquadObjective) == None) {
		if(GetTeamNum() == TEAM_GDI) {
			if(Obelisk == None) GetObelisk();
			if(Obelisk != None) {
				if(RetreatToAvoidAO(Obelisk.location)) {
					return;
				}
			}
		} else if(GetTeamNum() == TEAM_NOD) {
			if(AGT == None) GetAGT();
			if(AGT != None) {
				if(RetreatToAvoidAO(AGT.location)) {
					return;
				}
			}
		}
	}
	super.ChooseAttackMode();
}

function bool RetreatToAvoidAO(vector AO_Location) 
{
	local float WeaponAO_OkDist;
	local vector CheckLoc;
		
	if(FastTrace(Enemy.location, AO_Location)) {
		if(Rx_Vehicle(Pawn) != None) {
			WeaponAO_OkDist = Rx_Vehicle_Weapon(Pawn.Weapon).GetAO_OkDist();	
		} else {
			WeaponAO_OkDist = Rx_Weapon(Pawn.Weapon).GetAO_OkDist();
		}
		
		// check for a location ahead in direction of enemy
		CheckLoc = Pawn.location + vector(rotator(Enemy.location - Pawn.location)) * WeaponAO_OkDist;
		
		if(FastTrace(CheckLoc, AO_Location) || FastTrace(Pawn.location, AO_Location)) {
			GoalString = "Retreating to avoid AGT/OB";
			MoveTarget = PickRetreatFromAODestination();
			GotoState('Retreating');
			return true;			
		}
	} else if(FastTrace(Pawn.location, AO_Location)) {
		GoalString = "Retreating to avoid AGT/OB";
		MoveTarget = PickRetreatFromAODestination();
		GotoState('Retreating');
		return true;
	}	
	return false;
}

function Actor GetObelisk()
{
	local Rx_Sentinel_Obelisk_Laser_Base Ob;
	if(Rx_Game(WorldInfo.Game).Obelisk == None)
		return None;
	if(Obelisk != None) return Obelisk;
	ForEach DynamicActors(class'Rx_Sentinel_Obelisk_Laser_Base', Ob) {
		Obelisk = Ob;
	}
	return Obelisk;		
}

function Actor GetAGT()
{
	local Rx_Sentinel_AGT_Rockets_Base AdGT;
	if(Rx_Game(WorldInfo.Game).AGT == None)
		return None;	
	if(AGT != None) return AGT;
	ForEach DynamicActors(class'Rx_Sentinel_AGT_Rockets_Base', AdGT) {
		AGT = AdGT;
	}
	return AGT;		
}

function NavigationPoint PickRetreatFromAODestination()
{
	local bool bOkStrafeSpot;
	local Vehicle veh;
	local int i,Start;
	local float Dist,DistToAreaObjective;
	local NavigationPoint Nav, AlrightNavpoint;
	local Rx_AreaObjective AreaObjective;
	
	AreaObjective = Rx_AreaObjective(Squad.SquadObjective);
	DistToAreaObjective = VSize(Pawn.location - AreaObjective.location);
	 
	// get on path network if not already
	if (!Pawn.ValidAnchor())
	{
		Pawn.SetAnchor(Pawn.GetBestAnchor(Pawn, Pawn.Location, true, true, Dist));
		if (Pawn.Anchor == None)
		{
			// can't get on path network
			return None;
		}
		else
		{
			bOkStrafeSpot = VSize(Pawn.Anchor.Location - AreaObjective.location) < DistToAreaObjective;	
			if (bOkStrafeSpot )
			{
				return Pawn.Anchor;
			}
			else
			{
				return None;
			}
		}
	} 
	else if (Pawn.Anchor.PathList.length > 0)
	{
		// pick a random point linked to anchor within range of Area
		Start = Rand(Pawn.Anchor.PathList.length);
		i = Start;
		do
		{
			if (!Pawn.Anchor.PathList[i].IsBlockedFor(Pawn))
			{
				Nav = Pawn.Anchor.PathList[i].GetEnd();
				if (!Nav.bSpecialMove)
				{
					// one that gets us closer to the AreaObjective
					bOkStrafeSpot = VSize(Nav.Location - AreaObjective.location) < DistToAreaObjective;					
					if(bOkStrafeSpot && UTVehicle(Pawn) != None) {
						if(VolumePathNode(Nav) != None && !UTVehicle(Pawn).bCanFly) {
							bOkStrafeSpot = false;
						} else {							
							ForEach CollidingActors(class'Vehicle', veh, 500, Nav.location)
							{
								if(veh != Pawn) {
									if(VSize(veh.location - Nav.location) < VSize(Pawn.location - veh.location)) {
										bOkStrafeSpot = false; // so that we dont ramm into vehicles
										AlrightNavpoint = Nav;	
										break;
									}
								}
							}
						}
					}
					if (bOkStrafeSpot )
					{
						if(VSize(Nav.location - AreaObjective.location) < DistToAreaObjective) {
							return Nav;
						}
					} 
				}
			}
			i++;
			if (i == Pawn.Anchor.PathList.length)
			{
				i = 0;
			}
		} until (i == Start);
		
		if(AlrightNavpoint != None) {
			return AlrightNavpoint;
		} else {
			return None;
		}
	}	
	return None;
}

/**
function DoCharge()
{
	if(Rx_Vehicle(Pawn) != None && !Rx_Vehicle(Pawn).ValidEnemyForVehicle(Enemy)) {
		//loginternal("LoseEnemy");
		InvalidEnemy = Enemy; 
		LoseEnemy();
		ExecuteWhatToDoNext();
		return;	
	}
	super.DoCharge();
}
*/

state Roaming
{
	ignores EnemyNotVisible;

	function MayFall(bool bFloor, vector FloorNormal)
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('DroppedPickup')) );
	}

Begin:
	SwitchToBestWeapon();
	WaitForLanding();
	if ( Pawn.bCanPickupInventory && (UTPickupFactory(MoveTarget) != None) && (UTSquadAI(Squad).PriorityObjective(self) == 0) && (Vehicle(Pawn) == None)
		&& UTPickupFactory(MoveTarget).ShouldCamp(self, 5) )
	{
		CampTime = MoveTarget.LatentFloat;
		GoalString = "Short wait for inventory "$MoveTarget;
		GotoState('Defending','Pausing');
	}
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
DoneRoaming:
	WaitForLanding();
	LatentWhatToDoNext();
	if(!IsTimerActive('WaitAtAreaTimer')) {
		GoalString = "STUCK IN ROAMING";
		if ( bSoaking )
			SoakStop("STUCK IN ROAMING!");
	}
}

function setStrafingDisabled(bool bEnabled)
{
	bStrafingDisabled = bEnabled;
	//loginternal("Strafing:"@GetHumanReadableName()@" "@bEnabled);
}

function bool ShouldStrafeTo(Actor WayPoint)
{
	if(bStrafingDisabled) {
		return false;
	}
	return super.ShouldStrafeTo(WayPoint);
}

function bool IsInBuilding() 
{
	local Vector TraceStart;
	local Vector TraceEnd;
	local Vector TraceExtent;
	local Vector OutHitLocation, OutHitNormal;
	local TraceHitInfo HitInfo;
	local Actor TraceActor;	
	
	TraceStart = Pawn.Location;
	TraceEnd = Pawn.Location;
	TraceEnd.Z += 400.0f;
	// trace up and see if we are hitting a building ceiling  
	TraceActor = Trace(OutHitLocation, OutHitNormal, TraceEnd, TraceStart, TRUE, TraceExtent, HitInfo, TRACEFLAG_Bullet);
	if(Rx_Building(TraceActor) != None) {
		return true;
	}
	return false;
}


state GetOutOfBuilding
{

	function Actor GetNearestNav()
	{
		local array<NavigationPoint> out_NavList;
		local NavigationPoint Nav;	
		local float Dist;	
		class'NavigationPoint'.static.GetAllNavInRadius(Pawn,Pawn.location,200,out_NavList);
		Foreach out_NavList(Nav) {
			Dist = VSize(Nav.location - Pawn.location);
			if(Dist > 30 && FastTrace(Nav.location - Pawn.location) && ActorReachable(Nav)) {
				return Nav;
			} 
			/**
			else {
				return FindPathTowardNearest(class'Rx_DoorMarker');
			}
			*/
		}
		return None;
	}

Begin:
	tempActor = GetNearestNav();
	if(tempActor != None) {
		MoveToward(tempActor,tempActor,, false, false);
	} else {
		DoRandomJumps();
	}
	LatentWhatToDoNext();
}

protected event ExecuteWhatToDoNext()
{
	if(Rx_Vehicle(Pawn) != None && Rx_AreaObjective(Squad.SquadObjective) != None 
			&& Rx_AreaObjective(Squad.SquadObjective).bBlockedForVehicles) {
		super.ExecuteWhatToDoNext();
	}
	
	super.ExecuteWhatToDoNext();
}

function WanderOrCamp()
{
	if(bStrafingDisabled) {
		GotoState('GetOutOfBuilding', 'Begin');
	} else {
		super.WanderOrCamp();
	}
}

function DoRandomJumps()
{
	if ( (NumRandomJumps > 4) || PhysicsVolume.bWaterVolume )
	{
		// can't suicide during physics tick, delay it
		Pawn.SetTimer(0.01, false, 'Suicide');
		return;
	}
	else
	{
		// jump
		NumRandomJumps++;
		if (!Pawn.IsA('Vehicle') && Pawn.Physics != PHYS_Falling && Pawn.DoJump(false))
		{
			Pawn.SetPhysics(PHYS_Falling);
			Pawn.Velocity = 0.5 * Pawn.GroundSpeed * VRand();
			Pawn.Velocity.Z = Pawn.JumpZ;
		}
	}
}

function ChangeToSBH(bool sbh) {
	local pawn p;
	local vector l;
	local rotator r; 
	
	p = Pawn;
	l = Pawn.Location;
	r = Pawn.Rotation; 
	
	if(sbh) 
	{
		if(self.Pawn.class != class'Rx_Pawn_SBH' )
		{
			UnPossess();
			p.Destroy(); 
			p = Spawn(class'Rx_Pawn_SBH', , ,l,r);
		}
		else
		{
			return;
		}
	}
	else 
	{
		if(self.Pawn.class != class'Rx_Pawn' )
		{
			UnPossess();
			p.Destroy(); 
			p = Spawn(class'Rx_Pawn', , ,l,r);
		}
		else
		{
			return;
		}
		
	}
	Possess(p, false);
	Rx_Pri(PlayerReplicationInfo).equipStartWeapons();	
}

function bool TryDuckTowardsMoveTarget(vector Dir, vector Y)
{
	return false;
}

function bool IsShootingObjective()
{
	if(Rx_BuildingObjective(Focus) != None) {
		return true;
	}
	return false;
}

function ConsiderStartSprintTimer()
{
	local float Stamina;
	
	if(Rx_Pawn(pawn) == None) {
		StopSprinting();
		return;
	}
	if(Rx_Pawn(pawn).IsFiring() || Pawn.Acceleration == vect(0,0,0) || Stopped() || IsInState('TacticalMove')) {
		StopSprinting();
		return;
	}
	if(Rx_Pawn(pawn).bSprinting) {
		return;
	}
	Stamina = Rx_Pawn(pawn).Stamina;	
	
	if(IsRetreating() && (Stamina >= 10 + Rand(20))) {
		StartSprinting();
		return;	
	}
	if(Stamina >= 80) {
		StartSprinting();	
	} else if(Stamina  >= 0.5 && FRand() < 0.5) {
		StartSprinting();
	}
}

function StartSprinting()
{
	if(Rx_Pawn(pawn) == None || Rx_Pawn(pawn).bSprinting) {
		return;
	} 
	Rx_Pawn(pawn).StartSprint();
}

function StopSprinting()
{
	if(Rx_Pawn(pawn) == None || !Rx_Pawn(pawn).bSprinting) {
		return; 
	} 
	Rx_Pawn(pawn).StopSprinting();
}

function bool FireWeaponAt(Actor A)
{
	StopSprinting();
	return super.FireWeaponAt(A);
}

function StopMovement()
{
	StopSprinting();
	super.StopMovement();
}

function DoTacticalMove()
{
	StopSprinting();
	super.DoTacticalMove();
}

DefaultProperties
{
	CharInfoClass = class'RenX_Game.Rx_BotCharInfo'
	BaughtVehicleIndex = -1
	WaitingInAreaCount = 0;
	//bSoaking = true
}

 
