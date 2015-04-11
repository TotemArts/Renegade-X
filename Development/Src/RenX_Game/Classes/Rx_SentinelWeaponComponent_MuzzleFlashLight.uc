//=============================================================================
// Handles the muzzle flash light for a Rx_SentinelWeapon.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelWeaponComponent_MuzzleFlashLight extends UDKExplosionLight;

/** Location of light relative to base socket. */
var() Vector LightOffset;

/**
 * Attaches self to named socket of NewBase.
 */
function Initialize(SkeletalMeshComponent NewBase, name NewSocket)
{
	NewBase.AttachComponentToSocket(self, NewSocket);
	SetTranslation(LightOffset);
}

/**
 * Sets the light to be NewColour for its entire duration.
 */
function SetColour(LinearColor NewColour)
{
	local Color C;
	local int i;

	C = MakeColor(NewColour.R * 255, NewColour.G * 255, NewColour.B * 255, NewColour.A * 255);

	for(i = 0; i < TimeShift.Length; i++)
	{
		TimeShift[i].LightColor = C;
	}
}

/**
 * Starts the light.
 */
function Flash()
{
	ResetLight();
}

defaultproperties
{
	bEnabled=false
}