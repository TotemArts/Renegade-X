/*********************************************************
*
* File: RxInventoryManager.uc
* Author: RenegadeX-Team 
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*  Overwrites the default pickup methods for the new inventory system.
*
* ConfigFile:
*
*********************************************************
* <3 Vipeax
*********************************************************/

class Rx_InventoryManager extends UTInventoryManager
	config(Game)
	abstract;

var bool InterruptWeaponSwap;
var byte PreviousInventoryGroup;

/** one1: Categorized weapons. */
var array<class<Rx_Weapon> > PrimaryWeapons;
var array<class<Rx_Weapon> > SecondaryWeapons;
var array<class<Rx_Weapon> > SidearmWeapons;
var array<class<Rx_Weapon> > ExplosiveWeapons;
var array<class<Rx_Weapon> > Items;

var array<Rx_WeaponAbility>  AbilityWeapons; // Separated, as these don't simply have rigid inventory groups just where they're placed 
//var array<class<Rx_PassiveAbility> > PassiveAbilities;

/** one1: Weapon classification. */
var enum EClassification
{
	CLASS_PRIMARY,
	CLASS_SECONDARY,
	CLASS_SIDEARM,
	CLASS_EXPLOSIVE,
	CLASS_ITEM,
	CLASS_ABILITY
} Classification;

var array<class<Rx_Weapon> > AvailableSidearmWeapons;
var array<class<Rx_Weapon> > AvailableExplosiveWeapons;
var array<class<Rx_Weapon> > AvailableSecondaryWeapons;
var array<class<Rx_Weapon> > AvailableItems;
var array<class<Rx_WeaponAbility> > AvailableAbilityWeapons; //

//Inversely...
var array<class<Rx_Weapon> > ForbiddenItems;

var Weapon LastWeapon; 

