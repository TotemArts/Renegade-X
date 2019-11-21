class Rx_Weapon_Deployable extends Rx_Weapon_Reloadable
	abstract;

/** class of deployable actor to spawn */
var class<Rx_Weapon_DeployedActor> DeployedActorClass;

/** Toss strength when throwing out deployable */
var float TossMag;

/** Scale for deployable when being scaled for a preview in a stealth vehicle*/
var float PreviewScale;

/** if true, factory delays respawn countdown until this deployable is used */
var bool bDelayRespawn;

/** Radius to check against for other deployables nearby*/
var() float DeployCheckRadiusSq;

var SoundCue DeployFailedSoundCue;
var Rx_Weapon_DeployedActor DeployedActor;



static function class<Actor> GetTeamDeployable(int TeamNum)
{
	return default.DeployedActorClass;
}

/** Recommend an objective for player carrying this deployable */
function UTGameObjective RecommendObjective(Controller C)
{
	return None;
}

simulated function vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	return (Instigator != none) ? (Instigator.GetPawnViewLocation() + (FireOffset >> Instigator.GetViewRotation())) : Location;
}

//Given an actor, its position and a radius determine if we are near any deployables
static function bool DeployablesNearby(Actor MyActor, vector MyLocation, float CheckRadiusSq, optional out Rx_Weapon_DeployedActor Deployed)
{
	local float DistSqr;
	local Rx_Weapon_DeployedActor Actor;

	if ( MyActor.Instigator == None )
	{
		return true;
	}

	//Check the area for deployables
	foreach MyActor.DynamicActors(class'Rx_Weapon_DeployedActor', Actor)
	{
		if ( MyActor.WorldInfo.GRI.OnSameTeam(MyActor.Instigator, Actor) )
		{
			DistSqr = VSizeSq(Actor.Location - MyLocation);
			if (DistSqr < CheckRadiusSq)
			{
				Deployed = Actor;
				return TRUE;
			}
		}
	}

	return FALSE;
}

/** attempts to deploy the item
 * @return whether or not deploying was successful
 */
function bool Deploy()
{
	local vector SpawnLocation;
	local rotator Aim, FlatAim;

	SpawnLocation = GetPhysicalFireStartLoc();
	Aim = GetAdjustedAim(SpawnLocation);
	FlatAim.Yaw = Aim.Yaw - 16384;

	DeployedActor = Spawn(DeployedActorClass,,, SpawnLocation, FlatAim);
	
	if (DeployedActor != None)
	{
		DeployedActor.VRank=VRank; 
		
		//ClientSubtractAmmo();
		
		if ( AmmoCount <= 0 )
		{
			bForceHidden = true;
			Mesh.SetHidden(true);
		}
		DeployedActor.Velocity = TossMag * vector(Aim);
		return true;
	}

	return false;
}

reliable client function ClientSubtractAmmo() //Used to get around Deployables being mostly server-side.. At least visually shows correctly
{
	if(WorldInfo.Netmode != NM_Client) return; 
	else
	ConsumeAmmo(0); //Unless someday deployables have more than one fire mode. 
}

/** called when User tries to deploy us and fails for some reason */
function DeployFailed(optional bool bDeployablesAreNearby=false)
{
	// refund ammo
	AddAmmo(ShotCost[CurrentFireMode]);
	ClientDeployFailed(bDeployablesAreNearby);
}

/** called to notify client of deploy failure */
reliable client function ClientDeployFailed(bool bDeployablesAreNearby)
{
	if (DeployFailedSoundCue != None)
	{
		Instigator.PlaySound(DeployFailedSoundCue);
	}

	if (bDeployablesAreNearby)
	{
		//This is the message "unable to deploy due to close proximity"
		//Instigator.ReceiveLocalizedMessage(class'UTStealthVehicleMessage', 2);
	}
	else
	{
		//This is the message "Can't deploy here"
		//Instigator.ReceiveLocalizedMessage(class'UTDeployableMessage', 0);
	}
}

