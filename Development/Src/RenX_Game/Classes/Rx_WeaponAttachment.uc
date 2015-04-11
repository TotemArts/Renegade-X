class Rx_WeaponAttachment extends UTWeaponAttachment;

var const AnimSet DefaultWeaponAnimSet;
var const name    DefaultAimProfileName;
var       AnimSet WeaponAnimSet;
var       name    AimProfileName;

/** If true, pawn will always be "relaxed" while using this weapon. */
var       bool    bDontAim;


/*********************************************************************************************
 Empty Shell Ejection! -- Vipeax
********************************************************************************************* */

/** Holds the name of the socket to attach the particle to */
var name					ShellEjectSocket;

/** PSC and Templates*/

var ParticleSystemComponent	ShellEjectPSC;
var ParticleSystem			ShellEjectPSCTemplate, ShellEjectAltPSCTemplate;
var bool					bShellEjectPSCLoops;


/** How long the eject particle should be there */
var float					ShellEjectDuration;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	if( WeaponAnimSet == none )
	{
		WeaponAnimSet = DefaultWeaponAnimSet;
		//`logd("No Weapon AnimSet Setup for"@Class);
	}
	if( AimProfileName == 'none' )
	{
		AimProfileName = DefaultAimProfileName;
		//`logd("No Aim Profile Name Setup for"@Class);
	}
}

simulated function AttachTo(UTPawn OwnerPawn) 
{  
	super.AttachTo(OwnerPawn);

	if (ShellEjectSocket != '')
	{
		if (ShellEjectPSCTemplate != None || ShellEjectAltPSCTemplate != None)
		{
			ShellEjectPSC = new(self) class'UTParticleSystemComponent';
			ShellEjectPSC.bAutoActivate = false;
			ShellEjectPSC.SetOwnerNoSee(true);
			Mesh.AttachComponentToSocket(ShellEjectPSC, ShellEjectSocket);
		}
	}

	if( Rx_Pawn(OwnerPawn) != none )
	{
		Rx_Pawn(OwnerPawn).bAlwaysRelaxed = bDontAim;
		if (bDontAim)
		{
			Rx_Pawn(OwnerPawn).ResetRelaxStance();
		}
		Rx_Pawn(OwnerPawn).SetAnimSet(WeaponAnimSet, AimProfileName);
	}
}

simulated function DetachFrom( SkeletalMeshComponent MeshCpnt )
{
	super.DetachFrom(MeshCpnt);
	
	if ( Mesh != None) {
		if(MuzzleFlashPSC != None) {
			MuzzleFlashPSC.DeactivateSystem();
		}
		if (ShellEjectPSC != None) {
			Mesh.DetachComponent(ShellEjectPSC);
		}	
	}

	if( Rx_Pawn(Owner) != none ) {
		//`log("Setting DefaultAnimSet");
		Rx_Pawn(Owner).SetAnimSet(DefaultWeaponAnimSet, DefaultAimProfileName );
	}
}

simulated function ShellEjectTimer()
{

	if (ShellEjectPSC != none && (!bShellEjectPSCLoops) )
	{
		ShellEjectPSC.DeactivateSystem();
	}
}

/**
 * Causes the shell eject particle to turn on and setup a time to
 * turn it back off again.
 */
simulated function CauseShellEjection()
{
	local ParticleSystem ShellTemplate;

	if (ShellEjectPSC != none)
	{
		if ( !bShellEjectPSCLoops || !ShellEjectPSC.bIsActive)
		{
			if (Instigator != None && Instigator.FiringMode == 1 && ShellEjectAltPSCTemplate != None)
			{
				ShellTemplate = ShellEjectAltPSCTemplate;
			}
			else
			{
				ShellTemplate = ShellEjectPSCTemplate;
			}
			if (ShellTemplate != ShellEjectPSC.Template)
			{
				ShellEjectPSC.SetTemplate(ShellTemplate);
			}
			
			ShellEjectPSC.ActivateSystem();
		}
	}

	SetTimer(ShellEjectDuration,false,'ShellEjectTimer');
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	local Rx_Weapon weapon;
	
	if ( EffectIsRelevant(Location,false,MaxFireEffectDistance) )
	{
		CauseShellEjection();
	}
	Super.ThirdPersonFireEffects(HitLocation);

	if(Instigator != None && Instigator.Weapon != None) {
		weapon = Rx_Weapon(Instigator.Weapon);
		weapon.ShakeView();
	}
}

simulated function bool EffectIsRelevant(vector SpawnLocation, bool bForceDedicated, optional float VisibleCullDistance=5000.0, optional float HiddenCullDistance=350.0 )
{
	/**
	if(WorldInfo.isPlayingDemo() && owner != None) {
		return super.EffectIsRelevant( owner.location, bForceDedicated, VisibleCullDistance, HiddenCullDistance );
	} else {
		return super.EffectIsRelevant( SpawnLocation, bForceDedicated, VisibleCullDistance, HiddenCullDistance );
	}
	*/
	
	return super.EffectIsRelevant( owner.location, bForceDedicated, VisibleCullDistance, HiddenCullDistance );
}

DefaultProperties
{
	DefaultWeaponAnimSet  = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
	DefaultAimProfileName = Unarmed
	WeaponAnimSet         = none
	bDontAim             = false
	
	ShellEjectPSCTemplate=none
	ShellEjectDuration = 0.1
	ShellEjectSocket = ShellEjectSocket
}