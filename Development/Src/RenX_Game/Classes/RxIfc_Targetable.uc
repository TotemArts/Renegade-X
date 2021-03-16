interface RxIfc_Targetable; //Interface for anything that can be targeted
/*-------------------------------------------*/
/*BEGIN TARGET INTERFACE [RxIfc_Targetable]*/
/*------------------------------------------*/
//Health
simulated function int GetTargetHealth(); //Return the current health of this target
simulated function int GetTargetHealthMax(); //Return the current health of this target

//Armour 
simulated function int GetTargetArmour() ; // Get the current Armour of the target
simulated function int GetTargetArmourMax() ; // Get the current Armour of the target 

// Veterancy

simulated function int GetVRank();

/*Get Health/Armour Percents*/
simulated function float GetTargetHealthPct(); 
simulated function float GetTargetArmourPct();
simulated function float GetTargetMaxHealthPct(); //Everything together (Basically Health and armour)

/*Get what we're actually looking at*/
simulated function Actor GetActualTarget(); //Should return 'self' most of the time, save for things that should return something else (like building internals should return the actual building)

/*Booleans*/
simulated function bool GetUseBuildingArmour(); //Stupid legacy function to determine if we use building armour when drawing. 
simulated function bool GetShouldShowHealth(); //If we need to draw health on this 
simulated function bool AlwaysTargetable() ; //Targetable no matter what range they're at
simulated function bool GetIsInteractable(PlayerController PC); //Are we ever interactable?
simulated function bool GetCurrentlyInteractable(PlayerController RxPC); //Are we interactable right now? 
simulated function bool GetIsValidLocalTarget(Controller PC); //Are we a valid target for our local playercontroller?  
simulated function bool HasDestroyedState(); //Do we have a destroyed state where we won't have health, but can't come back? (Buildings in particular have this)
simulated function bool UseDefaultBBox();
simulated function bool IsStickyTarget(); //Does our target box 'stick' even after we're untargeted for awhile 
simulated function bool HasVeterancy();
//Spotting
simulated function bool IsSpottable(); 
simulated function bool IsCommandSpottable(); 

simulated function bool IsSpyTarget(); //Do we use spy mechanics? IE: our bounding box will show up friendly to the enemy

/* Text related */

simulated function string GetTargetName(); //Get our targeted name 
simulated function string GetInteractText(Controller C, string BindKey); //Get the text for our interaction 
simulated function string GetTargetedDescription(PlayerController PlayerPerspectiv); //Get any special description we might have when targeted 

//Actions
simulated function SetTargeted(bool bTargeted); //Function to say what to do when you're targeted client-side 

/*----------------------------------------*/
/*END TARGET INTERFACE [RxIfc_Targetable]*/
/*---------------------------------------*/