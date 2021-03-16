interface RxIfc_PassiveAbility; //Interface for anything capable of using passive abilities

function GivePassiveAbility(byte AbilityNum, class<Rx_PassiveAbility> PassiveAbility);

simulated function RemovePassive(byte SlotNum, Rx_PassiveAbility PassiveAbility); //Allows removing of a single passive ability 

simulated function ReplicatePassiveAbility (byte AbilityNum, Rx_PassiveAbility PassiveAbility); //Called on the client. Passes an actual instance of an ability class 

simulated function bool ActivateJumpAbility(bool Toggle) ; //(Usually Tied to 'SpaceBar') Returns if the ability was successfully activated 

simulated function bool ActivateAbility0(bool Toggle); // (Usually tied to 'X')Returns if the ability was successfully activated 

simulated function bool ActivateAbility1(bool Toggle); //(Usually Tied to 'G') Returns if the ability was successfully activated 

simulated function RenderPassiveOverlays(HUD H); //Renders overlays (crosshair/lock-on HUD stuff) for Passives

//Notifies 

simulated function NotifyPassivesLanded();

/*Notify passives we hit the dodge button in one of 8 directions. Return value useful if we need to interrupt other behaviour. */
simulated function bool NotifyPassivesDodged(int Dir); 

simulated function NotifyPassivesCrouched(bool Toggle); //Called when crouch is PRESSED.

simulated function NotifyPassivesSprint(bool Toggle);

simulated function NotifyPassivesMeshChanged(); 

simulated function NotifyPassivesOverlayChanged(MaterialInterface NewMIC);

simulated function NotifyPassivesMaterialsChanged();

simulated function NotifyPassivesTookDamage();

simulated function NotifyPassivesDied();

simulated function NotifyPassivesServerMove(float DeltaTime);

simulated function NotifyPassivesPlayerMove(name ControllerState, vector NewAccelVector, float DeltaTime);

simulated function NotifyPassivesWeaponFired(byte FireModeNum); 

simulated function NotifyPassivesBumpedActor(Actor Other, Vector Vel, Vector HitNormal);

simulated function NotifyPassivesPhysicsVolumeChanged(PhysicsVolume NewVolume);