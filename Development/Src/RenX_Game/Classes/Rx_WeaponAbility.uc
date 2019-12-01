/****************************************************************************************
*Extension of Rx_Weapon built to be used for recharging abilities that don't have *******
*ammo but instead recharge over time. 

Blame Yosh for all issues with this. 
*****************************************************************************************
*****************************************************************************************/

class Rx_WeaponAbility extends Rx_Weapon;

//var() name WeaponThrowGrenadeAnimName[4];
//var array<float> DelayFireTime; 

var float MaxCharges; //Actual charges left to expend before needing to recharg
var float CurrentCharges; //Actual charges left to expend before needing to recharg

/*Timing*/
var bool  bSingleCharge; //Only has one shot before reloading. Use true to differentiate this on the HUD and let it know to use the Recharge delay to describe how long it has left to recharge
var float RechargeRate; //Recharge rate of this ability  
var float RechargeDelay; //Time between being fired and when it begins recharging

var bool bAlwaysRecharge ; //This Ability is always recharging when not full after a delay. 

var bool bCurrentlyRecharging; //Is it currently recharging
var bool bFireWhileRecharging; //Can it fire while it's recharging

var bool bCurrentlyFiring; 

var bool bSwitchWeapAfterFire ; //Switch back to the previous weapon after firing 
var float EmptySwapDelay; //Delay after firing last shot to swap back to the previous weapon 0.0 is no delay


var float Vet_RechargeSpeedMult[4];

/** The GFX ability set, 0-15. */
var byte AbilityMovieGroup;

//Slot number used by this weapon. Replicated to client so that they can interact client-side and not have to rely on serverwith laggy weapon switches  
var repnotify byte AssignedSlot;

var int	FlashMovieIconNumber; 


replication 
{
	if(ROLE == ROLE_AUTHORITY && bNetDirty && bNetOwner)
		AssignedSlot; 
}

/*Modify RepNotify slightly for when weapons are changed too quickly */

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
}




simulated state Active
{
	
	simulated function bool bReadyToFire()
	{
		return  !bCurrentlyRecharging || (bFireWhileRecharging && HasAnyAmmo())  ; 
	}

}



simulated state WeaponFiring
{
	/**		
	simulated function HandleFinishedFiring() 
	{
					
	}*/
	
	simulated event EndState( Name NextStateName )
	{
		
		if(CurrentCharges == 0 && bSwitchWeapAfterFire)   
		{
			bCurrentlyRecharging = true; 
			if(!IsTimerActive('RechargeTimer')) SetTimer(RechargeDelay,false,'SetRechargeTimer');
			else
			{
				ClearTimer('RechargeTimer') ; 
				SetTimer(RechargeDelay,false,'SetRechargeTimer');
			}
		}
		
		if(bAlwaysRecharge && CurrentCharges < MaxCharges)
		{
			if(!IsTimerActive('RechargeTimer')) SetTimer(RechargeDelay,false,'SetRechargeTimer');
			else
			{
				ClearTimer('RechargeTimer') ; 
				SetTimer(RechargeDelay,false,'SetRechargeTimer');
			}
		}
		
		super.EndState(NextStateName);
	}

}




	
simulated function bool HasAnyAmmo()
{
	return (bFireWhileRecharging && CurrentCharges >= (ShotCost[0])) || (!bFireWhileRecharging && !bCurrentlyRecharging); 
}



simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	if (Amount==0)
		return (CurrentCharges >= ShotCost[FireModeNum]);
	else
		return ( CurrentCharges >= Amount);
}

simulated function PerformRefill()
{} 

simulated function SetRechargeTimer()
{

	if(!IsTimerActive('RechargeTimer')) SetTimer(RechargeRate*Vet_RechargeSpeedMult[VRank],true,'RechargeTimer');
	else
	return;
}

simulated function RechargeTimer()
{
	if(CurrentCharges < MaxCharges) AddCharge(1);
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

simulated function SubtractCharge(int Num = 1)
{
	CurrentCharges = max(0, CurrentCharges-abs(Num)) ; 
}

simulated function bool bCanBeSelected()
	{
		return  !bCurrentlyRecharging || (bFireWhileRecharging && HasAnyAmmo())  ; 	
	}
	
simulated function bool bShouldBeVisible()
{
	return true; 
}
	
simulated function FireAmmunition()
{
	SubtractCharge(ShotCost[CurrentFireMode]); //Beyond subtracting charges, the 
	super.FireAmmunition();
}

simulated function WeaponEmpty()
{
	// If we were firing, stop
	if ( IsFiring() )
	{
		GotoState('Active');
		PerformEmptySwap();
		//Rx_InventoryManager(Instigator.InvManager).SwitchToPreviousWeapon();
	}
	
	if(bSwitchWeapAfterFire) 
		PerformEmptySwap();

	
}

simulated function PerformEmptySwap(){
	if(EmptySwapDelay > 0.0) SetTimer(EmptySwapDelay, false, 'SwitchToPreviousWeapon') ;
	else
	Rx_InventoryManager(Instigator.InvManager).SwitchToPreviousWeapon();
}

simulated function SwitchToPreviousWeapon(){
	Rx_InventoryManager(Instigator.InvManager).SwitchToPreviousWeapon();
}

simulated function float GetRechargeTiming()
{
	local float RemainingSingleChargeTime; 
	
	//(RechargeRate+RechargeDelay)
	
	RemainingSingleChargeTime = GetRechargeRealTime();
	//if(RemainingSingleChargeTime == 0) RemainingSingleChargeTime = 1; 
	
	if(bSingleCharge) 
		return RemainingSingleChargeTime/((RechargeRate+RechargeDelay)*Vet_RechargeSpeedMult[VRank]) ;  
	else
		return (CurrentCharges/MaxCharges);
}

simulated function float GetRechargeRealTime()
{
	return (Vet_RechargeSpeedMult[VRank]*(RechargeRate+RechargeDelay)-(GetTimerRate('RechargeTimer') - GetTimerCount('RechargeTimer')) );
}

simulated function int GetFlashIconInt()
{
	return FlashMovieIconNumber;
}

DefaultProperties
{
	bSingleCharge = true
	
	AssignedSlot=255 //255 by default, so even switching to 0 is replicated without the need for math
	
	bByPassHandIK = true //Don't really bother for these unless they become something big	
	
	Vet_RechargeSpeedMult(0) = 1.0 
	Vet_RechargeSpeedMult(1) = 1.0
	Vet_RechargeSpeedMult(2) = 1.0 
	Vet_RechargeSpeedMult(3) = 1.0 	
	
	FlashMovieIconNumber = 0 
	
	
	InventoryGroup = 12
}