event PreBeginPlay()
{
	super.PreBeginPlay();

	/** one1: Print warning if we forgot to set primary weapon for any inventory type. */
	if (default.PrimaryWeapons[0] == none)
		`log("WARNING: Primary weapon for " $ Owner $ " (family " $ self.Class $ ") not set!");
}

/** one1: Override these functions in subclasses. GUI should call these functions to
 *  get number of how many slots per each classification are available. */
function int GetPrimaryWeaponSlots() { return default.PrimaryWeapons.Length; }
function int GetSecondaryWeaponSlots() { return default.SecondaryWeapons.Length; }
function int GetSidearmWeaponSlots() { return default.SidearmWeapons.Length; }
function int GetExplosiveWeaponSlots() { return default.ExplosiveWeapons.Length; }
function int GetItemSlots() { return 1; };
function  int GetWeaponAbilitySlots() {return default.AvailableAbilityWeapons.Length ; } 	; 

/** one1: Override these functions in subclasses. GUI should call these functions to
 *  obtain list of possible weapons for character. */
simulated function array<class<Rx_Weapon> > GetAvailablePrimaryWeapons() { return default.PrimaryWeapons;	} // usually allowed only certain prim. weapon
simulated function array<class<Rx_Weapon> > GetAvailableSecondaryWeapons() { return default.AvailableSecondaryWeapons; }
simulated function array<class<Rx_Weapon> > GetAvailableSidearmWeapons() { return default.AvailableSidearmWeapons; }
simulated function array<class<Rx_Weapon> > GetAvailableExplosiveWeapons() { return default.AvailableExplosiveWeapons; }
simulated function array<class<Rx_Weapon> > GetAvailableItems() { return default.AvailableItems; }

// Inverse of above
simulated function array<class<Rx_Weapon> > GetForbiddenItems() { return default.ForbiddenItems; }

/** one1: Call to determine if this character is permitted to have the wanted weapon. */
simulated function bool IsPrimaryWeaponAllowed(class<Rx_Weapon> w) { return IsClassifiedWeaponAllowed(w, GetAvailablePrimaryWeapons()); }
simulated function bool IsSecondaryWeaponAllowed(class<Rx_Weapon> w) { return IsClassifiedWeaponAllowed(w, GetAvailableSecondaryWeapons()); }
simulated function bool IsSidearmWeaponAllowed(class<Rx_Weapon> w) { return IsClassifiedWeaponAllowed(w, GetAvailableSidearmWeapons()); }
simulated function bool IsExplosiveWeaponAllowed(class<Rx_Weapon> w) { return IsClassifiedWeaponAllowed(w, GetAvailableExplosiveWeapons()); }
simulated function bool IsItemAllowed(class<Rx_Weapon> w) { return IsClassifiedWeaponAllowed(w, GetAvailableItems()); }

private simulated function bool IsClassifiedWeaponAllowed(class<Rx_Weapon> w, array<class<Rx_Weapon> > a)
{
	local int i;

	for (i = 0; i < a.length; i++)
		if (ClassIsChildOf(w,a[i]) && !IsClassifiedWeaponForbidden(w,GetForbiddenItems())) return true;

	return false;
}

private simulated function bool IsClassifiedWeaponForbidden(class<Rx_Weapon> w, array<class<Rx_Weapon> > a)
{
	local int i;

	if(a.length <= 0)
		return false;

	for (i = 0; i < a.length; i++)
		if (ClassIsChildOf(w,a[i])) return true;

	return false;
}


/** one1: Return current weapon classes of specified class index in inventory. 
 *  For class index, check classification in Rx_Weapon class. */
simulated function array<class<Rx_Weapon> > GetWeaponsOfClassification(EClassification classindex)
{
	switch (classindex)
	{
		case CLASS_PRIMARY:
			return PrimaryWeapons;
		case CLASS_SECONDARY:
			return SecondaryWeapons;
		case CLASS_SIDEARM:
			return SidearmWeapons;
		case CLASS_EXPLOSIVE:
			return ExplosiveWeapons;
		case CLASS_ITEM:
			return Items;
	}
}

/** one1: Remove all weapons of certain classification. */
simulated function RemoveWeaponsOfClassification(EClassification classindex)
{
	local array<class<Rx_Weapon> > remlist;
	local int i;

	switch (classindex)
	{
		case CLASS_PRIMARY:
			remlist = PrimaryWeapons;
			break;
		case CLASS_SECONDARY:
			remlist = SecondaryWeapons;
			break;
		case CLASS_SIDEARM:
			remlist = SidearmWeapons;
			break;
		case CLASS_EXPLOSIVE:
			remlist = ExplosiveWeapons;
			break;
		case CLASS_ITEM:
			remlist = Items;
			break;
	}

	for (i = 0; i < remlist.Length; i++)
	{
		RemoveFromInventory(FindInventoryType(remlist[i]));
		FindInventoryType(remlist[i]).Destroy();
	}
		
	remlist.Length = 0;

	Rx_Pawn(Owner).RefreshBackWeapons();
}

/** one1: Remove single weapon of known class. */
simulated function RemoveWeaponOfClass(class<Rx_Weapon> wclass)
{
	local Rx_Weapon inv;

	foreach InventoryActors(class'Rx_Weapon', inv)
	{
		if (inv.Class == wclass) {
			RemoveFromInventory(inv);
			inv.Destroy();
		}
	}

	// remove from class list
	PrimaryWeapons.RemoveItem(wclass);
	SecondaryWeapons.RemoveItem(wclass);
	SidearmWeapons.RemoveItem(wclass);
	ExplosiveWeapons.RemoveItem(wclass);
	Items.RemoveItem(wclass);

	Rx_Pawn(Owner).RefreshBackWeapons();
}

/** one1: Add new weapon. */
simulated function Rx_Weapon AddWeaponOfClass(class<Rx_Weapon> wclass, EClassification classindex)
{
	local Rx_Weapon w;
	
	switch (classindex)
	{
		case CLASS_PRIMARY:
			if(IsPrimaryWeaponAllowed(wclass)){
					// `log("Adding weapons from IsPrimaryWeaponAllowed()");
				PrimaryWeapons.AddItem(wclass);
			} 
			else if (wclass == class'Rx_Weapon_Grenade' 
				|| wclass == class'Rx_Weapon_ProxyC4'
				|| wclass == class'Rx_Weapon_EMPGrenade'
				|| wclass == class'Rx_Weapon_SmokeGrenade'
				|| wclass == class'Rx_Weapon_ATMine') {
					// `log("Adding weapons");
				PrimaryWeapons.AddItem(wclass);
			} 
			else {
				// `log("Failed adding weapons");
				return None;	
			}
			break;
		case CLASS_SECONDARY:
			if(IsSecondaryWeaponAllowed(wclass))
				SecondaryWeapons.AddItem(wclass);
			else
				return None;					
			break;
		case CLASS_SIDEARM:
			if(IsSidearmWeaponAllowed(wclass))
				SidearmWeapons.AddItem(wclass);
			else
				return None;					
			break;
		case CLASS_EXPLOSIVE:
			if(IsExplosiveWeaponAllowed(wclass))
				ExplosiveWeapons.AddItem(wclass);
			else
				return None;					
			break;
		case CLASS_ITEM:
			if(IsItemAllowed(wclass))
				Items.AddItem(wclass);
			else
				return None;					
			break;
	}

	if(FindInventoryType(wclass) != None) {
		SetCurrentWeapon(Rx_Weapon(FindInventoryType(wclass)));
		Rx_Pawn(Owner).RefreshBackWeapons();
		
		return None;
	}

	w = Rx_Weapon(CreateInventory(wclass, false));
	
	SetCurrentWeapon(w);
	Rx_Pawn(Owner).RefreshBackWeapons();
	//PromoteAllWeapons(Rx_PRI(Owner.PlayerReplicationInfo).VRank);
	if(ROLE == ROLE_Authority) 
		w.PromoteWeapon(Rx_Pawn(Owner).VRank);
	
	return w;
}


