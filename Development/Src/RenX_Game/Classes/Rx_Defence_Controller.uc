class Rx_Defence_Controller extends AIController;

var float time;
var float LastFireAttempt;
var bool bFireSuccess;
var float LastCanAttackCheckTime;
var bool bCanFire;
var Actor LastFireTarget;
var bool bStoppedFiring;
var Actor myFocus;
var Pawn DetectedPawn;
var vector PlayerFeet;
var vector SocketLocation;
var vector Aim_Spot;
var rotator SocketRotation;	

var Rx_SmokeScreen DummyActor;
var Vector DummyHitLoc, DummyHitNorm;

var vector HitLocation, HitNormal;

/** Prediction will never see target as moving faster than this. */
var float MaxPredictionSpeed;
/** Proportion of targets velocity to take into account when predicting where to fire. */
var float AimAhead;
var rotator AimAheadAimRotation;

var int Veterancy_Points; //Held by the controller for defences for ease of use
var bool bAutoVet; //Automatic defence, so automatically handle veterancy

enum Target
{
	TYPE_AIR, TYPE_GROUND, TYPE_BOTH
};

var const Target targets;

//Weapons
var float Misc_DamageBoostMod; 
var float Misc_RateOfFireMod;
var float Misc_ReloadSpeedMod;

//Survivablity
var float Misc_DamageResistanceMod;
var float Misc_RegenerationMod; 

//Healing Related Variables//
var int	LastSupportHealTime;

//Buff/Debuff modifiers//

var float Misc_SpeedModifier; 


struct ActiveModifier
{
	var class<Rx_StatModifierInfo> ModInfo; 
	var float				EndTime; 
	var bool				Permanent; 
};

var array<ActiveModifier> ActiveModifications; 


event PostBeginPlay()
{
	Super.PostBeginPlay();
	InitPlayerReplicationInfo();
	SetTimer(0.1,true,'CheckActiveModifiers');
}



function InitPlayerReplicationInfo()
{
	if(PlayerReplicationInfo != none)
	{
		CleanupPRI();
	}
	PlayerReplicationInfo = Spawn(class'Rx_DefencePRI', self);

	if (PlayerReplicationInfo != none) {
		PlayerReplicationInfo.SetPlayerName(Rx_Defence(Owner).GetHumanReadableName());
		PlayerReplicationInfo.SetPlayerTeam(WorldInfo.GRI.Teams[Owner.GetTeamNum()]);
	}
}

function bool IsTargetRelevant( Pawn thisTarget )
{
	if(Pawn.Health <= 0)
		return false;

	if (Rx_Pawn(thisTarget) != None && Rx_Pawn(thisTarget).isSpy()) // added spy exception
		return false;

	if(targets != TYPE_AIR && (Rx_Vehicle_Air_Jet(thisTarget) != None || Rx_Vehicle_Air(thisTarget) != None || Rx_SupportVehicle_Air(thisTarget) != none))
		return false;
	
	if(Rx_VehicleSeatPawn(thisTarget) != none)
	{
		if(Rx_Vehicle_Air(Rx_VehicleSeatPawn(thisTarget).MyVehicle) != none || Rx_Vehicle_Air_Jet(Rx_VehicleSeatPawn(thisTarget).MyVehicle) != none) 
			return false;		
	}
	
	if (thisTarget != None && 
		FastTrace(thisTarget.location,pawn.location) &&
		(thisTarget.Controller != None) && 
		(thisTarget.GetTeamNum() != self.GetTeamNum()) &&
		(thisTarget.Health > 0) &&
		pawn.Weapon.CanAttack(thisTarget))
		//(VSize(thisTarget.Location-Pawn.Location) < Pawn.SightRadius*1.25) )
	{
		if ( Rx_Game(WorldInfo.Game).SmokeScreenCount > 0 )
		{
			foreach TraceActors(class'Rx_SmokeScreen', DummyActor, DummyHitLoc, DummyHitNorm, thisTarget.Location, Pawn.Location)
				return false;
		}
		return true;
	}
	return false;
}

/*
*  Normal IsAimCorrect in UTVehicleWeapon checks if were aiming at Focus, but here we need
*  to check if were aiming at Enemy instead, while Focus can be None.
*/
function bool IsAimCorrect()
{
	local vector DesiredAimPoint, RealAimPoint;

	DesiredAimPoint = Enemy.location;

	UTVehicleWeapon(UTVehicle(Pawn).Seats[0].Gun).GetFireStartLocationAndRotation(SocketLocation, SocketRotation);

	RealAimPoint = SocketLocation + Vector(SocketRotation) * UTVehicle(Pawn).Seats[0].Gun.GetTraceRange();
	return ((Normal(DesiredAimPoint - SocketLocation) dot Normal(RealAimPoint - SocketLocation)) >= UTVehicleWeapon(UTVehicle(Pawn).Seats[0].Gun).GetMaxFinalAimAdjustment());
}

