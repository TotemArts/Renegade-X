/*********************************************************
*
* File: RxVolume_Tiberium.uc
* Author: RenegadeX-Team
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*   Damages player, not vehicles, with 
*   tiberium damage when they enter the volume
*
* ConfigFile: 
*
*********************************************************
*  by halo2pac 1/08/2012
*********************************************************/

class Rx_Volume_Tiberium extends PhysicsVolume;

var() Rx_Tib_NavigationPoint TibNavPoint;

replication
{
	if (bNetInitial)
		TibNavPoint;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	SetTimer(1.0f, true, 'DamageTick');
}

function DamageTick()
{
	local Actor A;

	ForEach TouchingActors(class'Actor', A)
	{
		if ( A.bCanBeDamaged && !A.bStatic )
		{
			if (Rx_Vehicle(A) == None)
				CausePainTo2(A);
		}
	}
}

function CausePainTo2(Actor Other)
{
	if (DamagePerSec > 0)
	{
		if ( WorldInfo.bSoftKillZ && (Other.Physics != PHYS_Walking) )
			return;
			
		if ( (DamageType == None) || (DamageType == class'DamageType') )
			`log("No valid damagetype ("$DamageType$") specified for "$PathName(self));
			
		Other.TakeDamage(DamagePerSec*PainInterval, DamageInstigator, Location, vect(0,0,1), DamageType,, self);
	}
	else
	{
		Other.HealDamage(-DamagePerSec * PainInterval, DamageInstigator, DamageType);
	}
}



DefaultProperties
{
	DamageType=class'Rx_DmgType_Tiberium'
	
	bEntryPain				= false
	
	//if you change this the super's timer will run
	// WE DO NOT WANT THAT TO HAPPEN.
	bPainCausing			= false
	
	bAIShouldIgnorePain		= false
	DamagePerSec			= 10 // FIXME::
	PainInterval			= 0.5f // FIXME::
	bDestructive			= false
	
	//Apparently these two variables are needed to cause it not to error.
	bStatic					= false
	bNoDelete				= true
}