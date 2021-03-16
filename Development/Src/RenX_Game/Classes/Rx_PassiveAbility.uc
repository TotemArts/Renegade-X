class Rx_PassiveAbility extends Actor
abstract; //Abilities that attach themselves invisibly to various pawns. 

//Interaction variables
var repnotify Pawn UsingPawn; 

var float MaxCharges; //Actual charges left to expend before needing to recharg
var float CurrentCharges; //Actual charges left to expend before needing to recharge

/*Timing*/
var bool  bSingleCharge; //Only has one shot before reloading. Use true to differentiate this on the HUD and let it know to use the Recharge delay to describe how long it has left to recharge
var float RechargeRate; //Recharge rate of this ability  
var float RechargeDelay; //Time between being fired and when it begins recharging
var float ConsumptionRate; 

var bool bAlwaysRecharge ; //This Ability is always recharging when not full after a delay. 

var bool bCurrentlyRecharging; //Is it currently recharging
var bool bFireWhileRecharging; //Can it fire while it's recharging

var bool bCurrentlyActive; 
var bool bRespondingToCrouch; 

/** The GFX ability set, 0-15. */
var byte AbilityMovieGroup;

//Sounds 

var SoundCue SC_AbilityActivate;
var SoundCue SC_AbilityDeactivate; 
var AudioComponent AbilityAudioComponent;  

//Slot number used by this weapon. Replicated to client so that they can interact client-side and not have to rely on serverwith laggy weapon switches  

var int	FlashMovieIconNumber; 

//Veterancy
var byte VRank; 
var float Vet_RechargeSpeedMult[4];

var repnotify byte  AssignedSlot; //ID replicated to owner so they can find this ability client side 

var class<Rx_PassiveAbilityAttachment> AttachmentClass; 
var Rx_PassiveAbilityAttachment	Attachment; 

var repnotify bool bDestroyed; //Replicates when destroyed on server 

var bool bDeactivateOnRelease; //Released the 'activate' key calls DeactivateAbility (Useful for abilities that perform their action on deactivation )

var bool bInitialized;

replication {
	if(bNetDirty && bNetOwner)
		bDestroyed, UsingPawn, AssignedSlot, bInitialized;
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'AssignedSlot')
	{
		if(AssignedSlot != 255 && RxIfc_PassiveAbility(Owner) != none){
			RxIfc_PassiveAbility(Owner).ReplicatePassiveAbility(AssignedSlot, self);
			
		}	
	}
	else
	if(VarName == 'bDestroyed')
	{
		if(bDestroyed)
		{
			RxIfc_PassiveAbility(Owner).RemovePassive(AssignedSlot, self);
			RemoveUser();
		}
		
	}
	else
		super.ReplicatedEvent(VarName); 
}

simulated event PostBeginPlay()
{
	if(ROLE < ROLE_Authority)
		super.PostBeginPlay();
}

simulated function bool bReadyToFire()
{
	return  !bCurrentlyRecharging || (bFireWhileRecharging && HasCharge()); 
}

simulated function bool HasCharge()
{
	return (bFireWhileRecharging && CurrentCharges >= 1) || (!bFireWhileRecharging && !bCurrentlyRecharging); 
}

simulated function PerformRefill()
{} 

simulated function SetRechargeTimer()
{
	if(!IsTimerActive('RechargeTimer')) 
		SetTimer(RechargeRate*Vet_RechargeSpeedMult[VRank],true,'RechargeTimer');
	else
		return;
}

simulated function RechargeTimer()
{
	if(UsingPawn == none)
		return; 
	
	if(CurrentCharges < MaxCharges) 
		AddCharge(1);
	
	if(CurrentCharges >= MaxCharges && IsTimerActive('RechargeTimer')) 
	{
		ClearTimer('RechargeTimer');	
		bCurrentlyRecharging = false; 
		if(WorldInfo.NetMode != NM_DedicatedServer) 
			Rx_Controller(UsingPawn.Controller).ClientPlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundPurchase') ; //SoundCue'Rx_Pickups.Sounds.SC_Pickup_Keycard' ; 
	}
}

simulated function AddCharge(int Num = 1)
{
	CurrentCharges = min(MaxCharges, CurrentCharges+abs(Num)) ; 
}

simulated function SubtractCharge()
{
	CurrentCharges = max(0, CurrentCharges-GetConsumptionRate()) ; 
}

simulated function bool bCanBeSelected()
	{
		return  !bCurrentlyRecharging || (bFireWhileRecharging && HasCharge())  ; 	
	}

//Show me on the HUD? 
simulated function bool bShouldBeVisible()
{
	return true; 
}

simulated function float GetRechargeTiming()
{
	local float RemainingSingleChargeTime; 
	
	RemainingSingleChargeTime = (Vet_RechargeSpeedMult[VRank]*(RechargeRate+RechargeDelay)-(GetTimerRate('RechargeTimer') - GetTimerCount('RechargeTimer')) ) ; 
	
	if(bSingleCharge) 
		return RemainingSingleChargeTime/((RechargeRate+RechargeDelay)*Vet_RechargeSpeedMult[VRank]) ;  
	else
		return (CurrentCharges/MaxCharges);
}