auto state Searching
{

	// treat Scripted pawn as player
	event SeeMonster( Pawn Seen )
	{
		if ( IsTargetRelevant( Seen ) )
		{
			Enemy = Seen;
			Focus = Seen;
			GotoState('Engaged');
		} 
		else 
		{
			Enemy = None;
			Focus = None;
		}
	}
	
	event SeePlayer( Pawn Seen )
	{
		
		if ( IsTargetRelevant( Seen ) )
		{
			Enemy = Seen;
			Focus = Seen;
			GotoState('Engaged');
		} 
		else {
			Enemy = None;
			Focus = None;
		}
	}
	
	event EnemyNotVisible()
	{
		super.EnemyNotVisible();
		Enemy = None;
		Focus = None;
	}

	function BeginState(Name PreviousStateName)
	{
		if(Pawn != None)
			self.StopFiring();
	}
	
	Begin:
	Focus = Enemy;
	Sleep(0.2);
	if ( Enemy != None && IsTargetRelevant( Enemy ) )
		GotoState('Engaged');
	Sleep(0.5 + 1.0*FRand());
	
	if(Pawn != None)
	{
		foreach WorldInfo.AllPawns(class'Pawn', DetectedPawn,Pawn.location,pawn.SightRadius)
		{ 
			if(IsTargetRelevant(DetectedPawn))
			{
				if(Enemy == None)
				{
					Enemy = DetectedPawn;
					Focus = DetectedPawn;
				}

				GotoState('Engaged');	
				break;
			}
		}
	}
	
	Goto('Begin');
}

state Engaged
{
	
	ignores SeePlayer;
	
	function EnemyNotVisible()
	{
		
		if ( IsTargetRelevant( Enemy ) )
		{
			Focus = None;
			GotoState('WaitForTarget');
			return;
		}
	}

	function BeginState(Name PreviousStateName)
	{
		SetTimer(0.1, true, 'TryToAttackFocus');
	}
	function EndState(Name NextStateName)
	{
		ClearTimer('TryToAttackFocus');
	}


	Begin:
	Focus = Enemy;
	Sleep(0.1);
	//	if(Trace(HitLocation, HitNormal, Focus.Location - vect(0,0,60), UTVehicle(Pawn).Seats[0].Gun.GetPhysicalFireStartLoc(), true,,, TRACEFLAG_Bullet) == Enemy);
	//     	FocalPoint.z = FocalPoint.z-60;
	
	UTVehicleWeapon(UTVehicle(Pawn).Seats[0].Gun).GetFireStartLocationAndRotation(SocketLocation, SocketRotation);
	
	if(AimAhead > 0.0 && Enemy != None && Focus != None) {
		FindAimToHit(Enemy, SocketLocation, Aim_Spot, AimAheadAimRotation);
		self.FocalPosition.Position = Aim_Spot;
	}
	
	if(UTVehicle(Enemy) == None && Rx_Defence_GuardTower(Pawn) == None)
	{
		PlayerFeet = self.FocalPosition.Position;
		PlayerFeet.Z -= 50;
		if(FastTrace(PlayerFeet,SocketLocation)) {
			self.FocalPosition.Position.Z -= 50;	// If Enemy is Infantry, aim more at the feet, if its a Vehicle aim at the middle
		}
	}
	// This 'manually' Points the Turret to where the Controller is Aiming
	UTVehicle(Pawn).ForceWeaponRotation(0, UTVehicle(Pawn).GetWeaponAim(UTVehicleWeapon(UTVehicle(Pawn).Seats[0].Gun)));
	Focus = None;
	Sleep(1.2);
	if ( !IsTargetRelevant( Enemy )) {
		GotoState('Searching');
	}
	Goto('Begin');
}

function TryToAttackFocus(){
	if((Enemy != None)  && IsAimCorrect() && UTVehicle(Pawn).Seats[0].Gun.CanAttack(Enemy))
	{
		Pawn.BotFire(false);
	}
	else
	{
		self.StopFiring();
	} 
}

State WaitForTarget
{
	event SeePlayer(Pawn SeenPlayer)
	{
		`log("Relevant?" @ SeenPlayer);
		if ( IsTargetRelevant( SeenPlayer ) )
		{
			`log("Seen in" @ "WaitForTarget");
			Enemy = SeenPlayer;
			GotoState('Engaged');
		}
	}

