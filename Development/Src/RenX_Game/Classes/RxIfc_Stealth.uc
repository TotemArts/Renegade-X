/**Interface for Stealthed units
*Most code will be in the units themselves, but the interface allows them to lump common functions in with one another
*and to not individually cast to different types of vehicles/paws/possibly structures. 
***/
interface RxIfc_Stealth;

simulated function bool GetIsinTargetableState();

simulated function bool GetIsStealthCapable(); 

simulated function ChangeStealthVisibilityParam(bool ForOnFoot, optional float PercentMod = 1.0); //Swaps between infantry/vehicle stealth detect difference (And can include modifiers if necessary)


/*******************************************************************
****This is a sample block of variables from the Ren-X Stealth Black Hand class****
******************************************************************
*
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
*/