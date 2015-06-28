/*********************************************************
*
* File: Rx_Vehicle_StealthTank.uc
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
class Rx_Vehicle_StealthTank extends Rx_Vehicle_Treaded
    placeable;

//================================================================
// Stealth-related variables
//================================================================
var protected float                    TimeStealthDelay;    // seconds we need to stay without action to get stealthed
var protected float                    TimeLastAction;      // time(stamp) when last action was performed
var protected float                    DistMaxNoticePlayers; 
var protected float                    DistMaxNoticeVehicles;
var protected float                    CurrentMaxNoticeDistance;
var() float                            LowHpMult;           // HealthMax * LowHpMult is the value for LowHP damage use
var int                                EMPFieldCount;
//================================================================
// Mat/Mesh-related variables
//================================================================
var protected MaterialInstanceConstant MICDestTrack;        // MIC for destroyed tracks
var protected MaterialInstanceConstant MICDestroyed;        // MIC for destroyed main
var protected MaterialInstanceConstant MICTrack;            // MIC for Tracks
var protected MaterialInstanceConstant MICTrackStealthed;   // MIC for Tracks
var protected MaterialInstanceConstant MICStealthed;        // MIC for Stealthed status
var protected MaterialInstanceConstant MICNormal;           // MIC for noramal use
var protected MaterialInterface        MatTrackStealthed;   // Mat for stealthed
var protected MaterialInterface        MatStealthed;        // Mat for stealthed
var protected MaterialInterface        MatNormal;           // Mat for normal use
var protected bool                     bCreated;
var protected bool                     bStealthMatInitialized;
var protected bool					   bIsInvisible;
var private float 					   StealthVisibilityDistance;	// Distance at wich enemys start to see an SBH	
var private float 					   BeenshotStealthVisibilityModifier;		
var private float 				       MaxStealthVisibility;		// Max decloakvalue for when enemys get close to an SBH	
var private int 					   LastHealthBeenShot;

// ERASE:
//var float Time1, Time2;


//================================================================
// state-related variables
//================================================================
var repnotify name                     CurrentState;
var protected PlayerController         LocalPC;

//================================================================
// replication
//================================================================
replication {
	if ((bNetDirty && Role == Role_Authority) || (bNetInitial && Role == Role_Authority))
		CurrentState, bIsInvisible;
}

simulated function ReplicatedEvent(name VarName) {
	if (VarName == 'CurrentState') {
      	ClientAdjustState();
	}
	else {
		super.ReplicatedEvent(VarName);
	}
}

simulated function PostBeginPlay()
{
   super.PostBeginPlay();
}


//================================================================
// General functions
//================================================================
simulated function ClientAdjustState() {
   GotoState(CurrentState);
}
function ChangeState (name newState) {
   CurrentState = NewState;
   GotoState(newState);
}

simulated function BlowupVehicle() {
   Mesh.SetMaterial(0, MICDestroyed);
   Mesh.SetMaterial(1, MICDestTrack);
   Mesh.SetMaterial(2, MICDestTrack);
   DynamicLightEnvironmentComponent(Mesh.LightEnvironment).bCastShadows = true;
   UpdateShadowSettings(!class'Engine'.static.IsSplitScreen() && class'UTPlayerController'.Default.PawnShadowMode == SHADOW_All);
   super.BlowupVehicle();
}

//================================================================
// Stealth-related functions (and states)
//================================================================

simulated function SetMovementEffect(int SeatIndex, bool bSetActive, optional UTPawn UTP)
{
	if (IsInState('Stealthed') || IsInState('BeenShot'))
	   super.SetMovementEffect(SeatIndex, false);
	else
	   super.SetMovementEffect(SeatIndex, bSetActive, UTP);
}

function EnteredEMPField(Rx_EMPField EMPCausingActor)
{
	if (EMPFieldCount++ == 0 && !bEMPd)
	{
		if (!IsInState('LowHP'))
			ChangeState('WaitForSt');
	}
}

function LeftEMPField(Rx_EMPField EMPCausingActor)
{
	--EMPFieldCount;
}

/* =============
 * state Idle - when the vehicle was created or left and
 * health > healthmax*LowHpMult else state LowHP is used
 */
