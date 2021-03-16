class Rx_Pawn_SBH extends Rx_Pawn
	implements (RxIfc_EMPable)
	implements (RxIfc_Stealth);

var float  										IdleTimeToStealth; // needed time to stay in idle to vanish
var private MaterialInterface  					MatStealthed;
var private MaterialInstanceConstant		  	MICStealthed;        // MIC for Stealthed status
var private MaterialInstanceConstant 			MICNormal;           // MIC for noramal use
var private array<MaterialInstanceConstant> 	WeaponsNormalMICs;
var private array<MaterialInstanceConstant>  	MICStealthedWeapon;
var private array<MaterialInstanceConstant>    	Materials; // last id for stealth mats
var private repnotify name                      CurrentState;
var private SkeletalMeshComponent               StealthOverlayMesh;
var private SkeletalMeshComponent            	CurrentWeaponAttachmentOverlay;
var private PlayerController                 	LocalPC;
var private float								AnimSteps;
var private float								AnimPlayTime;
var private float								LowHPMult;
var private float                               TimeLastAction; 
var private float                    			TimeStealthDelay;    // seconds we need to stay without action to get stealthed
var private bool                     			bStealthMatInitialized;
var private float                    			PawnDetectionModifier; 
var private float                   			VehicleDetectionModifier;
var private float                    			CurrentMaxNoticeDistance;
var private bool							    bInvisible;		
var public bool								    bStealthRecoveringFromBeeingShotOrSprinting;
var private float 								StealthVisibilityDistance;	// Distance at wich enemys start to see an SBH	
var private float 								SprintingStealthVisibilityDistance;	// Distance at wich enemys start to see an SBH	
var private float 								BeenshotStealthVisibilityModifier;		
var private float 								MaxStealthVisibility;		// Max decloakvalue for when enemys get close to an SBH
var private int 								LastHealthBeenShot;
var int                                         EMPFieldCount;
var float										Vet_StealthDelayMod[4]; 
var MaterialInstanceConstant					CurrentStoredOverlay; //We switch a lot of materials as an SBH.. remember our modifier overlay till we don't need it

replication
{
   if (bNetDirty && (Role==ROLE_Authority))
      CurrentState;
}

simulated function PostBeginPlay()
{  
	super.PostBeginPlay();
	if(WorldInfo.NetMode != NM_DedicatedServer)
		SetTimer(5.0,true,'CheckForLocalPCSpecificCloak');	
}

simulated event ReplicatedEvent(name VarName)
{
   if (VarName == 'CurrentState')
	  ClientAdjustState();
   else
      Super.ReplicatedEvent(VarName);
}

simulated function bool IsEffectedByEMP()
{
	return true;
}

function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor, optional int TimeModifier = 0)
{
	if (InstigatedByController.GetTeamNum() == GetTeamNum() )
		return false;

	EMPd();	
	return true;
}

function EMPd()
{
	if (!IsInState('LowHP'))
		ChangeState('WaitForSt');
}

function EnteredEMPField(Rx_EMPField EMPCausingActor)
{
	if (EMPFieldCount++ == 0)
		EMPd();
}

function LeftEMPField(Rx_EMPField EMPCausingActor)
{
	--EMPFieldCount;
}

/** This function is only needed to init the proper stealth for when a player changed teams or connected mid game. */
simulated function CheckForLocalPCSpecificCloak()
{
	if(LocalPC == None)
        foreach LocalPlayerControllers(class'PlayerController', LocalPC) {
           break;
        }
    if(LocalPC == None)
    {
    	UpdateNewStealthVisibilityParam(0.0f);    
    	return;
	}
	
    if (LocalPC.GetTeamNum() != self.GetTeamNum() && IsInState('Stealthed') && !IsTimerActive('UpdateStealthBasedOnDistanceTimer'))
      	SetTimer(0.1, true, 'UpdateStealthBasedOnDistanceTimer');
    else if (LocalPC.GetTeamNum() == self.GetTeamNum() && IsTimerActive('UpdateStealthBasedOnDistanceTimer'))
    {
    	ClearTimer('UpdateStealthBasedOnDistanceTimer');  
    	UpdateNewStealthVisibilityParam(1.0f);	
	}
}