/** one1: Get weapon attachment classes that aren't visible. 
 *  The size of out array is fixed. Change this size if you change number of back attachment slots! */
function GetHiddenWeaponAttachmentClasses(out class<Rx_BackWeaponAttachment> attclasses[5])
{
	local Rx_Weapon inv;
	//local int index;
	local int i;

	// clear
	for (i = 0; i < ArrayCount(attclasses); i++)
		attclasses[i] = none;

	foreach InventoryActors(class'Rx_Weapon', inv)
	{
		// holding weapon
		if (inv == Instigator.Weapon) continue;

		// no back attachment specified, ignore
		if (inv.BackWeaponAttachmentClass == none || !inv.bDrawBackAttachment() ) continue;

		attclasses[inv.BackWeaponAttachmentClass.static.GetSocketIndex(self)] = inv.BackWeaponAttachmentClass;
	}
}

/** one1: Same as above but used on non-instanced inv. manager to obtain default back attachments. */
static function GetStartingHiddenWeaponAttachmentClasses(class<Rx_InventoryManager> invtype, 
	out class<Rx_BackWeaponAttachment> attclasses[5])
{
	local int i;

	// clear 
	for (i = 0; i < ArrayCount(attclasses); i++)
		attclasses[i] = none;

	SetStartingHiddenWeaponAttachmentClassesPerCategory(attclasses, default.PrimaryWeapons, invtype, true);
	SetStartingHiddenWeaponAttachmentClassesPerCategory(attclasses, default.SecondaryWeapons, invtype, false);
	SetStartingHiddenWeaponAttachmentClassesPerCategory(attclasses, default.SidearmWeapons, invtype, false);
	SetStartingHiddenWeaponAttachmentClassesPerCategory(attclasses, default.ExplosiveWeapons, invtype, false);
	SetStartingHiddenWeaponAttachmentClassesPerCategory(attclasses, default.Items, invtype, false);
}

static private function SetStartingHiddenWeaponAttachmentClassesPerCategory(
	out class<Rx_BackWeaponAttachment> attclasses[5],
	array<class<Rx_Weapon> > cat,
	class<Rx_InventoryManager> invtype,
	bool skipFirst)
{
	local class<Rx_BackWeaponAttachment> bclass;
	local int i;

	for (i = skipFirst ? 1 : 0; i < cat.Length; i++)
	{
		bclass = cat[i].default.BackWeaponAttachmentClass;
		if (bclass == none) continue;
		attclasses[bclass.static.GetDefaultSocketIndex(invtype)] = bclass;
	}
}

/** one1: Adds weapons from specified array; before adding, check is performed;
 *  if weapon is already in list, it is not re-added. */
private function AddWeaponsFromArray(array<class<Rx_Weapon> > a, bool bActivateFirst)
{
	local int i;
	//local Rx_Weapon W;  

    for (i = 0; i < a.length; i++) 
    {
      	if (FindInventoryType(a[i]) == none) 
      	{
  	    	Rx_Weapon(CreateInventory(a[i], !(i == 0 && bActivateFirst)));
			
			/**if(W != none) 
				W.CreateAttachedAbility();*/
		}
	} 
}

simulated function SetWeaponsForPawn()
{
	local Rx_Weapon W;

	// first remove all the weapons, but standard weapons!
	foreach InventoryActors(class'Rx_Weapon', W) 
	{
		if(Rx_Weapon_Beacon(W) == None && Rx_Weapon_Airstrike(W) == None) 
		{
       		RemoveFromInventory(W);
			w.Destroy();
       	}
 	}

	InitAbilities(); 

	AddWeaponsFromArray(SecondaryWeapons, false);
	AddWeaponsFromArray(SidearmWeapons, false);
	AddWeaponsFromArray(ExplosiveWeapons, false);
	AddWeaponsFromArray(Items, false);
	AddWeaponsFromArray(PrimaryWeapons, true);

	Rx_Pawn(Owner).RefreshBackWeapons();
}

simulated function SwitchToStartWeapon()
{
	SetCurrentWeapon(Weapon(FindInventoryType(default.PrimaryWeapons[0])));
}
simulated function SwitchToSidearmWeapon()
{
	SetCurrentWeapon(Weapon(FindInventoryType(default.SidearmWeapons[0])));
}

simulated function ChangedWeapon()
{
	super.ChangedWeapon();
	HandleWeaponSockets();

	/** one1: Added to update back weapons. */
	if (Role == ROLE_Authority)
	{
		Rx_Pawn(Owner).RefreshBackWeapons();
	}
}