auto state Idle
{

   /*
    * starts up some things like the MIC
    */
   simulated function BeginState(name PreviousStateName) // TODO: check for server usage! -> move Client-Only!
   {
      //`Log("============ WE ARE IN Idle ===============");
      if (!bCreated) { // create the MICs and get a reference to the used Mat
         MICStealthed = new(outer) class'MaterialInstanceConstant';
         MICStealthed.SetParent(MatStealthed);
         
    	 MICTrackStealthed = new(outer) class'MaterialInstanceConstant';
		 MICTrackStealthed.SetParent(MatTrackStealthed);
         
         MICNormal = MaterialInstanceConstant(Mesh.GetMaterial(0));
         bCreated = true;
         if (WorldInfo.NetMode != NM_DedicatedServer) {
            foreach LocalPlayerControllers(class'PlayerController', LocalPC) {
               break;
            }
         }         
      }

	  DynamicLightEnvironmentComponent(Mesh.LightEnvironment).bCastShadows = true;
	  UpdateShadowSettings(true);
	    
	  UpdateStealthAnimParam(0.0f); 
   }

   simulated function bool DriverEnter(Pawn P)
   {
      ChangeState('WaitForSt');
      return super.DriverEnter(P);
   }

   simulated function TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
   {
      Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
      if (Health <= HealthMax*LowHpMult) {
         ChangeState('LowHP');
      }
   }

}

/* =============
 * state WaitForSt - all the time checks are performed here
 * and the main decision point for getting stealthed
 */
simulated state WaitForSt // also called driving
{

   /*
    * start up state
    */
   simulated function BeginState(name PreviousStateName)
   {
      //`Log("============ WE ARE IN WaitForSt ===============");
      // here we need to set to half TODO!
      DynamicLightEnvironmentComponent(Mesh.LightEnvironment).bCastShadows = true;
      UpdateShadowSettings(true);
      TimeLastAction = WorldInfo.TimeSeconds;
      // start the check for going to st state
      SetTimer(0.5f, true, 'StWait');
   }

   simulated function StWait () {
	  if( EMPFieldCount > 0 )
   	  {
   	  	 TimeLastAction = WorldInfo.TimeSeconds;
   	  	 return;
   	  }
      if (WorldInfo.TimeSeconds - TimeLastAction >= TimeStealthDelay) {
 	  	  ChangeState('PlayStealthAnim');
      }
   }

   simulated function bool DriverLeave(bool bForceLeave)
   {
      ChangeState('Idle');
      return Super.DriverLeave(bForceLeave);
   }

   simulated function TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
   {
      Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
      if (Health <= HealthMax*LowHpMult) {
         ChangeState('LowHP');
      }
   }

   simulated function VehicleWeaponFired(bool bViaReplication, vector HitLocation, int SeatIndex)
   {
      TimeLastAction = WorldInfo.TimeSeconds;
      super.VehicleWeaponFired(bViaReplication, HitLocation, SeatIndex);
   }

   /*
    * clean up state
    */
   simulated function EndState(Name NextStateName)
   {
      ClearTimer('StWait');
   }
}

/* =============
 * state PlayStealthAnim - state where we just play the
 * animatuon to go to the stealthed state
 *
 */
simulated state PlayStealthAnim
{
   /*
    * start up state
    */
   simulated function BeginState(name PreviousStateName)
   {
      //`Log("============ WE ARE IN PlayStealthAnim ===============");
      // FIXME: DO NOT PLAY THIS ON THE SERVER! (find a way to fix that)
      FirstVanish();
   }

   simulated function FirstVanish() {

      // TODO: what about the mesh overlay?!

      if (WorldInfo.NetMode != NM_DedicatedServer)
      {
      	Mesh.SetMaterial(0, MICStealthed);
      	Mesh.SetMaterial(1, MICTrackStealthed);
      	Mesh.SetMaterial(2, MICTrackStealthed);
		LeftTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(LeftTeadIndex);
		RightTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(RightTreadIndex);      	
      }
      UpdateStealthAnimParam(0.0f);
      ChangeVisibilityToCloaked();
      bStealthMatInitialized = true;
      Settimer (0.025f, true, 'PlayVanish');
      Settimer (2.5f, false, 'SwitchToStealthedState');     
      
   }
   
   simulated function SwitchToStealthedState() {
	    ChangeState('Stealthed');
   }

   simulated function PlayVanish() {
      local float F;
      MICStealthed.GetScalarParameterValue ('Stealth_Animation', F);
      if (F < 1.0f) {
         F += 0.01f;
         UpdateStealthAnimParam(F);
      } else {
         ClearTimer('PlayVanish');
      }
   }

   simulated function TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
   {
      Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
      if (Health <= HealthMax*LowHpMult) {
         ChangeState('LowHP');
      }
      else
      {
         if(EventInstigator != None && GetTeamNum() != EventInstigator.GetTeamNum())
         	ChangeState('BeenShot');
      }
   }

   simulated function VehicleWeaponFired(bool bViaReplication, vector HitLocation, int SeatIndex)
   {
      ChangeState('WaitForSt');
      super.VehicleWeaponFired(bViaReplication, HitLocation, SeatIndex);
   }

   simulated function bool DriverLeave(bool bForceLeave)
   {
      ChangeState('Idle');
      return Super.DriverLeave(bForceLeave);
   }

   /*
    * clean up state
    */
   simulated function EndState(Name NextStateName)
   {
      ClearTimer('PlayVanish');
      ClearTimer('SwitchToStealthedState');
      if (NextStateName != 'Stealthed' && NextStateName != 'BeenShot') {
      	 SetTimer(0.025, true, 'DeCloak');      	 
      } else {
      	 UpdateStealthAnimParam(1.0f);
      }
   }

}

