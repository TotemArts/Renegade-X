//=============================================================================
// Handles the muzzle flash for a Rx_SentinelWeapon. Initialize() should be called
// before using this. Call Flash() to turn it on, then it will automatically
// turn itself off again after a time.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelWeaponComponent_MuzzleFlash extends ParticleSystemComponent;

/** Time to keep muzzle flash active. */
var() float MuzzleFlashDuration;
/** If true, muzzle flash emitter will be activated only once when firing starts then allowed to loop until firing stops. If false, it will be reset every shot. */
var() bool bConstantFlash;
/** Location of muzzle flash relative to base socket. */
var() Vector MuzzleFlashOffset;
/** Name of colour parameter of Template. */
var() name MuzzleFlashColourName;
/** Set to false to stop Flash() from enabling the PSC. */
var() bool bShouldFlash;

/**
 * Attaches self to named socket of NewBase.
 */
function Initialize(SkeletalMeshComponent NewBase, name NewSocket)
{
	NewBase.AttachComponentToSocket(self, NewSocket);
	SetTranslation(MuzzleFlashOffset);
}

/**
 * Sets MuzzleFlashColourName parameter to NewColour.
 */
function SetColour(LinearColor NewColour)
{
	SetColorParameter(MuzzleFlashColourName, MakeColor(NewColour.R * 255, NewColour.G * 255, NewColour.B * 255, NewColour.A * 255));
}

/**
 * Turns muzzle flash on, automatically turning it off after MuzzleFlashDuration.
 */
function Flash()
{
	if(bShouldFlash)
	{
		if(bConstantFlash)
		{
			SetActive(true);
		}
		else
		{
			ActivateSystem();
		}

		if(MuzzleFlashDuration > 0.0)
		{
			if(Owner != None) {
				Owner.SetTimer(MuzzleFlashDuration, false, 'FlashOff', self);
			}
		}
	}
}

/**
 * Turns muzzle flash off.
 */
function FlashOff()
{
	DeactivateSystem();
}

defaultproperties
{
	MuzzleFlashColourName=MuzzleFlashColor
	bShouldFlash=true
	bAutoActivate=false
}