Begin:
	Sleep( GetWaitForTargetTime() );
	GotoState('Searching');
}

function float GetWaitForTargetTime()
{
	return (3 + 5 * FRand());
}

/**
 * Determines the best place to shoot at to hit the target.
 */
function FindAimToHit(Actor A, Vector Origin, out Vector AimSpot, out Rotator AimRotation)
{
	PredictTargetLocation(A, Origin, AimSpot);
	AimRotation = Rotator(AimSpot - Origin);
}

/**
 * Predicts where the target will be based on its velocity. Only call this if the Sentinel is using a projectile weapon.
 */
function PredictTargetLocation(Actor A, Vector Origin, out Vector AimSpot)
{
	local float PredictionTime;
	local Vector PredictionVelocity;

	AimSpot = A.GetTargetLocation();
//	`log(Self.GetHumanReadableName()@": Aiming towards"@A@"At"@AimSpot);

	//How long it will take for projectile to reach target.
	
	PredictionTime = GetPredictionTime(AimSpot, Origin);

	//Where the target will probably be by then.
	if(VSizeSq(A.Velocity) > Square(MaxPredictionSpeed))
		PredictionVelocity = Normal(A.Velocity) * MaxPredictionSpeed;
	else
		PredictionVelocity = A.Velocity;

	AimSpot += PredictionVelocity * PredictionTime * AimAhead;
}

function float GetPredictionTime(vector AimSpot, Vector Origin) {
	local float ret;
	ret = class'Rx_Defence_Turret_Projectile'.static.StaticGetTimeToLocation(AimSpot, Origin, Self);
	ret += 0.5 * ret;
	return ret;
}

/*
Is set, when a Player is controlling the Turret
*/
state Idle
{
}

function GiveVeterancy(int VP)
{
	if(!bAutoVet || Rx_Defence(Pawn) == none) return;
	
	Veterancy_Points+=VP; 
	
	if(Veterancy_Points >= 20 && Rx_Defence(Pawn).VRank < 1) Rx_Defence(Pawn).PromoteUnit(1); //50 
	else
	if(Veterancy_Points >= 60 && Rx_Defence(Pawn).VRank < 2) Rx_Defence(Pawn).PromoteUnit(2); //100
	else
	if(Veterancy_Points >= 120 && Rx_Defence(Pawn).VRank < 3) Rx_Defence(Pawn).PromoteUnit(3); //150
}

/*****************/
/**Set modifiers**/
/*****************/

function AddActiveModifier(class<Rx_StatModifierInfo> Info)//class<Rx_StatModifierInfo> Info) 
{
	local int FindI; 
	local ActiveModifier TempModifier; 
	//local class<Rx_StatModifierInfo> Info; 
	
	//Info = class'Rx_StatModifierInfo_Nod_PTP';
	
	FindI = ActiveModifications.Find('ModInfo', Info);
	
	//Do not allow stacking of the same modification. Instead, reset the end time of said modification
	if(FindI != -1) 
	{
		//`log("Found in array");
		ActiveModifications[FindI].EndTime = WorldInfo.TimeSeconds+Info.default.Mod_Length; 
		//return; 	
	}
	else //New modifier, so add it in and re-update modification numbers
	{
		
		//`log("Adding to array"); 
		TempModifier.ModInfo = Info; 
		if(Info.default.Mod_Length > 0) TempModifier.EndTime = WorldInfo.TimeSeconds+Info.default.Mod_Length;
		else
		TempModifier.Permanent = true; 
		ActiveModifications.AddItem(TempModifier);	
	}
	
	UpdateModifiedStats(); 
}


