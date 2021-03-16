class Rx_Weapon_Beacon extends Rx_Weapon_Deployable;

`include(RenX_Game\RenXStats.uci);

/*These were all PRIVATE variables. Reset them to that if they ever need to go back to that for some reason*/

var  bool     bShowLoadPanel;
var  float    PanelWidth, PanelHeight;   /** width and height of the panel relative to screen size*/
var  float    CurrentProgress;
var  float    TimerSeconds;
var repnotify  bool  bFired;
var Vector   LastPos;
var Vector   CurrentPos;
var float    SecondsNeedLoad;           /** seconds need to load to place Beacon*/
/*END Private variables*/
var() Color   PanelColor;
var SoundCue ChargeCue;
var AudioComponent ChargeCueComp;
var bool bCanCharge;
var bool bCharging;
var bool bRemoveWhenDepleted;
var bool bBlockDeployCloseToOwnBase;
var bool bAffectedByNoDeployVolume;

var bool bAllowDropDeploy;

/*replication
{
   if(bNetDirty && Role == ROLE_Authority)
      bFired;
}*/

//================================================================
// methods
//================================================================

/*public function bool CheckAlreadyFired()
{
   return bFired;
}*/

simulated function PlayDeployAnimation()
{
	PlayWeaponAnimation(WeaponFireAnim[0],SecondsNeedLoad,false);
	PlayArmAnimation(WeaponFireAnim[0],SecondsNeedLoad,false);
	if (Rx_Pawn(Owner) != none)
	{
		Rx_Pawn(Owner).PlayBeaconDeployAnimation();
	}
}

simulated function CancelDeployAnimation()
{
	if (Rx_Pawn(Owner) != none)
	{
		Rx_Pawn(Owner).CancelBeaconDeployAnimation();
	}
}

simulated function bool isMoving()
{
	return (LastPos.X != CurrentPos.X && LastPos.Y != CurrentPos.Y);
}

simulated event Tick (float DeltaTime)
{
	if (Owner != none)
	{
		LastPos = CurrentPos;
		CurrentPos = Owner.Location;
	}
	super.Tick(DeltaTime);
}

simulated function ChargeProgress()
{

}

simulated function BeginFire( Byte FireModeNum )
 {
	if(!isValidPosition())
	{
		return;
	}
	GotoState('Charging');
	BeginFire(FireModeNum);
 }

simulated function ClientFire()
{
     // do some cient related stuff after firing
}

simulated state Charging
{

   simulated function CustomFire()
   {
      //if (Owner.bIsMoving)
      //{
      //   GotoState('Active');
      //   return;
      //}
      //if(!IsInState('Charging'))
       //  SendToFiringState(CurrentFireMode);
      //else
      //   GotoState('Charging', 'EndIt');
   }

   /*simulated function ReplicatedEvent(name VarName)
   {
      if (VarName == 'bFired')
         ClientFire();
      else
         super.ReplicatedEvent(VarName);

   }*/

   simulated function ChargeProgress()
   {
	
      if (isMoving() || Instigator.Physics == PHYS_Falling || Instigator.Physics == PHYS_Swimming)
      {
         ClearPendingFire(0);
		 ClearPendingFire(1);
         bShowLoadPanel = false;
         GotoState('Active');
		 return;
      }

      CurrentProgress+= (1 / SecondsNeedLoad) * 0.025;
      bShowLoadPanel = true;
      if (CurrentProgress >= 1)
      {
         ClearTimer('ChargeProgress');
         bShowLoadPanel = false;
         ServerDeploy();
         SetFlashLocation(vect(0,0,0));
         //Instigator.InvManager.SwitchToBestWeapon( true );
         //SetHidden(true);
		 GotoState('Active');
      }
   }

	simulated function BeginFire( Byte FireModeNum )
   {
		/*if (bFired)
		{
			`log ("Goin inactive");
			GotoState('Inactive');
		}*/
		if (isMoving() || Instigator.Physics == PHYS_Falling || Instigator.Physics == PHYS_Swimming)
		{
			ClearPendingFire(0);
			ClearPendingFire(1);
			GotoState('Active');
		}
		else if (!bCharging)
		{
			bCharging = true;

			if(WorldInfo.NetMode != NM_DedicatedServer) {
      		PlayDeployAnimation();
	  		ChargeCueComp = CreateAudioComponent(ChargeCue, true, true, true, location, true);
      		SetTimer(0.025f, true, 'ChargeProgress');
      		ChargeProgress();
		}
	}
   }

   simulated function BeginState(name PreviousStateName)
   {
   	  super.BeginState(PreviousStateName);	
   	  if(Rx_Pawn_SBH(Instigator) != None)
   	  	 Rx_Pawn_SBH(Instigator).ChangeState('WaitForSt');
   }

   simulated event EndState( Name NextStateName )
   {
	 super.EndState(NextStateName);
		ClearTimer('ChargeProgress');

	 if (bCharging == true)
	 {
		bCharging = false;
	  
     
      CurrentProgress = 0;
      bShowLoadPanel = false;

      if(WorldInfo.NetMode != NM_DedicatedServer) 
      {
		 CancelDeployAnimation();
		 if (ChargeCueComp != none)
		 {
	  		ChargeCueComp.Stop();
		 }
	  }
	 }
   }
}