simulated function DeCloak() {
  	local float F;
  	MICStealthed.GetScalarParameterValue ('Stealth_Animation', F);
  	if (F > 0.0f) {
     	F -= 0.083f;
     	if(F < 0) {
     		F = 0;
     	}
     	UpdateStealthAnimParam(F);
    } else {
        Mesh.SetMaterial(0, MICNormal);
        Mesh.SetMaterial(1, MICTrack);
        Mesh.SetMaterial(2, MICTrack); 

		LeftTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(LeftTeadIndex);
		RightTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(RightTreadIndex);
		
        UpdateStealthVisibilityParam(0.0f);
        UpdateNewStealthVisibilityParam(1.0f);
		ClearTimer('DeCloak');	
		ClearTimer('SwitchToStealthedState');	
		ClearTimer('UpdateStealthBasedOnDistanceTimer');
	}
}

simulated function ChangeVisibilityToCloaked() {

	if(WorldInfo.NetMode != NM_DedicatedServer && LocalPC == None) {
        foreach LocalPlayerControllers(class'PlayerController', LocalPC) {
           break;
        }
	}
    if (WorldInfo.NetMode != NM_DedicatedServer) { 
        if (LocalPC.GetTeamNum() == self.GetTeamNum()) {
        	UpdateStealthVisibilityParam(0.0f);
        } else {
        	if(Vehicle(LocalPC.Pawn) != None) {
        		ChangeStealthVisibilityParam(false);	
        	} else {
        		ChangeStealthVisibilityParam(true);	
        	}
        }
     }
}


/* =============
 * state Stealthed - main st state
 *
 */
simulated state Stealthed
{
   simulated function setupStealthed ()
   {
      if (WorldInfo.NetMode != NM_DedicatedServer)
      {
         Mesh.SetMaterial(0, MICStealthed);
         Mesh.SetMaterial(1, MICTrackStealthed);
         Mesh.SetMaterial(2, MICTrackStealthed);
		 LeftTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(LeftTeadIndex);
		 RightTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(RightTreadIndex);               
      }
   }

   /*
    * start up state
    */
   simulated function BeginState(name PreviousStateName)
   {
      bIsInvisible = true;
      if(!bStealthMatInitialized) {
        Mesh.SetMaterial(0, MICStealthed);
        Mesh.SetMaterial(1, MICTrackStealthed);
        Mesh.SetMaterial(2, MICTrackStealthed);
		LeftTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(LeftTeadIndex);
		RightTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(RightTreadIndex);              
    	UpdateStealthAnimParam(1.0f);
    	UpdateStealthVisibilityParam(0.001f);
      	setTimer(2.0f, false, 'ChangeVisibilityToCloaked');
      }
      
      SetMovementEffect(0,false);
      DisableDamageSmoke();
      UpdateShadowSettings(true);
      // for other playser that recently joined but ST was stealthed
      if (SpawnTime <= 1.0f)
      {
         setupStealthed();
      }

      DynamicLightEnvironmentComponent(Mesh.LightEnvironment).bCastShadows = false;
      UpdateShadowSettings(false);
      
      if(Role == Role_SimulatedProxy) {
      	  EngineSound.VolumeMultiplier = 0.3;
      	  //Wheels[0].WheelParticleSystem.
      }
      
       if (WorldInfo.NetMode != NM_DedicatedServer && LocalPC.GetTeamNum() != self.GetTeamNum())
      	SetTimer(0.1, true, 'UpdateStealthBasedOnDistanceTimer');
   }

   simulated function bool DriverLeave(bool bForceLeave)
   {
      ChangeState('Idle');
      return Super.DriverLeave(bForceLeave);
   }

   simulated function VehicleWeaponFired(bool bViaReplication, vector HitLocation, int SeatIndex)
   {
      ChangeState('WaitForSt');
      super.VehicleWeaponFired(bViaReplication, HitLocation, SeatIndex);
   }

   simulated function TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
   {
      Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
      if (Health <= HealthMax*LowHpMult)
      {
         ChangeState('LowHP');
      }
      else
      {
         if(EventInstigator != None && GetTeamNum() != EventInstigator.GetTeamNum())
         	ChangeState('BeenShot');
      }
   }

   /*
    * clean up state
    */
   simulated function EndState(Name NextStateName)
   {
      bIsInvisible = false;
      // need same mat in BeenShot
      if (NextStateName != 'BeenShot')
      {
         SetTimer(0.025, true, 'DeCloak');
         CheckDamageSmoke();
         UpdateShadowSettings(true);
         SetMovementEffect(0,true);
      }
      if(Role == Role_SimulatedProxy) {
      	  EngineSound.VolumeMultiplier = 1.0;		
      }      
   }
}

