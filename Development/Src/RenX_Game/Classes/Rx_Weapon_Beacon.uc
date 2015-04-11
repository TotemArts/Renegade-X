class Rx_Weapon_Beacon extends Rx_Weapon_Deployable;

var private bool     bShowLoadPanel;
var float    SecondsNeedLoad;           /** seconds need to load to place Beacon*/
var private float    PanelWidth, PanelHeight;   /** width and height of the panel relative to screen size*/
var private float    CurrentProgress;
var private float    TimerSeconds;
var repnotify private bool  bFired;
var() Color   PanelColor;
var private Vector   LastPos;
var private Vector   CurrentPos;
var SoundCue ChargeCue;
var AudioComponent ChargeCueComp;
var bool bCanCharge;
var bool bCharging;
var bool bRemoveWhenDepleted;
var bool bBlockDeployCloseToOwnBase;

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
      if (isMoving() || Instigator.Physics == PHYS_Falling)
      {
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
		if (isMoving())
		{
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
      local Rotator FlatAim;


	  if(bBlockDeployCloseToOwnBase && GetNearestSpottargetLocationIsOwnTeamBuilding())
	  {
	  	Rx_Controller(Pawn(Owner).Controller).ClientMessage("Planting Beacon failed: This location is too close to your base!");
	  	return false;	
	  }

      FlatAim.Yaw = 0;
      FlatAim.Pitch = 0;
      FlatAim.Roll = 0;

      DeployedActor = Spawn(DeployedActorClass, Pawn(Owner).Controller,, Owner.Location, FlatAim);

      //bFired = true;
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
      return true;
   }

reliable server function ServerDeploy()
{
	Deploy();
}

function bool GetNearestSpottargetLocationIsOwnTeamBuilding() 
{
	local RxIfc_SpotMarker SpotMarker;
	local Actor TempActor;
	local float NearestSpotDist;
	local RxIfc_SpotMarker NearestSpotMarker;
	local float DistToSpot;	
	
	foreach AllActors(class'Actor',TempActor,class'RxIfc_SpotMarker') {
		SpotMarker = RxIfc_SpotMarker(TempActor);
		DistToSpot = VSize(TempActor.location - owner.location);
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

   super.ActiveRenderOverlays(H);
   C = H.Canvas;

   if (LastPos != Owner.Location || !bShowLoadPanel || C == none)
      return;

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

simulated function float GetWeaponRating()
{
	return -1;
}

defaultproperties
{
	bCanCharge = true
	bRemoveWhenDepleted = true
	bBlockDeployCloseToOwnBase = true

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
}