reliable client function SetCurrentWeapon( Weapon DesiredWeapon )
{
	Super.SetCurrentWeapon( DesiredWeapon );

	if( Rx_Pawn(Instigator).bThrowingGrenade && DesiredWeapon.IsA('Rx_Weapon_Grenade') )
	{
		Instigator.Weapon.StartFire(0);
		SetTimer(2.0, false, 'SwitchToPreviousWeapon');
	}
}

//Legacy. Uses weapon groups 
simulated function SwitchToPreviousWeapon()
{
		Instigator.Weapon.StopFire(0);
		Rx_Pawn(Instigator).bThrowingGrenade = false;
		SwitchWeapon(PreviousInventoryGroup);
}

//Uses the actual last weapon held
simulated function SwitchtoLastUsedWeapon()
{
	//`log("Switch to Last Used Weapon" @ LastWeapon);

	Rx_Pawn(Instigator).PreviousWeaponClass = class<Rx_Weapon>(Instigator.Weapon.class);
	SetCurrentWeapon(LastWeapon); 
}

simulated function SwitchWeapon(byte NewGroup)
{
	local UTWeapon CurrentWeapon;
	
	if( Rx_Pawn(Instigator).bThrowingGrenade && NewGroup != 12 )
		return;
		
		CurrentWeapon = UTWeapon(Instigator.Weapon);
		Rx_Pawn(Instigator).PreviousWeaponClass = class<Rx_Weapon>(CurrentWeapon.class);
		LastWeapon=CurrentWeapon; 
		
		/**if (CurrentWeapon != none && CurrentWeapon.InventoryGroup == NewGroup)
		{
			return;
		}*/
	
		Super.SwitchWeapon(NewGroup);
	
}

simulated function Weapon GetBestWeapon( optional bool bForceADifferentWeapon  )
{
	local Weapon	W, BestWeapon;
	local float		Rating, BestRating;

	ForEach InventoryActors( class'Weapon', W )
	{
		if(Rx_WeaponAbility(W) != none) continue; 
		
		if( w.HasAnyAmmo() )
		{
			if( bForceADifferentWeapon &&
				W == Instigator.Weapon )
			{
				continue;
			}

			Rating = W.GetWeaponRating();
			if( BestWeapon == None ||
				Rating > BestRating )
			{
				BestWeapon = W;
				BestRating = Rating;
			}
		}
	}

	return BestWeapon;
}

simulated function AdjustWeapon(int NewOffset)
{
	local Weapon CurrentWeapon;
	local array<UTWeapon> WeaponList;
	local int i, Index;
	// don't allow multiple weapon switches very close to one another (seems to happen with some mouse wheels)
	if (WorldInfo.TimeSeconds - LastAdjustWeaponTime < 0.5)	
		return;
	
	LastAdjustWeaponTime = WorldInfo.TimeSeconds;
	Rx_Weapon(Instigator.Weapon).PlayWeaponPutDown();
	Rx_Pawn(Owner).ResetRelaxStance(true);

	CurrentWeapon = UTWeapon(PendingWeapon);
	if (CurrentWeapon == None)	
		CurrentWeapon = UTWeapon(Instigator.Weapon);	

	if (Rx_Pawn(Owner) != none)
		Rx_Pawn(Owner).Relax(false);

   	GetWeaponList(WeaponList,,, false);
   	if (WeaponList.length == 0)   	
   		return;
   	

	for (i = 0; i < WeaponList.Length; i++)
	{
		if (WeaponList[i] == CurrentWeapon)
		{
			Index = i;
			break;
		}
	}
	Index += NewOffset*-1;

	if (Index < 0)	
		Index = WeaponList.Length - 1;	

	else if (Index >= WeaponList.Length)
		Index = 0;	

	if (Index >= 0)
		SetCurrentWeapon(WeaponList[Index]);
	
}