auto simulated state JustSpawned
{
    simulated function BeginState(name PreviousStateName)
    {
   	    MICNormal 	 = MaterialInstanceConstant(Mesh.GetMaterial(0));
   	    MICStealthed = new(outer) class'MaterialInstanceConstant';
  		MICStealthed.SetParent(MatStealthed);
  		UpdateStealthAnimParam(0.0f);	 
		
  		SetTimer(2.0, false, 'GotoStealthed');
    }

	simulated function GotoStealthed() { 
		ChangeState('PlayStealthAnim');	     
	} 
}

simulated function ClientAdjustState() { 
   GotoState(CurrentState);
}

function ChangeState (name newState) {
   CurrentState = NewState;
   if(NewState != 'Stealthed') 
   {
	   SetOverlayMaterial(CurrentStoredOverlay);
	   if(CurrentStoredWeaponOverlayByte != 255) SetWeaponOverlayFlag(CurrentStoredWeaponOverlayByte);
	   
   }
   else 
   {
	  if(GetOverlayMaterial() != none) SetOverlayMaterial(none);
	   if(CurrentStoredWeaponOverlayByte != 255) ClearWeaponOverlayFlag(CurrentStoredWeaponOverlayByte);
   }
   GotoState(newState);
}

/* =============
 * state WaitForSt - all the time checks are performed here
 * and the main decision point for getting stealthed
 */