simulated function UpdateStealthBasedOnDistanceTimer()
{	
	local float StealthValue;
	
	
	if(!IsInState('Stealthed') && !IsInState('BeenShot'))
		return;
		
	if(LocalPC.Pawn == None)
		return;		
	
	if(IsInState('BeenShot') && (Health != LastHealthBeenShot))
	{
		SetTimer(0.6, false, 'ChangeToPlayStealthAnimState');
		BeenshotStealthVisibilityModifier = default.BeenshotStealthVisibilityModifier;	
		LastHealthBeenShot = Health;
	}
	
	StealthValue = VSize(LocalPC.Pawn.location - location);
	//loginternal(StealthValue);
	
	// 1 = completely visible	
	StealthValue = 1.2 - StealthValue/StealthVisibilityDistance;
	if(StealthValue < 0.0)
		StealthValue = 0.0;
		
	if(BeenshotStealthVisibilityModifier > 0.0f)
	{	
		BeenshotStealthVisibilityModifier -= 0.2;
		if(StealthValue + BeenshotStealthVisibilityModifier > StealthValue)
			StealthValue += BeenshotStealthVisibilityModifier;	
	}		
	
	if(BeenshotStealthVisibilityModifier <= 0.0)
	{
		if(StealthValue > MaxStealthVisibility && BeenshotStealthVisibilityModifier <= 0.0)
		{
			StealthValue = MaxStealthVisibility;	 		
		}
	}	
	
	if(StealthValue > 1.0)
		StealthValue = 1.0;		
		
	if(StealthValue < 0.0)
		StealthValue = 0.0;	
	
	//loginternal(StealthValue);
	
	UpdateNewStealthVisibilityParam(StealthValue);
}

/* =============
 * state LowHP - idle state if health <= healthmax*0.1
 *
 */
simulated state LowHP
{

   simulated function BeginState(name PreviousStateName)
   {
      //`Log("============ WE ARE IN LowHP ===============");
      if (bDriving){
      	 UpdateStealthAnimParam(0.1f);
      }
      else {
      	UpdateStealthAnimParam(0.0f);
      }
   }

   function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
   {
      if (Health + Amount > HealthMax*LowHpMult && !bDriving)
         ChangeState('Idle');
		else if (Health + Amount > HealthMax*LowHpMult)
			ChangeState('WaitForSt');

      return Super.HealDamage(Amount, Healer, DamageType);
   }

}

/* =============
 * state BeenShot - st been shot and is visible to the enemy
 *
 */