function HandleWeaponSockets()
{
	//local Rx_Weapon PrimarySocketWeapon;
	//local Rx_Weapon SecondarySocketWeapon;
    local Rx_Pawn P;
	local array<Rx_Weapon> WeaponList;
	local int i;
	local int Index;
	super.ChangedWeapon();
		
    P = Rx_Pawn(Owner); 
   	if(P == None)
		return;
		
	if (P.BackSocketComponent != None)
		P.Mesh.DetachComponent(P.BackSocketComponent);
	if (P.C4SocketComponent != None)
		P.Mesh.DetachComponent(P.C4SocketComponent);
	if (P.PistolSocketComponent != None)
		P.Mesh.DetachComponent(P.PistolSocketComponent);	
	switch (Rx_Weapon(P.Weapon).InventoryGroup)
	{
		case 1:
			/* Primary Weapon (default: pistol) is in our hands.
			 * PistolSocket: Empty
			 * C4Socket: Empty (no C4s in BD)
			 * WeaponSocket: First primary weapon
			 */
			GetPrimaryWeaponList(WeaponList);
			if( WeaponList.Length > 0 ) {
				//PrimarySocketWeapon = WeaponList[Index];
				WeaponList.Remove(0, WeaponList.Length);				
			}
			break;
		case 2:
			/* Secondary Weapon is in our hands.
			 * PistolSocket: Pistol
			 * C4Socket: Empty (no C4s in BD)
			 * WeaponSocket: The other primary weapon
			 */
			if( WeaponList.Length == 0 ) {
				break;
			} 
			WeaponList.Remove(0, WeaponList.Length);
			GetPrimaryWeaponList(WeaponList);
			if (WeaponList.Length > 1)
			{
				for (i = 0; i < WeaponList.Length; i++)
				{
					if (WeaponList[i] == P.Weapon)
					{
						Index = i;
						break;
					}
				}
				Index += 1;
				if (Index < 0)
				{
					Index = WeaponList.Length - 1;
				}
				else if (Index >= WeaponList.Length)
				{
					Index = 0;
				}
				//PrimarySocketWeapon = WeaponList[Index];

				i = 0;
			}	
			WeaponList.Remove(0, WeaponList.Length);
			GetSecondaryWeaponList(WeaponList);
			if (WeaponList.Length > 0)
			{
				for (i = 0; i < WeaponList.Length; i++)
				{
					if (WeaponList[i] == P.Weapon)
					{
						Index = i;
						break;
					}
				}
				Index += 1;
				if (Index < 0)
				{
					Index = WeaponList.Length - 1;
				}
				else if (Index >= WeaponList.Length)
				{
					Index = 0;
				}
				//SecondarySocketWeapon = WeaponList[Index];
				WeaponList.Remove(0, WeaponList.Length);	
				i = 0;
			}
			break;
		case 3:
			break;
		case 4:
			break;
		default:
			break;
	}
	P.BackSocketComponent = None;
	P.C4SocketComponent = None;
	P.PistolSocketComponent = None;
	/**
	if (PrimarySocketWeapon != None && Rx_WeaponAttachment(PrimarySocketWeapon.WeaponAttachment) != None)
	{
		Rx_WeaponAttachment(PrimarySocketWeapon.WeaponAttachment).WeaponSocketMesh.SetShadowParent(P.Mesh);
		Rx_WeaponAttachment(PrimarySocketWeapon.WeaponAttachment).WeaponSocketMesh.SetLightEnvironment(P.LightEnvironment);
		P.BackSocketComponent = Rx_WeaponAttachment(PrimarySocketWeapon.WeaponAttachment).WeaponSocketMesh;
		P.Mesh.AttachComponentToSocket(Rx_WeaponAttachment(PrimarySocketWeapon.WeaponAttachment).WeaponSocketMesh, P.WeaponBackSocket);	
	}
	if (SecondarySocketWeapon != None && Rx_WeaponAttachment(SecondarySocketWeapon.WeaponAttachment) != None)
	{
		Rx_WeaponAttachment(SecondarySocketWeapon.WeaponAttachment).WeaponSocketMesh.SetShadowParent(P.Mesh);
		Rx_WeaponAttachment(SecondarySocketWeapon.WeaponAttachment).WeaponSocketMesh.SetLightEnvironment(P.LightEnvironment);
		P.PistolSocketComponent = Rx_WeaponAttachment(SecondarySocketWeapon.WeaponAttachment).WeaponSocketMesh;
		P.Mesh.AttachComponentToSocket(Rx_WeaponAttachment(SecondarySocketWeapon.WeaponAttachment).WeaponSocketMesh, P.WeaponPistolSocket);			
	}
	*/
}

/**
 * This function returns a sorted list of primary weapons, sorted by their InventoryWeight.
 *
 * @Returns the index of the current Weapon
 */
simulated function GetPrimaryWeaponList(out array<Rx_Weapon> WeaponList, optional bool bFilter, optional int GroupFilter, optional bool bNoEmpty)
{
	local Rx_Weapon Weap;
	local int i;

	ForEach InventoryActors( class'Rx_Weapon', Weap )
	{
		if ( (!bFilter || Weap.InventoryGroup == GroupFilter) && ( !bNoEmpty || Weap.HasAnyAmmo()) && Weap.InventoryGroup == 2)
		{
			if ( WeaponList.Length>0 )
			{
				// Find it's place and put it there.

				for (i=0;i<WeaponList.Length;i++)
				{
					if (WeaponList[i].InventoryWeight > Weap.InventoryWeight)
					{
						WeaponList.Insert(i,1);
						WeaponList[i] = Weap;
						break;
					}
				}
				if (i==WeaponList.Length)
				{
					WeaponList.Length = WeaponList.Length+1;
					WeaponList[i] = Weap;
				}
			}
			else
			{
				WeaponList.Length = 1;
				WeaponList[0] = Weap;
			}
		}
	}
}

