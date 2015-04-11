class Rx_AreaObjective extends UTGameObjective
	placeable;

var Rx_SquadAI TeamSquads[2];
var() int	   GroupNum;
var() int 	   Importance;
var() bool 	   bShowBaseRadius;
var() bool 	   bLineOfSightArea;	
var() bool 	   bBlockForVehicles;	
var() array<Rx_ObservedPoint> ObservePointsGDI;	
var() array<Rx_ObservedPoint> ObservePointsNod;	
var   float	   GDIPresence;
var   float	   NodPresence;
var   float    LastPlayerCountTime;


simulated function PostBeginPlay()
{  
	super.PostBeginPlay();
	if(bShowBaseRadius && WorldInfo.IsPlayInEditor()) {
		DrawDebugSphere(location,BaseRadius,10,0,0,255,true);
	}
	bBlockedForVehicles = bBlockForVehicles;
}

function bool TellBotHowToDisable(UTBot B)
{
	local NavigationPoint PickedNavPoint;
	local UTGameObjective NewRO;
	local bool bPathToObjective;
	
	if(bBlockForVehicles && Rx_Vehicle(B.Pawn) != None) {
		Rx_TeamInfo(B.PlayerReplicationInfo.Team).AI.PutOnOffense(B);
		return B.StartMoveToward(B.Squad.SquadObjective);
	}
	
	if(B.Enemy != None) {
		return false;
	} else if(!BotNearObjective(B)){
		// move closer
		bPathToObjective = UTSquadAI(B.Squad).FindPathToObjective(B,self);
		if(bPathToObjective) {
			return true;
		} else {
			//`log(B.GetHumanReadableName()@"couldnt find path to AO");
			return false;
		}
	} else {
		
		if(WorldInfo.TimeSeconds >= Rx_Bot(B).ReevaluateAreaObjectiveTime) {
			Rx_Bot(B).ReevaluateAreaObjectiveTime = WorldInfo.TimeSeconds + 3.0;
			Rx_Bot(B).ReevaluateAreaObjectiveTime += Rand(8);
			NewRO = UTTeamInfo(UTSquadAI(B.Squad).Team).AI.GetPriorityAttackObjectiveFor(UTSquadAI(B.Squad),B);
			if(NewRO != None && NewRO != self) {
				//loginternal("changed RO");
				Rx_TeamAI(UTTeamInfo(UTSquadAI(B.Squad).Team).AI).PutOnOffenseAttackO(B,NewRO);
				return NewRO.TellBotHowToDisable(B);
			}
		}
		if(Rx_Bot(B).bWaitingAtAreaSpot) {
			return true;
		}
		
		if(Vehicle(B.Pawn) != None && FRand() < 0.4) {
			Rx_Bot(B).bWaitingAtAreaSpot = true;
			B.MoveTarget = None;
			if(UTVehicle(B.Pawn) != None) {
				UTVehicle(B.Pawn).Throttle = 0.0;
				UTVehicle(B.Pawn).Steering = 0.0;
			}
			//`log("waiting in area");
			Rx_Bot(B).SetTimer(3.0 + Rand(3),false,'WaitAtAreaTimer');
			Rx_Bot(B).GoalString = "Patroulling Area";
			Rx_Bot(B).SetTimer(0.1,false,'LookarroundWhileWaitingInAreaTimer');
			return true;
		} else {
			PickedNavPoint = GetNextPathnodeForPawnToRoamTo(B.Pawn);
			B.SetFocalPoint(self.location);
			if(PickedNavPoint != None) {
				B.GoalString = "Moving arround AreaObjective";
				B.MoveTarget = PickedNavPoint;
				//todo B.GotoState('MyRoaming')
				B.SetAttractionState();
				return true;	
			} else {
				return false;
			}
		}
	}
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	TeamSquads[0] = None;	
	TeamSquads[1] = None;	
	super.Reset();
}