simulated state WaitForSt // also called driving
{

   simulated function BeginState(name PreviousStateName)
   {
      if(bInvisible) {
      	 SetInvisible(false);
      }
      TimeLastAction = WorldInfo.TimeSeconds;
      SetTimer(0.5f, true, 'StWait');
   }

   simulated function StWait () {
   	  if( (Rx_Weapon_Beacon(weapon) != None && weapon.IsInState('Charging')) || EMPFieldCount > 0 )
   	  {
   	  	 TimeLastAction = WorldInfo.TimeSeconds;
   	  	 return;
   	  }
      if (WorldInfo.TimeSeconds - TimeLastAction >= (TimeStealthDelay-Vet_StealthDelayMod[VRank] ) ) {
 	  	  ChangeState('PlayStealthAnim');
      }
   }

   simulated function TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
   {
      Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
      if (Health <= HealthMax*LowHpMult) {
         ChangeState('LowHP');
      }
   }

   simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
   {
      //ChangeState('WaitForSt');
      TimeLastAction = WorldInfo.TimeSeconds;
      SetTimer(0.5f, true, 'StWait');
      super.WeaponFired(InWeapon, bViaReplication, HitLocation);
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
      ClearTimer('DeCloak');
      FirstVanish(PreviousStateName);
   }

   simulated function FirstVanish(name PreviousStateName) {

      // TODO: what about the mesh overlay?!

      if (WorldInfo.NetMode != NM_DedicatedServer)
      {
      	setMaterialsCloaked(true);
      }
      if(PreviousStateName != 'BeenShot')
      	UpdateStealthAnimParam(0.0f);
      else 
      {
     	UpdateStealthAnimParam(0.5f);	
        bStealthRecoveringFromBeeingShotOrSprinting = true;
      }
      ChangeVisibilityToCloaked();
      bStealthMatInitialized = true;
      if (WorldInfo.NetMode != NM_DedicatedServer)
      {
      	Settimer (0.025f, true, 'PlayVanish');
      }
      if(!bStealthRecoveringFromBeeingShotOrSprinting) 
      	Settimer (2.0f, false, 'SwitchToStealthedState');
      else
      	Settimer (1.0f, false, 'SwitchToStealthedState');	     
      
   }
   
   simulated function SwitchToStealthedState() {
	    ChangeState('Stealthed');
   }

   simulated function PlayVanish() {
      local float F;
      MICStealthed.GetScalarParameterValue ('Stealth_Animation', F);
      if (F < 1.0f) {
      	 if(!bStealthRecoveringFromBeeingShotOrSprinting)
         	F += 0.025f;
         else
         	F += 0.0125f;	
         
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

   simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
   {
      ChangeState('WaitForSt');
      super.WeaponFired(InWeapon, bViaReplication, HitLocation);
   }

   simulated function EndState(Name NextStateName)
   {
      ClearTimer('PlayVanish');
      ClearTimer('SwitchToStealthedState');
      bStealthRecoveringFromBeeingShotOrSprinting = false;
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
        SetMaterialsCloaked(false);
		
        UpdateStealthVisibilityParam(0.0f);
        UpdateNewStealthVisibilityParam(1.0f);
		ClearTimer('DeCloak');	
		ClearTimer('SwitchToStealthedState');	
		ClearTimer('UpdateStealthBasedOnDistanceTimer');
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
		  SetMaterialsCloaked(true);              
      }
   }

   /*
    * start up state
    */
   simulated function BeginState(name PreviousStateName)
   {  
      SetInvisible(true);
      // for other playser that recently joined but SBH was stealthed
      if(!bStealthMatInitialized || SpawnTime <= 1.0f) {
		SetMaterialsCloaked(true);             
    	UpdateStealthAnimParam(1.0f);
    	UpdateStealthVisibilityParam(0.001f);
      	setTimer(2.0f, false, 'ChangeVisibilityToCloaked');
      }
      
      if (WorldInfo.NetMode != NM_DedicatedServer && LocalPC.GetTeamNum() != self.GetTeamNum())
      	SetTimer(0.1, true, 'UpdateStealthBasedOnDistanceTimer');
      
	  if(ROLE==ROLE_Authority) Rx_PRI(PlayerReplicationInfo).SetTargetEliminated(100); //Restealthed. Remove target status
      
   }

   simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
   {
      ChangeState('WaitForSt');
      super.WeaponFired(InWeapon, bViaReplication, HitLocation);
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
      SetInvisible(false);
      // need same mat in BeenShot
      if (NextStateName != 'BeenShot')
      {
         SetTimer(0.025, true, 'DeCloak');
      }   
   }
}

simulated function UpdateStealthBasedOnDistanceTimer()
{	
	local float StealthValue;
	
	if(!IsInState('Stealthed') && !IsInState('BeenShot'))
		return;
		
	if(LocalPC.Pawn == None)
	{
		if(LocalPC.GetTeamNum() != GetTeamNum()) {
			StealthValue = 0.0; 
		}
		else{
			StealthValue = 1.0; 
		}
			
	return;		
	}
		
	if(IsInState('BeenShot') && (Health+Armor != LastHealthBeenShot))
	{
		SetTimer(0.6, false, 'ChangeToPlayStealthAnimState');
		BeenshotStealthVisibilityModifier = default.BeenshotStealthVisibilityModifier;	
		LastHealthBeenShot = Health+Armor;
	}
		
	
	StealthValue = VSize(LocalPC.Pawn.location - location);
	//loginternal(StealthValue);
	
	// 1 = completely visible	
	
	if(bSprintingServer)
	{
		if(Rx_Pawn(LocalPC.Pawn) != none)
			StealthValue = 1.2 - StealthValue/(SprintingStealthVisibilityDistance*PawnDetectionModifier);
		else
			StealthValue = 1.2 - StealthValue/(SprintingStealthVisibilityDistance*VehicleDetectionModifier);
	}	
	else 
	{
		if(Rx_Pawn(LocalPC.Pawn) != none)
			StealthValue = 1.2 - StealthValue/(StealthVisibilityDistance*PawnDetectionModifier);
		else
			StealthValue = 1.2 - StealthValue/(StealthVisibilityDistance*VehicleDetectionModifier);
	}
	
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
  		UpdateStealthAnimParam(0.0f);
   }

   function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
   {
	  if (Health + Amount > HealthMax*LowHpMult)
		 ChangeState('WaitForSt');

      return Super.HealDamage(Amount, Healer, DamageType);
   }

	// Already perma visible, don't change state.
	function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor, optional int TimeModifier = 0)
	{
		return true;
	}
	
	function regenerateHealthTimer()
	{
		super.regenerateHealthTimer();
		if(Health >= HealthMax*LowHPMult) 
			GotoState('WaitForSt') ;
	}
	
	function regenerateHealth(int HealAmount)
	{
		super.regenerateHealth(HealAmount);
		if(Health >= HealthMax*LowHPMult) 
			GotoState('WaitForSt') ;
	}
}