/**
 * This function returns a sorted list of secondary weapons, sorted by their InventoryWeight.
 *
 * @Returns the index of the current Weapon
 */
simulated function GetSecondaryWeaponList(out array<Rx_Weapon> WeaponList, optional bool bFilter, optional int GroupFilter, optional bool bNoEmpty)
{
	local Rx_Weapon Weap;
	local int i;

	ForEach InventoryActors( class'Rx_Weapon', Weap )
	{
		if ( (!bFilter || Weap.InventoryGroup == GroupFilter) && ( !bNoEmpty || Weap.HasAnyAmmo()) && Weap.InventoryGroup == 1)
		{
			if ( WeaponList.Length>0 )
			{
				// Find it's place and put it there.

				for (i=0;i<WeaponList.Length;i++)
				{
					if (WeaponList[i].InventoryWeight > Weap.InventoryWeight)
					{
						WeaponList.Insert(i,1);
						WeaponList[i] = Weap;
						break;
					}
				}
				if (i==WeaponList.Length)
				{
					WeaponList.Length = WeaponList.Length+1;
					WeaponList[i] = Weap;
				}
			}
			else
			{
				WeaponList.Length = 1;
				WeaponList[0] = Weap;
			}
		}
	}
}


simulated function bool IsAmmoFull()
{
	local Rx_Weapon Weap;

	ForEach InventoryActors( class'Rx_Weapon', Weap )
	{
		if (!Weap.bHasInfiniteAmmo && Weap.AmmoCount < Weap.MaxAmmoCount && Weap.bCanGetAmmo)
			return false;
	}
	return true;
}

simulated function PerformWeaponRefill()
{
	local Rx_Weapon Weap;

	ForEach InventoryActors( class'Rx_Weapon', Weap )
	{
		Weap.PerformRefill();
		Weap.bForceHidden = false;
	}

	// some weapons hide on empty ammo (mines, etc). Need to redraw them if applicable
	Rx_Pawn(Owner).RefreshBackWeapons();
}

simulated function PromoteAllWeapons(byte rank) 
{
	local Rx_Weapon Weap;

	ForEach InventoryActors( class'Rx_Weapon', Weap )
	{
		Weap.PromoteWeapon(rank);
		Weap.bForceHidden = false;
	}
}

simulated function DoubleToggleCam()
{
	local Rx_Controller pc;
	pc = Rx_Controller(GetALocalPlayerController());

	if(pc.IsPlayerOwned())
	{
		if (!Instigator.IsFirstPerson())
		{
			//Switch to 1st person
			pc.ToggleCam();
			//...And back to 3rd person.
			pc.ToggleCam();
		}
	}
}

simulated function SetPendingFire(Weapon InWeapon, int InFiringMode)
{
	if(Rx_Weapon_SniperRifle(InWeapon) != None && InFiringMode == 1 && Rx_Weapon_SniperRifle(InWeapon).bDisplayCrosshair) 
	{
		Rx_Weapon_SniperRifle(InWeapon).EndZoom(UTPlayerController(Instigator.Controller));
	} 
	else
	{
		super.SetPendingFire(InWeapon, InFiringMode);
	} 
}

simulated function bool IsEquiped(class<Rx_Weapon> Weap, optional EClassification C)
{
	local class<Rx_Weapon> testWeap;

	if(C == 0 || C == EClassification.CLASS_PRIMARY)
	{
		foreach PrimaryWeapons(testWeap)
		{
			if(Weap == testWeap)
				return true;
		}
	}
	if(C == 0 || C == EClassification.CLASS_SECONDARY)
	{
		foreach SecondaryWeapons(testWeap)
		{
			if(Weap == testWeap)
				return true;
		}
	}

	if(C == 0 || C == EClassification.CLASS_SIDEARM)
	{
		foreach SidearmWeapons(testWeap)
		{
			if(Weap == testWeap)
				return true;
		}
	}

	if(C == 0 || C == EClassification.CLASS_EXPLOSIVE)
	{
		foreach ExplosiveWeapons(testWeap)
		{
			if(Weap == testWeap)
				return true;
		}
	}

	if(C == 0 || C == EClassification.CLASS_ITEM)
	{
		foreach Items(testWeap)
		{
			if(Weap == testWeap)
				return true;
		}
	}

	return false;
}

