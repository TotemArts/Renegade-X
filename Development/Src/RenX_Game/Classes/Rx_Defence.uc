class Rx_Defence extends Rx_Vehicle
	implements (Rx_ObjectTooltipInterface)
	abstract;

var AIController ai;
var bool bAIControl;
var class<Rx_Defence_Controller> DefenceControllerClass;

var const byte TeamID;
var Rx_PRI Deployer;
var bool bOwnedDefence;
var int SellBack;
var float SellTime;

replication
{
	if (bNetDirty && Role == ROLE_Authority)
		bAIControl, Deployer, bOwnedDefence, SellTime;

}

simulated function bool CanEnterVehicle(Pawn P)
{
	if (p.Controller.bIsPlayer && bAIControl)
		return false;

	return super.CanEnterVehicle(P);
}

simulated function PostBeginPlay()
{
	super(UTVehicle).PostBeginPlay();
	SetTimer(3.0,false,'Initialize');
}

function Tick( FLOAT DeltaSeconds )
{
	super(UTVehicle).Tick(DeltaSeconds);

	if(bOwnedDefence)
	{
		if(SellTime > 0 && Deployer == None)
		{
			SellTime = FMax(SellTime - DeltaSeconds, 0);

			if(SellTime <= 0)
			{
				Undeploy();
				bOwnedDefence = false;	
			}

			return;
		}

		if(Deployer != None && GetTeamNum() != Deployer.GetTeamNum())
			Deployer = None;

		if(Deployer == None && SellTime <= 0)
		{
			SellTime = 10.0;
		}
	}
}

reliable server function bool SellMe(Rx_PRI Seller)
{
	if(Deployer != Seller)
		return false;

	Rx_Controller(Deployer.Owner).CTextMessage("Sold"@GetHumanReadableName()@"for ["$SellBack$"] credits",'Green');
	Deployer.AddCredits(SellBack);	
	Deployer = None;
	return true;
}

simulated function Undeploy()
{
	TakeDamage(10000, none, Location, vect(0,0,1), class'UTDmgType_LinkBeam');
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local string DeathVPString; 
	local Rx_Controller RxC;

	if(Deployer != None)
	{
		Deployer.DeployedDefenseNumber -= 1; 
		Rx_PRI(Instigator.PlayerReplicationInfo).DeployedDefenses.RemoveItem(Self);
	}
	
	DeathVPString = BuildDeathVPString(Killer, DamageType);
	
	if(Rx_Controller(Killer) != None && GetTeamNum() != Killer.GetTeamNum()) //Rx_Controller(Killer).DisseminateVPString(DeathVPString); 
	{
		if(!bOwnedDefence)
		{
			foreach WorldInfo.AllControllers(class'Rx_Controller', RxC)
			{
				if(RxC.GetTeamNum() == Killer.GetTeamNum()) 
					RxC.DisseminateVPString(DeathVPString);
				else
					continue;
			}
		}
		else
		{
			Rx_Controller(Killer).DisseminateVPString(DeathVPString);
		}
	}


	if(IsTimerActive('Undeploy'))
	{
		ClearTimer('Undeploy');
	}
	
	
	return super(UTVehicle).Died(Killer,DamageType,HitLocation);
}

// Rx_Defence don't count towards CapturePoints, no need to notify.
function NotifyCaptuePointsOfDied(byte FromTeam);
function NotifyCaptuePointsOfTeamChange(byte from, byte to);

function startUpDriving() { }

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
								   const out CollisionImpactData Collision, int ContactIndex ) 
{
	super(UTVehicle).RigidBodyCollision(HitComponent,OtherComponent,Collision,ContactIndex);
}

simulated event SuspensionHeavyShift(float Delta) { }

simulated function DrivingStatusChanged() 
{
	super(UTVehicle).DrivingStatusChanged();
}


function bool TryToDrive(Pawn P)
{
    if(Rx_Controller(P.Controller) != None || Rx_Bot(P.Controller) != None)
    	return false;
    if( WorldInfo.GRI.OnSameTeam(Self,P)){
        StopFiring();
        Seats[0].SeatPawn.DriverLeave(true);
        ai.GotoState('Idle');
    }
    return Super.TryToDrive(P);
}

function DriverLeft()
{
	Super.DriverLeft();

	if(!bAIControl) {
		bAIControl = true;
		ai.Possess(Self, true);
		ai.GotoState('Searching');
	}
	else
	{
		bAIControl = false;
	}
}

function bool AnySeatAvailable()
{
	local int i;
	for (i=0;i<Seats.Length;i++)
	{
		if( ( Seats[i].SeatPawn != none )
			&& ( Seats[i].SeatPawn.Controller==none || Rx_Defence_Controller(Seats[i].SeatPawn.Controller) != none)
			)
		{
			return true;
		}
	}
	return false;
}