simulated state BeenShot
{
   simulated function BeginState(name PreviousStateName)
   {
      if (WorldInfo.NetMode != NM_DedicatedServer && LocalPC.GetTeamNum() != self.GetTeamNum()) {
      	//SetTimer(0.05f, true, 'PlayApper');
      }
      SetTimer(0.6, false, 'ChangeToPlayStealthAnimState');
      BeenshotStealthVisibilityModifier = default.BeenshotStealthVisibilityModifier;
      LastHealthBeenShot = Health;
   }

   simulated function TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
   {
      Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
      if (Health <= HealthMax*LowHpMult) {
         ChangeState('LowHP');
      }
      else {
    	if(EventInstigator != None && GetTeamNum() != EventInstigator.GetTeamNum())
    	{
      		BeenshotStealthVisibilityModifier = default.BeenshotStealthVisibilityModifier;  
    		SetTimer(0.6, false, 'ChangeToPlayStealthAnimState');
    	}
      }
   }
   
   simulated function ChangeToPlayStealthAnimState() {
  	 ChangeState('Stealthed');   	
   }

   simulated function bool DriverLeave(bool bForceLeave)
   {
      ChangeState('Idle');
      return Super.DriverLeave(bForceLeave);
   }

   simulated function VehicleWeaponFired(bool bViaReplication, vector HitLocation, int SeatIndex)
   {
      ChangeState('WaitForSt');
      super.VehicleWeaponFired(bViaReplication, HitLocation, SeatIndex);
   }

   /*
    * clean up
    */
   simulated function EndState(Name NextStateName)
   {
      // need same mat in BeenShot
      if (NextStateName != 'Stealthed') {
         bIsInvisible = false;
         Mesh.SetMaterial(0, MICNormal);
         Mesh.SetMaterial(1, MICTrack);
         Mesh.SetMaterial(2, MICTrack);
		 LeftTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(LeftTeadIndex);
		 RightTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(RightTreadIndex);        
      }
      ClearTimer('ChangeToPlayStealthAnimState');
      BeenshotStealthVisibilityModifier = 0.0;
   }
}    

simulated function UpdateStealthAnimParam(float value) {
	MICStealthed.SetScalarParameterValue('Stealth_Animation', value);	
	MICTrackStealthed.SetScalarParameterValue('Stealth_Animation', value);	
}

simulated function UpdateStealthVisibilityParam(float value) {
	//MICStealthed.SetScalarParameterValue('PixelDepth', value);
	//MICTrackStealthed.SetScalarParameterValue('PixelDepth', value);	
}

/** A value of 0 being not visible, and a value of 1 being completely visible. */
simulated function UpdateNewStealthVisibilityParam(float value) {
	MICStealthed.SetScalarParameterValue('Stealth_Visibility', value);	
	MICTrackStealthed.SetScalarParameterValue('Stealth_Visibility', value);	
}

simulated function ChangeStealthVisibilityParam(bool ForOnFoot) {
	if(ForOnFoot) {
		//MICStealthed.SetScalarParameterValue('PixelDepth', DistMaxNoticePlayers);
		//MICTrackStealthed.SetScalarParameterValue('PixelDepth', DistMaxNoticePlayers);
		CurrentMaxNoticeDistance = DistMaxNoticePlayers; 	
	} else {
		//MICStealthed.SetScalarParameterValue('PixelDepth', DistMaxNoticeVehicles);
		//MICTrackStealthed.SetScalarParameterValue('PixelDepth', DistMaxNoticeVehicles);
		CurrentMaxNoticeDistance = DistMaxNoticeVehicles;
	}
}

function bool IsInvisible() {
	return bIsInvisible; // todo: check why this is not sufficient enoguh for bots not seeing me
}
     