/* =============
 * state BeenShot - SBH been shot and is visible to the enemy
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
      LastHealthBeenShot = Health+Armor;
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
 	 SetInvisible(true);
  	 ChangeState('Stealthed');   	  	 	  	
   }

   simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
   {
      ChangeState('WaitForSt');
      super.WeaponFired(InWeapon, bViaReplication, HitLocation);
   }


   simulated function EndState(Name NextStateName)
   {
      if (NextStateName != 'Stealthed' && NextStateName != 'PlayStealthAnim') {
		  SetMaterialsCloaked(false);
		  SetInvisible(false);      
      }
      BeenshotStealthVisibilityModifier = 0.0;
      ClearTimer('ChangeToPlayStealthAnimState');
   }
}

simulated function UpdateStealthAnimParam(float value) {
	MICStealthed.SetScalarParameterValue('Stealth_Animation', value);	
}

simulated function UpdateStealthVisibilityParam(float value) {
	//MICStealthed.SetScalarParameterValue('PixelDepth', value);	
}

/** A value of 0 being not visible, and a value of 1 being completely visible. */
simulated function UpdateNewStealthVisibilityParam(float value) {
	//loginternal(value);
	MICStealthed.SetScalarParameterValue('Stealth_Visibility', value);	
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

simulated function SetMaterialsCloaked(bool cloaked) 
{
  local int i, j, count;
  
  if (cloaked) 
  {
        // Set character to stealth and initalize a MIC
        Mesh.SetMaterial(0, MICStealthed);
        Mesh.CreateAndSetMaterialInstanceConstant(0);
    
        // Set equipped weapon to stealth and intialize MIC
        if ((Weapon != None && Weapon.Mesh != none) && (Weapon.default.Mesh.Materials.Length > 0 || Weapon.Mesh.GetNumElements() > 0))
        {
            if(Rx_Weapon_LaserRifle(Weapon) != none)
            {
               Weapon.Mesh.SetMaterial(0, MICStealthed);
               Weapon.Mesh.CreateAndSetMaterialInstanceConstant(0);
            } else {
               count = Weapon.default.Mesh.Materials.Length > 0 ?  Weapon.default.Mesh.Materials.Length : Weapon.Mesh.GetNumElements();
               for (i = 0; i < count; i++) 
               {
                  Weapon.Mesh.SetMaterial(i, MICStealthed);
                  Weapon.Mesh.CreateAndSetMaterialInstanceConstant(i);  
               }     
            }
        }   
    
        // Set 1st person arms to stealth and intialize MIC
        for (i = 0; i < 2; i++) 
        {
            if(ArmsMesh[i] != None) 
            {
                ArmsMesh[i].SetMaterial(0, MICStealthed); 
                ArmsMesh[i].CreateAndSetMaterialInstanceConstant(0);    
            }
        }
        
        BodyMaterialInstances[0] = MaterialInstanceConstant(Mesh.GetMaterial(0));
        Mesh.SetMaterial(0, BodyMaterialInstances[0]);  
        
        // Set 3rd person equipped weapon to stealth and intialize MIC
        if (CurrentWeaponAttachment != None) 
            for (i = 0; i < CurrentWeaponAttachment.Mesh.SkeletalMesh.Materials.length; i++) 
            {
                CurrentWeaponAttachment.Mesh.SetMaterial(i, MICStealthed);
                CurrentWeaponAttachment.Mesh.CreateAndSetMaterialInstanceConstant(i);
            }
        
        // Set non-equipped equipped weapon to stealth and intialize MIC
        for (j = 0; j < ArrayCount(CurrentBackWeapons); j++)
        {
            if (CurrentBackWeaponComponents[j] != None)
                for (i = 0; i < CurrentBackWeaponComponents[j].SkeletalMesh.Materials.length; i++) 
                {
                    CurrentBackWeaponComponents[j].SetMaterial(i, MICStealthed);
                    CurrentBackWeaponComponents[j].CreateAndSetMaterialInstanceConstant(i);
                }
        }   
  } 
    else 
    {
        Mesh.SetMaterial(0, MICNormal);
        Mesh.CreateAndSetMaterialInstanceConstant(0);

        if (Weapon != None && Weapon.Mesh != none) 
        {
            for (i = 0; i < Weapon.default.Mesh.Materials.Length; i++) 
            {
                Weapon.Mesh.SetMaterial(i, Weapon.default.Mesh.GetMaterial(i));
                Weapon.Mesh.CreateAndSetMaterialInstanceConstant(i);  
            }

            if (Weapon.default.Mesh.Materials.Length == 0)
                for (i = 0; i < Weapon.Mesh.GetNumElements(); i++) 
                {
                    Weapon.Mesh.SetMaterial(i, MICNormal);
                    Weapon.Mesh.CreateAndSetMaterialInstanceConstant(i);
                }

            Rx_Weapon(Weapon).SetSkin(None);
        } 
        
        for (i = 0; i < 2; i++) 
        {
            if (ArmsMesh[i] != None) 
            {
                ArmsMesh[i].SetMaterial(0, MICNormal); 
                ArmsMesh[i].CreateAndSetMaterialInstanceConstant(0);    
            }
        } 
        
        BodyMaterialInstances[0] = MaterialInstanceConstant(Mesh.GetMaterial(0));
        Mesh.SetMaterial(0, BodyMaterialInstances[0]);    
        
        if (CurrentWeaponAttachment != None)
            for (i = 0; i < CurrentWeaponAttachment.default.Mesh.Materials.length; i++) 
            {
                CurrentWeaponAttachment.Mesh.SetMaterial(i, CurrentWeaponAttachment.Mesh.default.Materials[i]);
                CurrentWeaponAttachment.Mesh.CreateAndSetMaterialInstanceConstant(i);
            }

        for (j = 0; j < ArrayCount(CurrentBackWeapons); j++) 
        {
            if (CurrentBackWeaponComponents[j] != None) {
                for (i = 0; i < CurrentBackWeaponComponents[j].default.SkeletalMesh.Materials.length; i++)
                { 
                   // Some weapons such as the nod autorifile, get the GDI material if we use the skeletal mesh
                   // If the material exists, use it otherwise fall back to the skeletal mesh.
                   if (i < CurrentBackWeaponComponents[j].default.Materials.length) {
                     CurrentBackWeaponComponents[j].SetMaterial(i, CurrentBackWeaponComponents[j].default.Materials[i]);
                   } else {
                      CurrentBackWeaponComponents[j].SetMaterial(i, CurrentBackWeaponComponents[j].default.SkeletalMesh.Materials[i]);
                   }
                   CurrentBackWeaponComponents[j].CreateAndSetMaterialInstanceConstant(i);
                }
            }
        } 
    }
}

simulated function WeaponAttachmentChanged()
{
	super.WeaponAttachmentChanged();
	if (IsInState('PlayStealthAnim') || IsInState('Stealthed') || IsInState('BeenShot'))
	{
		SetMaterialsCloaked(true);		
	}
}

simulated function SetInvisible(bool bNowInvisible)
{
	super.SetInvisible(bNowInvisible);
	bIsInvisible = false;
	bInvisible = bNowInvisible;
}

function bool IsInvisible() {
	return bInvisible;
}

simulated function RefreshBackWeaponComponents()
{
	super.RefreshBackWeaponComponents();
	if (IsInState('PlayStealthAnim') || IsInState('Stealthed') || IsInState('BeenShot'))
	{
		SetMaterialsCloaked(true);		
	}
	else 	
		SetMaterialsCloaked(false);
}


function bool GiveHealth(int HealAmount, int HealMax)
{
	if(Health+HealAmount >= HealthMax*LowHPMult) GotoState('WaitForSt') ;
	
	return super.GiveHealth(HealAmount, HealMax);
}

function PerformRefill() {
   Super.PerformRefill();
   ChangeState('WaitForSt');
}


/** todo: when sprinting decrease stealtheffect a bit
function StopSprinting()
{
	if (bSprinting)
	{
		 super.StopSprinting();
		 if(bInvisible)
 		 	ChangeState('PlayStealthAnim');	 
	}
}

function StartSprint()
{
	if (!bSprinting)
	{
	 	super.StartSprint();
	 	if(bInvisible)
	 	{
 			ChangeState('Stealthed');
 			UpdateStealthAnimParam(0.7f);
 		}
	}
}
*/


simulated function SetOverlay(class<Rx_StatModifierInfo> StatClass, bool bAffectWeapons)//SetOverlay(LinearColor MatColour, float MatOpacity, float MatInflation, bool bAffectWeapons)
{
	ClearOverlay(); 
	
	CurrentStoredOverlay = StatClass.default.PawnMIC;
	if(bAffectWeapons) CurrentStoredWeaponOverlayByte = StatClass.default.EffectPriority;
	
	if(IsInState('Stealthed')) //Just store stuff and cut out
	{
		return; 
	}
	
	SetOverlayMaterial(StatClass.default.PawnMIC); 
	
	if(bAffectWeapons) 
	{
		//CurrentStoredWeaponOverlayByte = StatClass.default.EffectPriority;
	
		if(Rx_GRI(WorldInfo.GRI).WeaponOverlays.Length == 0 && WorldInfo.NetMode != NM_DedicatedServer) Rx_GRI(WorldInfo.GRI).SetupWeaponOverlays(); //Tell GRI to setup weapon overlays if it hasn't already 
		
		SetWeaponOverlayFlag(StatClass.default.EffectPriority);
	}
	
	
}

simulated function ClearOverlay()
{
	CurrentStoredOverlay = none;
	if(CurrentStoredWeaponOverlayByte != 255) 
	{
		ClearWeaponOverlayFlag(CurrentStoredWeaponOverlayByte);
		CurrentStoredWeaponOverlayByte = 255; 
	}
	if(!IsInState('Stealthed')) SetOverlayMaterial(none);
	
}

/*Functions shared by all stealth units for the HUD (And maybe for a sensor array or something)*/

simulated function bool GetIsinTargetableState(){
	return (((GetStateName() != 'Stealthed' && GetStateName() != 'BeenShot') || bStealthRecoveringFromBeeingShotOrSprinting) && Health > 0); 
}

simulated function bool GetIsStealthCapable()
{
	return Health > HealthMax*LowHPMult;
}
	
simulated function ChangeStealthVisibilityParam(bool ForOnFoot, optional float PercentMod = 1.0) {
	if(ForOnFoot) {
		CurrentMaxNoticeDistance = PawnDetectionModifier*PercentMod; 	
	} else {
		CurrentMaxNoticeDistance = VehicleDetectionModifier*PercentMod;
	}
} 

/*End Stealth Interface Functions*/

/*RxIfc_Targetable*/
simulated function bool GetIsValidLocalTarget(Controller PC) {return PC.GetTeamNum() == GetTeamNum() || GetIsinTargetableState();} //Are we a valid target for our local playercontroller?  (Buildings are always valid to look at (maybe stealthed buildings aren't?))


Defaultproperties 
{

    Begin Object Class=SkeletalMeshComponent Name=OverlayMeshComponent1 ObjName=OverlayMeshComponent1
       bUpdateSkelWhenNotRendered=False
       bOverrideAttachmentOwnerVisibility=True
       bOwnerNoSee=False
       bUseAsOccluder=False
       CastShadow=False
       Scale=1.00010f // change scale if needed
       TickGroup=TG_PostAsyncWork
    End Object
    StealthOverlayMesh=OverlayMeshComponent1	
	
	//Lower numbers make you spotted shimmer from further away. 
	MatStealthed 	  	 = MaterialInterface'RX_CH_Nod_SBH.Material.MI_SBH_Cloak_Enemy'
	PawnDetectionModifier  = 1.10//0.0015f   // remember to test this! and anjust similar to CCR
	VehicleDetectionModifier = 1.0 //0.001f    // and this	
	
	BeenshotStealthVisibilityModifier = 1.0
	StealthVisibilityDistance = 400
	SprintingStealthVisibilityDistance = 600
	MaxStealthVisibility = 0.2
	
	AnimSteps            = 40.0f;
	AnimPlayTime         = 1.5f;
	LowHPMult            = 0.50f //0.15f;	
   	TimeStealthDelay 	 = 5.0f    //  seconds we need to stay without action to get stealthed
	
	//-X
	Vet_StealthDelayMod(0) = 0; 
	Vet_StealthDelayMod(1) = 1; 
	Vet_StealthDelayMod(2) = 2; 
	Vet_StealthDelayMod(3) = 3; 

}