function Initialize() 
{
	if(Deployer != None)
		SetTeamNum(Deployer.GetTeamNum());
	else
		SetTeamNum(TeamID);
	ai = Spawn(DefenceControllerClass,self);
	ai.SetOwner(None);  // Must set ai owner back to None, because when the ai possesses this actor, it calls SetOwner - and it would fail due to Onwer loop if we still owned it.

	ai.Possess(self, true);
	bAIControl = true;

	if(Deployer != None)
		PromoteUnit(Deployer.VRank);
}

function bool DriverEnter(Pawn P)
{
	P.StopFiring();

	if (Seats[0].Gun != none)
	{
		InvManager.SetCurrentWeapon(Seats[0].Gun);
	}

	Instigator = self;

	if ( !Super(UTVehicle).DriverEnter(P) )
		return false;

	SetSeatStoragePawn(0,P);

	if (ParentFactory != None)
	{
		ParentFactory.TriggerEventClass(class'UTSeqEvent_VehicleFactory', None, 3);
	}

	if ( PlayerController(Controller) != None )
	{
		VehicleLostTime = 0;
	}
	
	StuckCount = 0;
	ResetTime = WorldInfo.TimeSeconds - 1;
	bHasBeenDriven = true;

	return true;
}

simulated function Destroyed()
{
	loginternal("Turret destroyed");
	if(ai != none)
		ai.UnPossess();
	super.Destroyed();
}

simulated function bool IsEffectedByEMP()
{
	return false;
}

// EMPs are not to affect automated defences
simulated function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor, optional int TimeModifier = 0)
{
	return false;
}

function string BuildDeathVPString(Controller Killer, class<DamageType> DamageType)
{

	if(Killer == none || LastTeamToUse == Killer.GetTeamNum() ) return ""; //Meh, you get nothing

		return "[Emplacement Destroyed]&+" $ default.VPReward[VRank] $ "&" ;
	
}

//A much lighter variant of the VPString builder, used to calculate assists (Which only add in negative modifiers for in-base and higher VRank)
function int BuildAssistVPString(Controller Killer) 
{
	//No Modifiers for the Harvester
	return 0; 	
}

simulated function bool ForceVisible()
{
	return Rx_DefencePRI(PlayerReplicationInfo) != none && Rx_DefencePRI(PlayerReplicationInfo).bSpotted;  
}

simulated function string GetTargetedDescription(PlayerController PlayerPerspective)
{
	if(bOwnedDefence)
	{
		if(Deployer != None)
		{
			if(PlayerPerspective.GetTeamNum() != GetTeamNum())
			{
				return "Deployed Defense";
			}
			else if(Deployer == PlayerPerspective.PlayerReplicationInfo)
			{
				return "Your Defense";
			}
			else
			{
				return "Deployed by"@Deployer.PlayerName;
			}
		}
		else if (SellTime > 0.0)
		{
			return ("Undeploying Defense in : "@FCeil(SellTime));
		}
	}

	return "";
}

simulated function string GetTooltip(Rx_Controller PC)
{
	local string UseKey;

	if(Deployer != PC.PlayerReplicationInfo)
		return "";

	else if(VSizeSq(PC.Pawn.Location - Location) <= 16000000)
	{
		UseKey = "<font color='#ff0000'>["$Caps(Rx_PlayerInput(PC.PlayerInput).GetUDKBindNameFromCommand("GBA_Use"))$"]</font>";

		return "Hold"@UseKey@"to sell this"@GetHumanReadableName()@"for <font color='#00ff00'>"$SellBack$"</font>";
	}

	return "";
}

simulated function bool IsTouchingOnly()
{
	return false;
}

simulated function bool IsBasicOnly()
{
	return false;
}


simulated function byte GetTeamNum()
{
	if(Controller == None && bOwnedDefence && Deployer != None)
		return Deployer.GetTeamNum();

	return super.GetTeamNum();
}

DefaultProperties
{
	DefenceControllerClass=class'Rx_Defence_Controller'
	bBlocksNavigation=true
	GroundSpeed=1
    AirSpeed=0
    MaxSpeed=0
    bReplicateMovement=false
    bAlwaysRelevant=true
	RadarVisibility = 1
	
	VPCost(0) = 0
	VPCost(1) = 0
	VPCost(2) = 0
	
	VPReward(0) = 10
	VPReward(1) = 15
	VPReward(2) = 15
	VPReward(3) = 20
	
	//VP Given on death (by VRank)
	
	Vet_HealthMod(0)=1
	Vet_HealthMod(1)=1.10
	Vet_HealthMod(2)=1.25
	Vet_HealthMod(3)=1.50
	
	RegenerationRate = 4
	/**************************/
	
	SellBack = 300
	
	
}