function NavigationPoint GetNextPathnodeForPawnToRoamTo(Pawn P) 
{
	local bool bOkStrafeSpot,bPreferNavInFront;
	local int i,Start;
	local float Dist;
	local NavigationPoint Nav, AlrightNavpoint;
	 
	// get on path network if not already
	if (!P.ValidAnchor())
	{
		P.SetAnchor(P.GetBestAnchor(P, P.Location, true, true, Dist));
		if (P.Anchor == None)
		{
			// can't get on path network
			return None;
		}
		else
		{
			bOkStrafeSpot = !P.Anchor.bBlocked && VSize(P.Anchor.Location - self.location) < BaseRadius;
			if(bOkStrafeSpot && bLineOfSightArea) {
				bOkStrafeSpot = FastTrace(self.Location, P.Anchor.Location);
			}
			if(bOkStrafeSpot && UTVehicle(P) != None) {
				if(VolumePathNode(P.Anchor) != None && !UTVehicle(P).bCanFly) {
					bOkStrafeSpot = false;
				} else {
					bOkStrafeSpot = Rx_Bot(P.Controller).NavBlockedByVeh(P.Anchor);
				}
			}
			if (bOkStrafeSpot )
			{
				return P.Anchor;
			}
			else
			{
				//`log("Failed to move cause Anchor failed. Have"@P.Anchor.PathList.length@"Paths"); 
			}
		}
	} 
	
	if (P.Anchor.PathList.length > 0)
	{
		// pick a random point linked to anchor within range of Area
		Start = Rand(P.Anchor.PathList.length);
		i = Start;
		//if(class'Rx_Utils'.static.OrientationToB(P, self) > -0.5 && FRand() < 0.5) {
		if(FRand() < 0.6) {
			bPreferNavInFront = true;
		}
		do
		{
			if (!P.Anchor.PathList[i].IsBlockedFor(P))
			{
				Nav = P.Anchor.PathList[i].GetEnd();
				if (Nav != self && !Nav.bSpecialMove)
				{
					bOkStrafeSpot = !Nav.bBlocked && VSize(Nav.Location - self.location) < BaseRadius;
					if(bOkStrafeSpot && bLineOfSightArea) {
						bOkStrafeSpot = FastTrace(self.Location, Nav.Location);
					}
										
					if(NavCanBeHitByAO(Rx_Bot(P.Controller), Nav)) {
						bOkStrafeSpot = false;						
					}
															
					if(bOkStrafeSpot && UTVehicle(P) != None) {
						if(VolumePathNode(Nav) != None && !UTVehicle(P).bCanFly) {
							bOkStrafeSpot = false;
						} else {							
							bOkStrafeSpot = Rx_Bot(P.Controller).NavBlockedByVeh(Nav);
						}
					}
					if (bOkStrafeSpot )
					{
						if(!bPreferNavInFront) {
							return Nav;
						}
						if(class'Rx_Utils'.static.OrientationToB(P, Nav) >= 0.0) {
							//loginternal("PickedNavInFront");
							return Nav;
						} else {
							AlrightNavpoint = Nav;
						}
					} 
				}
			}
			i++;
			if (i == P.Anchor.PathList.length)
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
}

function bool NavCanBeHitByAO(Rx_Bot B, Navigationpoint Nav) 
{
	if(B.GetTeamNum() == TEAM_GDI) {
		if(B.Obelisk == None) B.GetObelisk();
		if(B.Obelisk != None) {
			if(FastTrace(B.Obelisk.location, Nav.Location)) {
				return true;
			}
		}
	} else if(B.GetTeamNum() == TEAM_NOD) {
		if(B.AGT == None) B.GetAGT();
		if(B.AGT != None) {
			if(FastTrace(B.AGT.location, Nav.Location)) {
				return true;
			}
		}
	}
	return false;
}

function bool NearObjective(Pawn P)
{
	local bool bIsNear;
	bIsNear = VSize(Location - P.Location) < BaseRadius;
	if(bIsNear && bLineOfSightArea) {	
		bIsNear = FastTrace(self.location,P.location);
	}
	return bIsNear;
}

simulated function string GetHumanReadableName()
{
	return "AreaObjective";	
}

function array<float> getTeamPresence() {
	local Pawn p;
	local array<float> teamPresence;
	local float temp;
	if(WorldInfo.TimeSeconds - LastPlayerCountTime > 5.0) {
		GDIPresence = 0.0;
		NodPresence = 0.0;
		
		if(bLineOfSightArea) {
			Foreach VisibleCollidingActors(class'Pawn', P, BaseRadius) {
				if((Rx_Pawn(P) == None && Rx_Vehicle(P) == None) || (Rx_Vehicle(P) != None && Rx_Vehicle(P).Driver == None))
					continue;
				temp = Rx_Vehicle(P) != None ? 1.0 : 0.5;
				if(P.GetTeamNum() == TEAM_GDI)
					GDIPresence += temp;
				else if(P.GetTeamNum() == TEAM_NOD)
					NodPresence += temp;	
			}
		} else {
			Foreach OverlappingActors(class'Pawn', P, BaseRadius) {
				if((Rx_Pawn(P) == None && Rx_Vehicle(P) == None) || (Rx_Vehicle(P) != None && Rx_Vehicle(P).Driver == None))
					continue;
				temp = Rx_Vehicle(P) != None ? 1.0 : 0.5;
				if(P.GetTeamNum() == TEAM_GDI)
					GDIPresence += temp;
				else if(P.GetTeamNum() == TEAM_NOD)
					NodPresence += temp;	
			}
		}
		LastPlayerCountTime = WorldInfo.TimeSeconds;	
	}
	teamPresence[TEAM_GDI] = GDIPresence;
	teamPresence[TEAM_NOD] = NodPresence;
	return teamPresence;
}

/** determines what next RO of the same group the bot will move to */
function int GetImportance(byte forTeam) {
	local int ret;
	local array<float> teamPresence;
	
	teamPresence = getTeamPresence();
	
	ret = Importance;
	if(forTeam == TEAM_GDI) {
		if(teamPresence[TEAM_GDI] < teamPresence[TEAM_NOD]) {
			ret += 1;
		}
	} else {
		if(teamPresence[TEAM_NOD] < teamPresence[TEAM_GDI]) {
			ret += 1;
		}
	}
	if(ret == 0)
		ret = 1;
	return ret;
}

defaultproperties
{
	Begin Object Class=CylinderComponent Name=Cylinder
		CollisionRadius=+3000.000000
		CollisionHeight=+0400.000000
		CylinderColor=(R=0,G=255,B=0,A=255)
		CollideActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		bAlwaysRenderIfSelected=true		
	End Object
	Components.Add(Cylinder)
	
	BaseRadius=+3000.0
	bFirstObjective=false
	bCollideWhenPlacing=true
	bMustBeReachable = true
	bCollideActors = false
	bMustTouchToReach = false
	bShowBaseRadius = true
	bLineOfSightArea = true
	DefenderTeamIndex = 5;
}