simulated function GetWeaponList(out array<UTWeapon> WeaponList, optional bool bFilter, optional int GroupFilter, optional bool bNoEmpty)
{
	local UTWeapon Weap;
	local int i;

	ForEach InventoryActors( class'UTWeapon', Weap )
	{
		//Ignore Abilities 
		if(Rx_WeaponAbility(Weap) != none) 
		{
		//Pawn(Owner).controller.ClientPlaySound(SoundCue'RX_SoundEffects.SFX.SC_Boink') ;
		continue; 		
		}
			
		if ( (!bFilter || Weap.InventoryGroup == GroupFilter) && ( (!bNoEmpty && Rx_Weapon_Deployable(Weap) == None && Rx_Weapon_Airstrike(Weap) == None) || Weap.HasAnyAmmo()))
		{
			if ( WeaponList.Length>0 )
			{
				// Find it's place and put it there.

				for (i=0;i<WeaponList.Length;i++)
				{
					if (WeaponList[i].InventoryWeight > Weap.InventoryWeight)
					{
						WeaponList.Insert(i,1);
						WeaponList[i] = Weap;
						break;
					}
				}
				if (i==WeaponList.Length)
				{
					WeaponList.Length = WeaponList.Length+1;
					WeaponList[i] = Weap;
				}
			}
			else
			{
				WeaponList.Length = 1;
				WeaponList[0] = Weap;
			}
		}
	}
}

function float GetInventoryWeight()
{
	local UTWeapon InvActor;
	local float Total;  
	
	ForEach InventoryActors( class'UTWeapon', InvActor )
	{
		if(Rx_Weapon(InvActor) != none) 
			Total += Rx_Weapon(InvActor).WeaponSpeedModifier ;
	}
	return Total; 
}

//Initialize/create active and passive abilities
private function InitAbilities()
{
	local int i; 
	local Rx_WeaponAbility NewAbility;
	//local Rx_PassiveAbility NewPAbility; 
	
	//Rid yourself of old abilities
	ClearAbilities();
	if(ROLE < ROLE_Authority)
		return; 
	
	for(i=0;i<AvailableAbilityWeapons.Length;i++)
	{
		if(AvailableAbilityWeapons[i] != none) 
		{
			NewAbility = Rx_WeaponAbility(CreateInventory(AvailableAbilityWeapons[i],true));
			//`log("Created New Ability" @ NewAbility) ; 
				AbilityWeapons.InsertItem(i, NewAbility);
				NewAbility.AssignedSlot = i;				
		}
	}
	
	/**for(i=0;i<=AvailablePassiveAbilities.Length;i++)
	{
		if(AvailablePassiveAbilities[i] != none) 
		{
			NewAbility = Rx_PassiveAbility(CreateInventory(AvailablePassiveAbilities[i],false));
			PassiveAbilities.InsertItem(i, NewPAbility);
		}
	}*/
	
}

//Add abilities derived from weapons you're holding/picked up
function Rx_WeaponAbility AddAbilityFromWeapon(class<Rx_WeaponAbility> WeaponA)
{
	local Rx_WeaponAbility NewAbility;
			
			if(ROLE < ROLE_Authority)
				return none; 
			
			NewAbility = Rx_WeaponAbility(CreateInventory(WeaponA,true));
			//`log("Created New Ability" @ NewAbility) ; 
			
			//Authoritative source adds it. Remote clients add on replication
				AbilityWeapons.InsertItem(AbilityWeapons.Length, NewAbility);
				NewAbility.AssignedSlot = AbilityWeapons.Length-1;
				
	
	//Incase anything else needs to modify this
	return AbilityWeapons[AbilityWeapons.length-1];	
}

simulated function ClearAbilities()
{
	local Rx_WeaponAbility RxA; 
	//local Rx_PassiveAbility RxPA;
	foreach AbilityWeapons(RxA) 
	{
		RemoveFromInventory(RxA);
		RxA.Destroy();
	}
	
	/**foreach PassiveAbilities(RxPA) 
	{
		RemoveFromInventory(RxPA);
	}*/
	
	AbilityWeapons.Length = 0;
	//PassiveAbilities.Length = 0; 
}

//Shouldn't need support for multiple abilities. The Jumpjets will be more of an always on kind of thing with its own HUD element
//EDIT: Dumb comment; Adding support for multiple abilities. 


/*Gets the list of abilities and also returns if there are any to begin with*/
simulated function bool GetAbilityList(out array<Rx_WeaponAbility> WeaponAbilityList, out array<Rx_PassiveAbility> PassiveAbilityList) 
{

local int i; 	
		
	if(AbilityWeapons.Length > 0) 
	{
		for(i=0;i<AbilityWeapons.Length;i++)
		{
			if(AbilityWeapons[i] != none) WeaponAbilityList.InsertItem(i, AbilityWeapons[i]); 
			//`log("Found Ability" @ AbilityWeapons[i]); 
		}
		return true; 
	}		
	else
		return false; 
}