simulated function CustomFire()   
{
//
}

function bool Deploy()
{
    local Rotator SpawnRot;
    local vector SpawnLoc, SpawnNormal,X, Y, Z;
    local Actor SpawnBase;
    local bool bTraceHit;
	  
	if(!isValidPosition())
	{
		return false;
	}	  
	  
	if(!bAllowDropDeploy)
	{
		bTraceHit = GetBeaconSpawnLoc(SpawnLoc, SpawnNormal, SpawnBase);
	  
		if(!bTraceHit)
			return false;

		GetAxes(Rotator(SpawnNormal),X,Y,Z);
		SpawnRot = Rotator(Z);
	}
	else
	{
		SpawnLoc = Owner.Location;
		SpawnRot = Owner.Rotation;
		SpawnRot.Pitch = 0.0;
	}

    DeployedActor = Spawn(DeployedActorClass, Pawn(Owner).Controller,, SpawnLoc, SpawnRot,,true); 
//      DeployedActor.bCollideComplex=false;
    if(bTraceHit && !bAllowDropDeploy)
    	DeployedActor.Landed(SpawnNormal,SpawnBase); //force land
    else if(bAllowDropDeploy)
    {
    	DeployedActor.bCollideComplex=false;
    	DeployedActor.SetPhysics(PHYS_Falling);
    }

	ClientFire();
    ConsumeAmmo(0);

	  /** one1: Added to remove from inventory. */
	  if (AmmoCount <= 0 && bRemoveWhenDepleted)
		Rx_InventoryManager(Pawn(Owner).InvManager).RemoveWeaponOfClass(self.Class);

      if (DeployedActor == none) 
      {
         loginternal("Error: Beacon could not be placed <spawn problem>");
         return false;
      }

	`RecordGamePositionStat(WEAPON_BEACON_DEPLOYED, DeployedActor.Location, 1);

      return true;
}

function bool GetBeaconSpawnLoc(out vector OutLoc, out vector OutNormal, out Actor HitBase)
{
	local vector TraceStart, TraceEnd, HitLocation,HitNormal;
	local actor A;

	TraceStart = Owner.Location;
	TraceEnd = TraceStart - vect(0,0,1500);

	foreach TraceActors(class'Actor', A, HitLocation, HitNormal, TraceEnd, TraceStart,,,TRACEFLAG_Bullet)
	{
		if(!A.bWorldGeometry || Rx_Weapon_DeployedActor(A) != None)
			continue;

		OutLoc = HitLocation;
		OutNormal = HitNormal;
		HitBase = A;

		return true;
	}

	return false;

}

reliable server function ServerDeploy()
{
	Deploy();
}

simulated function bool IsValidPosition() 
{
	local vector HitLocation, HitNormal, off;
	local Actor HitActor;
	local float ZDistToBuildingCenter;
	local float notCrouchedOffset;
	
	if(bBlockDeployCloseToOwnBase && GetNearestSpottargetLocationIsOwnTeamBuilding())
	{
	  Rx_Controller(Pawn(Owner).Controller).ClientMessage("Planting Beacon failed: This location is too close to your base!");
	  return false;
	}

	if(bAffectedByNoDeployVolume && Rx_Controller(Pawn(Owner).Controller).CheckIfInNoBeaconPlacementVolume())
	{
		Rx_Controller(Pawn(Owner).Controller).ClientMessage("Planting Beacon failed: This is a no-plant zone!");
	  	return false;
	}
	 
	off = Pawn(Owner).location;
	off.z -= 60;  
	
	if(!Pawn(Owner).bIsCrouched) 
	{
		notCrouchedOffset = 15; 
		off.z -= notCrouchedOffset; 		
	}		
	
	HitActor = Trace(HitLocation, HitNormal, off, Pawn(Owner).location, true);
	
	if(HitActor == None || !HitActor.bWorldGeometry)
	{
		Rx_Controller(Pawn(Owner).Controller).ClientMessage("Planting Beacon failed: This location is invalid!");
		return false;
	} 

	if(Rx_Building(HitActor) != none) ZDistToBuildingCenter = abs(Rx_Building(HitActor).location.z - (Pawn(Owner).location.z - notCrouchedOffset));

	if(((Rx_Building(HitActor) != None && ZDistToBuildingCenter > 440) && !(Rx_Building_WeaponsFactory(HitActor) != None && ZDistToBuildingCenter < 800))
	      ||  (Rx_Building_AirTower(HitActor) != None && ZDistToBuildingCenter > 367)
	      ||  (Rx_Building_Refinery(HitActor) != None && !HitActor.IsA('Rx_Building_Refinery_GDI_Ramps') && !HitActor.IsA('Rx_Building_Refinery_Nod_Ramps')
					&& !(ZDistToBuildingCenter > 90 && (Rx_Building(HitActor).location.z - Pawn(Owner).location.z) > 0))
	      ||  (Rx_Building_AirTower(HitActor) != None && !HitActor.IsA('Rx_Building_AirTower_Ramps')
					&& !(ZDistToBuildingCenter > 90 && (Rx_Building(HitActor).location.z - Pawn(Owner).location.z) > 0))
	      ||  (Rx_Building_Barracks(HitActor) != None && !HitActor.IsA('Rx_Building_Barracks_Ramps')
					&& !(ZDistToBuildingCenter > 90 && (Rx_Building(HitActor).location.z - Pawn(Owner).location.z) > 0))	
	      ||  (Rx_Building_PowerPlant(HitActor) != None && !HitActor.IsA('Rx_Building_PowerPlant_GDI_Ramps') && !HitActor.IsA('Rx_Building_PowerPlant_Nod_Ramps')
					&& !(ZDistToBuildingCenter > 90 && (Rx_Building(HitActor).location.z - Pawn(Owner).location.z) > 0)))										
	{
		Rx_Controller(Pawn(Owner).Controller).ClientMessage("Planting Beacon failed: This location is invalid!");
		return false; // to prevent beacons to be placed on chimneys, the Hand of the HON etc
	}
	
	return true; 
}

simulated function bool GetNearestSpottargetLocationIsOwnTeamBuilding() 
{
	local RxIfc_SpotMarker SpotMarker;
	local Actor TempActor;
	local float NearestSpotDist;
	local RxIfc_SpotMarker NearestSpotMarker;
	local float DistToSpot;	
	
	foreach AllActors(class'Actor',TempActor,class'RxIfc_SpotMarker') {
		SpotMarker = RxIfc_SpotMarker(TempActor);
		DistToSpot = VSizeSq(TempActor.location - owner.location);
		if(NearestSpotDist == 0.0 || DistToSpot < NearestSpotDist) {
			NearestSpotDist = DistToSpot;	
			NearestSpotMarker = SpotMarker;
		}
	}
	
	return Rx_Building(NearestSpotMarker) != None && Rx_Building(NearestSpotMarker).GetTeamNum() == Pawn(Owner).GetTeamNum();		
}

simulated function PerformRefill()
{
}


/**
 * Access to HUD and Canvas. Set bRenderOverlays=true to receive event.
 * Event called every frame when the item is in the InventoryManager
 *
 * @param   HUD H
 */
simulated function ActiveRenderOverlays( HUD H )
{
   local Canvas C;
   local float PanX, PanY, PosX, PosY;

   local Rx_Hud RxH;
   local Rx_GFxHud HudMovie;

   super.ActiveRenderOverlays(H);
   C = H.Canvas;
   RxH = Rx_Hud(H);
   HudMovie = RxH.HudMovie;

   if (LastPos != Owner.Location || !bShowLoadPanel || C == none) {
		if (HudMovie != none) {
			HudMovie.HideLoadingBar();
		}
		return;
   } 

   if (HudMovie != none) {
	
	   if (CurrentProgress < 0.5){
			HudMovie.ShowLoadingBar(CurrentProgress, "Loading Coordinates ...");
	   } else {
			HudMovie.ShowLoadingBar(CurrentProgress, "Connecting to satellite ...");
	   }
   } else {
	   // get the draw values
	   PanX = C.SizeX * PanelWidth;
	   PanY = C.SizeY * PanelHeight;
	   // draw the loadpanel border
	   //C.DrawColor = Rx_Hud(H).TeamColors[Owner.GetTeamNum()];
	   C.SetDrawColor(255,64,64,255);
	   PosX = C.SizeX * 0.5f - PanX * 0.5f;
	   PosY = C.SizeY - PanY - 200;
	   C.SetPos(PosX, PosY);
	   C.DrawBox(PanX, PanY);
	   // draw the text
	   C.SetPos(PosX+3, PosY+3);

	   if (CurrentProgress < 0.5)
		  C.DrawText("Loading Coordinates ...");
	   else
		  C.DrawText("Connecting to satellite ...");
	   // draw the loadpanel anim
	   C.DrawColor.A = 50;
	   C.SetPos(PosX + 1, PosY + 1);
	   C.DrawRect(PanX * CurrentProgress - 2, PanY - 2);
   }

}

simulated function float GetWeaponRating()
{
	return -1;
}

simulated function bool CanThrow()
{
	return false; //true; Re-enable when we have this fully fleshed out. 
}

function DropFrom(vector StartLocation, vector StartVelocity)
{
	/******* Uncomment if we ever decide to actually use this ***********
	local String DropLocation;
	local PlayerController PC;
	
	
	
	DropLocation = Rx_Controller(Pawn(Owner).Controller).GetSpottargetLocationInfo(self);
	foreach WorldInfo.AllControllers(class'PlayerController', PC) {
		if (PC.PlayerReplicationInfo.Team == Pawn(Owner).Controller.PlayerReplicationInfo.Team) {
			WorldInfo.Game.BroadcastHandler.BroadcastText(Instigator.PlayerReplicationInfo, PC, "Beacon dropped"@DropLocation, 'TeamSay');
		}
	}	
	*/
	super.DropFrom(StartLocation,StartVelocity);
	SetTimer(10.0, false, 'Destroy');
}

simulated static function bool IsBuyable(Rx_Controller C)
{
	local Rx_GRI GRI;

	if(C.WorldInfo.NetMode == NM_Standalone)
		return true;

	GRI = Rx_GRI(C.WorldInfo.GRI);

	if(GRI == None)
	{
		return false;
	}

	return GRI.bEnableNuke;
}

defaultproperties
{
	bCanCharge = true
	bRemoveWhenDepleted = true
	bBlockDeployCloseToOwnBase = true
	bAffectedByNoDeployVolume = true
	bDropOnDeath = false//true
	bCanGetAmmo=false

	WeaponFireSnd(0)=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Fire'
   	FiringStatesArray(0)="Charging"
   	WeaponFireTypes(0)=EWFT_Custom

	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object
   	
	AmmoCount=1
   	MaxAmmoCount=1

   	ShotCost(0)=1
   	FireInterval(0)=3.0f

	SecondsNeedLoad = 4

	WeaponPutDownSnd=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'
	
	ThirdPersonWeaponPutDownAnim="H_M_Beacon_PutDown"
	ThirdPersonWeaponEquipAnim="H_M_Beacon_Equip"

	ReloadAnimName(0) = "weaponequip"
	ReloadAnimName(1) = "weaponequip"
	ReloadAnim3PName(0) = "H_M_Beacon_Equip"
	ReloadAnim3PName(1) = "H_M_Beacon_Equip"
	ReloadArmAnimName(0) = "weaponequip"
	ReloadArmAnimName(1) = "weaponequip"

	MaxDesireability=0.1
	AIRating=+0.1
	CurrentRating=0.1
	InventoryGroup=6
	GroupWeight=1

	ClipSize = 1
	InitalNumClips = 1
	MaxClips = 1
	bUseClientAmmo = false

	Price = 1000
}