class Rx_PassiveAbility extends Actor; //Abilities that attach themselves invisibly to various pawns. 

//Interaction variables
var Pawn UsingPawn; 

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
var repnotify byte AssignedSlot;

var int	FlashMovieIconNumber; 

//Veterancy
var byte VRank; 
var float Vet_RechargeSpeedMult[4];

/**
simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'AssignedSlot')
	{
		//Add yourself if you don't exist already 
		if(Rx_InventoryManager(Instigator.InvManager).AbilityWeapons.find(self) == -1 )
			Rx_InventoryManager(Instigator.InvManager).AbilityWeapons.InsertItem(AssignedSlot, self);
	}

    else 
    {
    	super.ReplicatedEvent(VarName);
    } 
}*/

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
	if(CurrentCharges < MaxCharges) 
		AddCharge(1);
	
	if(CurrentCharges >= MaxCharges && IsTimerActive('RechargeTimer')) 
	{
		ClearTimer('RechargeTimer');	
		bCurrentlyRecharging = false; 
		if(WorldInfo.NetMode != NM_DedicatedServer) Rx_Controller(Instigator.Controller).ClientPlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundPurchase') ; //SoundCue'Rx_Pickups.Sounds.SC_Pickup_Keycard' ; 
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

simulated function Init(Pawn InitiatingPawn)
{
	UsingPawn = InitiatingPawn; 
	`log("Initialize Passive Ability" @ self @ "with Pawn " @ UsingPawn);
} 

function RemoveUser()
{
	UsingPawn = none; 
	SetTimer(0.5,false,'ToDestroy');
	
}

function ToDestroy()
{
   Destroy();
}

simulated function ActivateAbility()
{
	`log("Activate"); 
} 

simulated function DeactivateAbility(bool bForce)
{
	`log("Deactivate"); 
}

simulated function NotifyLanded(); //Called when our pawn lands 

//Called if our Pawn pulls a dodge move. 
simulated function bool NotifyDodged(int DodgeDir){
	return false; 
}

//Called when crouch is pressed/released
simulated function NotifyCrouched(bool Toggle); 

simulated function NotifySprint(bool Toggle); //Called when our pawn starts/stops sprinting

simulated function DrawHUD(Canvas HUDCanvas); 

simulated function float GetConsumptionRate(){
	return 1; 
}

simulated function bool GetRespondingToCrouch(); //Returns if this ability is currently responding to crouch being pressed 



DefaultProperties
{
	bSingleCharge = true
	ConsumptionRate = 0.5
	
	AssignedSlot=255 //255 by default, so even switching to 0 is replicated without the need for math
	
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