simulated function CustomFire()
{
	local bool bAreDeployablesNearby;

	//Deployable radius check here so UTSlowVolume uses it too
	if (Role == ROLE_Authority)
	{
		bAreDeployablesNearby = DeployablesNearby(self, GetPhysicalFireStartLoc(), DeployCheckRadiusSq);
		if (bAreDeployablesNearby)
		{
			DeployFailed(bAreDeployablesNearby);
		}
		else if (!Deploy())
		{
			DeployFailed();
		}
		else {
			SetFlashLocation(vect(0,0,0));
		}
	}
}

function OvermineBroadcast()
{
	local Rx_Controller PC;
	local string Message;

	Message = Instigator.Controller.PlayerReplicationInfo.PlayerName $ " is over-mining " $ Rx_Controller(Instigator.Controller).GetSpottargetLocationInfo(self);
	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
		if (Instigator.GetTeamNum() == PC.GetTeamNum())
			PC.ClientMessage(Message, 'EVA');

	`LogRx("GAME" `s "OverMine;" `s `PlayerLog(Instigator.Controller.PlayerReplicationInfo) `s "near" `s Rx_Controller(Instigator.Controller).GetSpottargetLocationInfo(self));
}

function destroyOldMinesIfMinelimitReached() {

	local Rx_TeamInfo teamInfo;
	local Rx_Weapon_DeployedC4 mine, oldestMine;

	teamInfo = Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[Instigator.GetTeamNum()]);
	if(teamInfo.MineLimit <= teamInfo.mineCount)
	{
		foreach DynamicActors(class'Rx_Weapon_DeployedC4', mine) 
		{
			//if(Rx_Weapon_DeployedRemoteC4(mine) == none && RenProxy(mine) == none) {
			if(!mine.bUsesMineLimit || mine.GetTeamNum() != teamInfo.GetTeamNum()) 
			{
				continue;
			}
			if(oldestMine == None) 
			{
				oldestMine = mine;
			} 
			else if(mine.CreationTime < oldestMine.CreationTime) 
			{
				oldestMine = mine;
			}
		}
		oldestMine.Destroy();
		OvermineBroadcast();
	}
}


simulated function float MaxRange()
{
	return 200.0;
}

function bool CanAttack(Actor Other)
{
	if (Instigator == None || Instigator.Controller == None)
	{
		return false;
	}
	if (VSizeSq(Instigator.Location - Other.Location) > Square(MaxRange()))
	{
		return false;
	}
	return Instigator.Controller.LineOfSightTo(Other);
}

function PromoteWeapon(byte rank)
{
super(Rx_Weapon).PromoteWeapon(rank);  
//if(Rx_Pawn(Instigator).PawnInFriendlyBase("", Instigator)) PerformRefill();  
}

simulated state WeaponPuttingDown
{
    simulated event BeginState( Name PreviousState )
    {
        if (bDebugWeapon)
        {
            `log("---"@self$"."$GetStateName()$".BeginState("$PreviousState$")");
        }
        ClearFlashLocation(); //Reset the flash location so other weapons don't use it when they're switched to
        super.BeginState(PreviousState);
    }

}

defaultproperties
{
	WeaponFireTypes[0]=EWFT_Custom
	WeaponFireTypes[1]=EWFT_None
	ShotCost[0]=1
	AmmoCount=1
	MaxAmmoCount=1
	InventoryGroup=10
	RespawnTime=1.0
	TossMag=580
	bDelayRespawn=true
	MaxDesireability=0.0
	AIRating=+0.6
	CurrentRating=0.0
	bUseClientAmmo = false 
	bMeleeWeapon = true

	DeployCheckRadiusSq=0.0;

	bExportMenuData=false
	PreviewScale=1.0

	FireInterval(0)=+2.0
	FireInterval(1)=+2.0

	EquipTime=1.0
	PutDownTime=0.01
	
	bRefillonPromotion = false 
	
	bUseHandIKWhenRelax=false
	bByPassHandIK=true
	bLimitAmmoForScripted=true
}