simulated function Rx_WeaponAbility GetIndexedAbility(byte AbilityIndex)
{
	if(AbilityWeapons.Length > AbilityIndex) {
			return AbilityWeapons[AbilityIndex]; 
	}
	else
		return none; 
}

simulated function ClientSwitchToWeaponAbility(byte AbilityNumber)
{	
	SwitchToWeaponAbility(AbilityNumber) ;
	//ServerSwitchToWeaponAbility(AbilityNumber); 
	
}

reliable server function ServerSwitchToWeaponAbility(byte AbilityNumber)
{
	//`log("Fire Server"); 
	SwitchToWeaponAbility(AbilityNumber) ; 
}

simulated function SwitchToWeaponAbility(byte AbilityNumber) //Switches to ability 
{
	/*By default there is support for up to 4 different ability slots linked to '5', 'X', 'G' and 'Q'(Each coinciding to 1-4 respectively) */
	local array<Rx_WeaponAbility> MyAbilities;
	local Rx_WeaponAbility CurrentAbility;
	local array<Rx_PassiveAbility> PAbility; 
	
	if(!GetAbilityList(MyAbilities, PAbility)) 
		return; 
	else if(Rx_WeaponAbility_Attached(Instigator.Weapon) != none){
		//SwitchToPreviousWeapon();
		SwitchtoLastUsedWeapon();
	}
	else if(AbilityWeapons[AbilityNumber] != none) {
			CurrentAbility = AbilityWeapons[AbilityNumber] ; 
			
			if( Instigator.Weapon != AbilityWeapons[AbilityNumber] && CurrentAbility.bCanBeSelected() ) 
			{
				LastWeapon=Instigator.Weapon; 
				Rx_Pawn(Instigator).PreviousWeaponClass = class<Rx_Weapon>(Instigator.Weapon.class);
				PreviousInventoryGroup = Rx_Weapon(Instigator.Weapon).InventoryGroup;
				SetCurrentWeapon(AbilityWeapons[AbilityNumber]); 
			}
			else
			if(Instigator.Weapon == AbilityWeapons[AbilityNumber])
			{
				SwitchToPreviousWeapon();
			}
		return; 
		}	
	
}

//Inject to handle weapon abilities attached to weapons
simulated function bool AddInventory(Inventory NewItem, optional bool bDoNotActivate)
{
	if(super.AddInventory(NewItem, bDoNotActivate))
	{
		//Create a new ability
		if(Rx_Weapon(NewItem) != none) 
			Rx_Weapon(NewItem).CreateAttachedAbility();
		
		return true; 
	}
	
	return false; 
}

defaultproperties
{
	bMustHoldWeapon=true
	PendingFire(0)=0
	PendingFire(1)=0

	
	AvailableSidearmWeapons(0) = class'Rx_Weapon_Pistol_Unsilenced'//class'Rx_Weapon_Pistol'
	/**
	AvailableSidearmWeapons(1) = class'Rx_Weapon_SMG'
	AvailableSidearmWeapons(2) = class'Rx_Weapon_SMG_GDI'
	AvailableSidearmWeapons(3) = class'Rx_Weapon_SMG_Nod'
	AvailableSidearmWeapons(4) = class'Rx_Weapon_HeavyPistol'
	AvailableSidearmWeapons(5) = class'Rx_Weapon_TiberiumFlechetteRifle'
	AvailableSidearmWeapons(6) = class'Rx_Weapon_TiberiumAutoRifle'
	AvailableSidearmWeapons(7) = class'Rx_Weapon_Carbine'
	AvailableSidearmWeapons(8) = class'Rx_Weapon_RepairTool'
*/


	//AvailableExplosiveWeapons(0) = class'Rx_Weapon_Grenade' Fuck 'nades 'yo =|
	AvailableExplosiveWeapons(0) = class'Rx_Weapon_TimedC4'

/**		AvailableExplosiveWeapons(2) = class'Rx_Weapon_EMPGrenade'
	AvailableExplosiveWeapons(3) = class'Rx_Weapon_ATMine'
	AvailableExplosiveWeapons(4) = class'Rx_Weapon_SmokeGrenade'
*/
	AvailableItems(0) = class'Rx_Weapon_IonCannonBeacon'
	AvailableItems(1) = class'Rx_Weapon_NukeBeacon'
	AvailableItems(2) = class'Rx_Weapon_Airstrike_GDI'
	AvailableItems(3) = class'Rx_Weapon_Airstrike_Nod'
	AvailableItems(4) = class'Rx_Weapon_RepairTool'
	AvailableItems(5) = class'Rx_Weapon_Blueprint'

	SidearmWeapons[0] = class'Rx_Weapon_Pistol_Unsilenced' //class'Rx_Weapon_Pistol'
	ExplosiveWeapons[0] = class'Rx_Weapon_TimedC4'
}