simulated function int GetFlashIconInt()
{
	return FlashMovieIconNumber;
}

//Initialize and return an ID to replicate
simulated function Init(Pawn InitiatingPawn, byte SlotNum)
{
	if(ROLE == ROLE_Authority && !bInitialized)
	{
		SetUsingPawn(InitiatingPawn);
		//`log("Initialize Passive Ability" @ self @ "with Pawn " @ UsingPawn);
		AssignedSlot = SlotNum; 
		
		//Create replication attachment for all non-owning clients
		Attachment = Spawn(AttachmentClass, InitiatingPawn);
		Attachment.InitAttachment(InitiatingPawn);
		Instigator = InitiatingPawn;
		bInitialized = true; 
	}
} 

//If we're waiting on replication still, use this timer
simulated function TryInitTimer()
{
	if(AssignedSlot != 255 && UsingPawn != none)
	{
		Init(UsingPawn, AssignedSlot);
	}
	else
		SetTimer(0.2, false, 'TryInitTimer');
}

simulated function RemoveUser()
{
	//`log("User Removed" @ self); 
	//ScriptTrace();
	if(ROLE == ROLE_Authority)
		bDestroyed = true; 
	
	SetUsingPawn(none);
	
	//Get rid of our Attachment. Our old Pawn will dispose of it on its own. 
	Attachment = none; 

	ClearTimer('RechargeTimer'); 
	
	SetTimer(0.25,false,'ToDestroy');
	
}

reliable client function ClientRemoveUser()
{
	RemoveUser(); 
}

simulated function ToDestroy()
{
   Destroy();
}

simulated function ActivateAbility()
{
	//`log("Activate"); 
} 

reliable server function ServerActivateAbility(){
	//`log("Server Activate"); 
}

simulated function DeactivateAbility(bool bForce)
{
	//`log("Deactivate"); 
}

reliable server function ServerDeactivateAbility(bool bForce){
	//`log("Server DeactivateAbility"); 
}

simulated function NotifyLanded(); //Called when our pawn lands 

//Called if our Pawn pulls a dodge move. Return true if it should override its usual dodge behaviour. 
simulated function bool NotifyDodged(int DodgeDir){
	return false; 
}

//Called when crouch is pressed/released
simulated function NotifyCrouched(bool Toggle); 

simulated function NotifySprint(bool Toggle); //Called when our pawn starts/stops sprinting 

simulated function RenderOverlay(HUD H);

simulated function float GetConsumptionRate(){
	return 1; 
}

simulated function bool GetRespondingToCrouch(); //Returns if this ability is currently responding to crouch being pressed 

simulated function NotifyMeshChanged(); //Called after our Pawn mesh is changed (Useful if this ability needs socket locations specific to meshes)

simulated function NotifyOverlayChanged(MaterialInterface NewMIC); 

simulated function NotifyMaterialsChanged();

simulated function NotifyTookDamage();

simulated function NotifyBumpedActor(Actor Other, Vector Vel, Vector HitNormal);

/*Infantry specific notifications*/
simulated function NotifyWeaponAttachmentsChanged();

simulated function NotifyBackWeaponAttachmentsChanged();

simulated function NotifyDriveVehicle(bool bDriving);

simulated function NotifyOwnerDied(){
	RemoveUser();
}

function NotifyServerMove(float DeltaTime);

simulated function NotifyPlayerMoving(name ControllerState, Controller C, vector NewAccelVector, float DeltaTime);

simulated function NotifyWeaponFired(byte FireModeNum); 

simulated function NotifyPhysicsVolumeChange(PhysicsVolume NewVolume);

/*----------------*/
simulated function ToggleAbility()
{
	if(bCurrentlyActive)
		DeactivateAbility(false);
	else
		ActivateAbility();
}

/*Timer that's called about a second and a half after the ability is spawned to basically check that EVERYTHING was setup correctly*/
simulated function UltimateFallBackTimer();

simulated function SetUsingPawn(Pawn OurPawn)
{
	//`log(self @ "Set Pawn to:" @ OurPawn);
	UsingPawn = OurPawn;
}

DefaultProperties
{
	RemoteRole=ROLE_SimulatedProxy
	bSingleCharge = true
	ConsumptionRate = 0.5
	bOnlyRelevantToOwner=TRUE
	
	AssignedSlot=255 //255 by default, so even switching to 0 is replicated without the need for math (Do not change)	
	
	Vet_RechargeSpeedMult(0) = 1.0 
	Vet_RechargeSpeedMult(1) = 1.0
	Vet_RechargeSpeedMult(2) = 1.0 
	Vet_RechargeSpeedMult(3) = 1.0 	
	
	FlashMovieIconNumber = 0 
	
	Begin Object Class=Rx_AudioComponent Name=AbilityAudio
		bUseOwnerLocation = true
		bStopWhenOwnerDestroyed = true
		SoundCue = none
	End Object
	AbilityAudioComponent=AbilityAudio
	Components.Add(AbilityAudio);

	
}