function UpdateModifiedStats()
{
	local ActiveModifier TempMod;
	local byte			 HighestPriority; 
	//local LinearColor	 PriorityColor; 
	local bool			 bAffectsWeapon;
	local class<Rx_StatModifierInfo> PriorityModClass; /*Highest priority modifier class (For deciding what overlay to use)*/
	
	ClearAllModifications(); //start from scratch
	HighestPriority = 255 ; // 255 for none
	
	if(ActiveModifications.Length < 1) 
	{
		if(Rx_Pawn(Pawn) != none) 
		{
			//In case speed was modified. Update animation info
			Rx_Pawn(Pawn).SetSpeedUpgradeMod(0.0);
			Rx_Pawn(Pawn).UpdateRunSpeedNode(); 
			Rx_Pawn(Pawn).SetGroundSpeed();
			Rx_Pawn(Pawn).ClearOverlay();
		}
		else if(Rx_Vehicle(Pawn) != none)
		{
			Rx_Vehicle(Pawn).ClearOverlay();
		}
		//TODO: Insert code to handle vehicles 
		return; 	
	}
	
	foreach ActiveModifications(TempMod) //Build all buffs
	{
		Misc_SpeedModifier+=TempMod.ModInfo.default.SpeedModifier;	
		Misc_DamageBoostMod+=TempMod.ModInfo.default.DamageBoostMod;	
		Misc_RateOfFireMod-=TempMod.ModInfo.default.RateOfFireMod;
		Misc_ReloadSpeedMod-=TempMod.ModInfo.default.ReloadSpeedMod;
		Misc_DamageResistanceMod-=TempMod.ModInfo.default.DamageResistanceMod;
		Misc_RegenerationMod+=TempMod.ModInfo.default.RegenerationMod;
		bAffectsWeapon=TempMod.ModInfo.static.bAffectsWeapons();
		if(TempMod.ModInfo.default.EffectPriority < HighestPriority || TempMod.ModInfo.default.EffectPriority == 0) 
		{
			HighestPriority = TempMod.ModInfo.default.EffectPriority;
			//PriorityColor = TempMod.ModInfo.default.EffectColor;
			PriorityModClass = TempMod.ModInfo;
		}
	}
	
	
	if(Rx_Pawn(Pawn) != none) 
	{
		//In case speed was modified. Update animation info
		Rx_Pawn(Pawn).SetSpeedUpgradeMod(Misc_SpeedModifier);
		Rx_Pawn(Pawn).UpdateRunSpeedNode();
		Rx_Pawn(Pawn).SetGroundSpeed();
		Rx_Pawn(Pawn).SetOverlay(PriorityModClass, bAffectsWeapon) ; 
		
		if(Rx_Weapon(Pawn.Weapon) != none) Rx_Weapon(Pawn.Weapon).SetROFChanged(true);	
	}
	else if(Rx_Vehicle(Pawn) != none) 
	{
		//Misc_SpeedModifier+=1.0; //Add one to account for vehicles not operating like Rx_Pawn 
		Rx_Vehicle(Pawn).UpdateThrottleAndTorqueVars();
		Rx_Vehicle(Pawn).SetOverlay(PriorityModClass.default.EffectColor) ; 
		
		if(Rx_Vehicle_Weapon(Pawn.Weapon) != none) Rx_Vehicle_Weapon(Pawn.Weapon).SetROFChanged(true);	
	}
}

function ClearAllModifications()
{
	//Buff/Debuff modifiers
	Misc_SpeedModifier 			= default.Misc_SpeedModifier;

	//Weapons
	Misc_DamageBoostMod 		= default.Misc_DamageBoostMod; 
	Misc_RateOfFireMod 			= default.Misc_RateOfFireMod; 
	Misc_ReloadSpeedMod 		= default.Misc_ReloadSpeedMod; 

	//Survivablity
	Misc_DamageResistanceMod 	= default.Misc_DamageResistanceMod;
	Misc_RegenerationMod 		= default.Misc_RegenerationMod; 	
}

function RemoveAllEffects()
{
	ActiveModifications.Length = 0; 
	
	UpdateModifiedStats(); 
}

function CheckActiveModifiers()
{
	local ActiveModifier TempMod;
	local float			 TimeS; 
	
	if(ActiveModifications.Length < 1) return; 
	
	TimeS=WorldInfo.TimeSeconds; 
	
	//Should never be more than 1 or 2 of these at any given time, so shouldn't affect tick, though can be moved to a timer if necessary. 
	foreach ActiveModifications(TempMod) 
	{
		if(!TempMod.Permanent && TimeS >= TempMod.EndTime) 
		{
			ActiveModifications.RemoveItem(TempMod);
			
			UpdateModifiedStats(); 
		}
	}
}

defaultproperties
{
	targets=TYPE_GROUND
	bIsPlayer = false
	RotationRate=(Pitch=32768,Yaw=60000,Roll=0)
	bSeeFriendly=false
	MaxPredictionSpeed=1000.0
	AimAhead = 1.0	
	bAutoVet = true
	Veterancy_Points=0
	
	//Buff/Nerf Stats
	
	//Buff/Debuff modifiers//

	Misc_SpeedModifier 			= 0.0 

	//Weapons
	Misc_DamageBoostMod 		= 0.0  
	Misc_RateOfFireMod 			= 0.0f //1.0 
	Misc_ReloadSpeedMod 		= 0.0f //1.0 

	//Survivablity
	Misc_DamageResistanceMod 	= 1.0 
	Misc_RegenerationMod 		= 1.0  
}