DefaultProperties
{
   	TimeStealthDelay = 4.0f    //  seconds we need to stay without action to get stealthed
   	LowHpMult = 0.15f           //  HealthMax * LowHpMult is the value for LowHP (damaged) use

	DistMaxNoticePlayers  = 0.00085f   // remember to test this! and anjust similar to CCR
	DistMaxNoticeVehicles = 0.00085f    // and this
	
   	MatStealthed 	  = MaterialInterface'RX_VH_StealthTank.Materials.MI_StealthTank_Cloaked'
   	MICTrack 		  = MaterialInstanceConstant'RX_VH_StealthTank.Materials.MI_VH_Tracks'
   	MatTrackStealthed = MaterialInterface'RX_VH_StealthTank.Materials.MI_Treads_Cloaked'
   	//MICDestroyed = MaterialInstanceConstant'RX_VH_StealthTank.Materials.MI_VH_StealthTank_BO'
   	//MICDestTrack = MaterialInstanceConstant'RX_VH_StealthTank.Materials.MI_VH_Tracks_BO'	

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


    Health=400
    MaxDesireability=0.8
    MomentumMult=0.7
    bCanFlip=False
    bTurnInPlace=True
    bSeparateTurretFocus=True
    CameraLag=0.15 //0.25
	LookForwardDist=250
    GroundSpeed=300
    MaxSpeed=1000
    LeftStickDirDeadZone=0.1
    TurnTime=18
     ViewPitchMin=-13000
    HornIndex=1
    COMOffset=(x=0.0,y=0.0,z=-30.0)
    
    BeenshotStealthVisibilityModifier = 1.0
	StealthVisibilityDistance = 650
	MaxStealthVisibility = 0.2
	
	SprintTrackTorqueFactorDivident=1.125

    Begin Object Class=SVehicleSimTank Name=SimObject

        bClampedFrictionModel=true

        WheelSuspensionStiffness=40
        WheelSuspensionDamping=1.0
        WheelSuspensionBias=0.1

//        WheelLongExtremumSlip=0
//        WheelLongExtremumValue=20
//        WheelLatExtremumValue=4

        // Longitudinal tire model based on 10% slip ratio peak
        WheelLongExtremumSlip=0.5
        WheelLongExtremumValue=2.0
        WheelLongAsymptoteSlip=2.0
        WheelLongAsymptoteValue=0.6

        // Lateral tire model based on slip angle (radians)
           WheelLatExtremumSlip=0.5 //0.35     // 20 degrees
        WheelLatExtremumValue=4.0
        WheelLatAsymptoteSlip=1.4     // 80 degrees
        WheelLatAsymptoteValue=2.0

        ChassisTorqueScale=0.0
        StopThreshold=20
        EngineDamping=3.0
        InsideTrackTorqueFactor=0.42
        TurnInPlaceThrottle=0.175
        TurnMaxGripReduction=0.995 //0.980
        TurnGripScaleRate=0.8
        MaxEngineTorque=3000
    End Object
    SimObj=SimObject
    Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_StealthTank.Mesh.SK_VH_StealthTank'
        AnimTreeTemplate=AnimTree'RX_VH_StealthTank.Anims.AT_VH_StealthTank'
        PhysicsAsset=PhysicsAsset'RX_VH_StealthTank.Mesh.SK_VH_StealthTank_Physics'
    End Object

    DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_StealthTank.Mesh.SK_PTVH_StealthTank'

	VehicleIconTexture=Texture2D'RX_VH_StealthTank.UI.T_VehicleIcon_StealthTank'
	MinimapIconTexture=Texture2D'RX_VH_StealthTank.UI.T_MinimapIcon_StealthTank'


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


    Seats(0)={(GunClass=class'Rx_Vehicle_StealthTank_Weapon',
                GunSocket=(TurretFireSocket01,TurretFireSocket02),
                TurretControls=(TurretPitch,TurretRotate),
                GunPivotPoints=(MainTurretYaw,MainTurretPitch),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-10),
                CameraOffset=-400,
                SeatIconPos=(X=0.5,Y=0.33),
                MuzzleFlashLightClass=class'Rx_Light_Tank_MuzzleFlash'
                )}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    LeftTeadIndex     = 1
    RightTreadIndex   = 2

    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_StealthTank.Materials.PhysMat_StealthTankDriving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_StealthTank.Materials.PhysMat_StealthTank'

    RecoilTriggerTag = "MainGun"
    VehicleEffects(0)=(EffectStartTag="TurretFireRight",EffectTemplate=ParticleSystem'RX_VH_StealthTank.Effects.P_MuzzleFlash_Missiles',EffectSocket="TurretFireSocket01")
    VehicleEffects(1)=(EffectStartTag="TurretFireLeft",EffectTemplate=ParticleSystem'RX_VH_StealthTank.Effects.P_MuzzleFlash_Missiles',EffectSocket="TurretFireSocket02")
    VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke01)
    VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke02)

	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
    WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt_Small')
	WheelParticleEffects[2]=(MaterialType=Grass,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt_Small')
    WheelParticleEffects[3]=(MaterialType=Water,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Water')
    WheelParticleEffects[4]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Snow_Small')
	WheelParticleEffects[5]=(MaterialType=Concrete,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
	WheelParticleEffects[6]=(MaterialType=Metal,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
	WheelParticleEffects[7]=(MaterialType=Stone,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Stone')
	WheelParticleEffects[8]=(MaterialType=WhiteSand,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_WhiteSand_Small')
	WheelParticleEffects[9]=(MaterialType=YellowSand,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_YellowSand_Small')
	DefaultWheelPSCTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt_Small'
	
    BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Huge')
    BigExplosionSocket=VH_Death
	
	DamageMorphTargets(0)=(InfluenceBone=MT_StealthTank_F,MorphNodeName=MorphNodeW_Front,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_StealthTank_L,MorphNodeName=MorphNodeW_Left,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage2))
    DamageMorphTargets(2)=(InfluenceBone=MT_StealthTank_R,MorphNodeName=MorphNodeW_Right,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage3))
    DamageMorphTargets(3)=(InfluenceBone=MT_StealthTank_B,MorphNodeName=MorphNodeW_Rear,LinkedMorphNodeName=none,Health=40,DamagePropNames=(Damage4))

    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.1)

//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\


    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_StealthTank.Sounds.SC_StealthTank_Idle'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);

    EnterVehicleSound=SoundCue'RX_VH_StealthTank.Sounds.SC_StealthTank_Start'
    ExitVehicleSound=SoundCue'RX_VH_StealthTank.Sounds.SC_StealthTank_Stop'
	
	Begin Object Name=ScorpionTireSound
		SoundCue=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireDirt'
	End Object
	TireAudioComp=ScorpionTireSound
	Components.Add(ScorpionTireSound);
	
	TireSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireDirt')
	TireSoundList(1)=(MaterialType=Foliage,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireFoliage')
	TireSoundList(2)=(MaterialType=Grass,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireGrass')
	TireSoundList(3)=(MaterialType=Metal,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireMetal')
	TireSoundList(4)=(MaterialType=Mud,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireMud')
	TireSoundList(5)=(MaterialType=Snow,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireSnow')
	TireSoundList(6)=(MaterialType=Stone,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireStone')
	TireSoundList(7)=(MaterialType=Water,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireWater')
	TireSoundList(8)=(MaterialType=Wood,Sound=SoundCue'RX_SoundEffects.Vehicle.SC_VehicleSurface_TireWood')


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\



    Begin Object Class=Rx_Vehicle_StealthTank_Wheel Name=FRMWheel
        BoneName="Wheel_FRM"
        SkelControlName="Wheel_FRM_Cont"
        Side=SIDE_Right
    End Object
    Wheels(0)=FRMWheel

    Begin Object class=Rx_Vehicle_StealthTank_Wheel Name=FRBWheel
        BoneName="Wheel_FRB"
        SkelControlName="Wheel_FRB_Cont"
        Side=SIDE_Right
    End Object
    Wheels(1)=FRBWheel

    Begin Object class=Rx_Vehicle_StealthTank_Wheel Name=FLMWheel
        BoneName="Wheel_FLM"
        SkelControlName="Wheel_FLM_Cont"
        Side=SIDE_Left
    End Object
    Wheels(2)=FLMWheel

    Begin Object class=Rx_Vehicle_StealthTank_Wheel Name=FLBWheel
        BoneName="Wheel_FLB"
        SkelControlName="Wheel_FLB_Cont"
        Side=SIDE_Left
    End Object
    Wheels(3)=FLBWheel

    Begin Object class=Rx_Vehicle_StealthTank_Wheel Name=RRMWheel
         BoneName="Wheel_RRM"
        SkelControlName="Wheel_RRM_Cont"
        Side=SIDE_Right
    End Object
    Wheels(4)=RRMWheel

    Begin Object class=Rx_Vehicle_StealthTank_Wheel Name=RRBWheel
        BoneName="Wheel_RRB"
        SkelControlName="Wheel_RRB_Cont"
        Side=SIDE_Right
    End Object
    Wheels(5)=RRBWheel

    Begin Object class=Rx_Vehicle_StealthTank_Wheel Name=RLMWheel
          BoneName="Wheel_RLM"
        SkelControlName="Wheel_RLM_Cont"
        Side=SIDE_Left
    End Object
    Wheels(6)=RLMWheel

    Begin Object class=Rx_Vehicle_StealthTank_Wheel Name=RLBWheel
        BoneName="Wheel_RLB"
        SkelControlName="Wheel_RLB_Cont"
        Side=SIDE_Left
    End Object
    Wheels(7)=RLBWheel

}
