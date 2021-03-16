/*Acts as a lightweight proxy between other clients and the visual/audio effects played by passive abilities. The owning client of an ability is the only one who needs to know anything about the actual ability*/

class Rx_PassiveAbilityAttachment extends Actor
abstract; 

//Authoritative Pawn on server 
var Pawn OwnerPawn;
var bool bDestroyed; //Used as a flag to tell functions to more or less ignore any calls to them 

/**replication{ 
	if(bNetDirty || bNetInitial)
		OwnerPawn;
}*/

function InitAttachment(Pawn OwningPawn){
	if(RxIfc_PassiveAbility(OwningPawn) != none){
		OwnerPawn = OwningPawn;
	}
}

//Same as Passive Abilities 
function NotifyMeshChanged();
function NotifyOverlayChanged(MaterialInterface NewMIC); 
function NotifyMaterialsChanged(); 
function NotifyTookDamage();
function NotifyWeaponAttachmentsChanged();
function NotifyBackWeaponAttachmentsChanged();
function NotifyDriveVehicle(bool bDriving);

function NotifyOwnerDied(){DestroyAttachment();}
function NotifyWeaponFired(byte FireModeNum); 
function NotifyPhysicsVolumeChange(PhysicsVolume NewVolume);


function DestroyAttachment()
{
	`log("-----Kill off attachment--------" @ self);
	StopEffects(); 
	OwnerPawn = none;
	bDestroyed = true; 
	Destroy(); 
}



function PlayEffects(); 
function StopEffects(); 

DefaultProperties
{	
	bReplicateInstigator = true 
	RemoteRole=ROLE_NONE //Be thy own master 
}