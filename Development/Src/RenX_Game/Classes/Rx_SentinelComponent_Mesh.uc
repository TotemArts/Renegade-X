//=============================================================================
// Handles the appearance of a Sentinel component e.g. spawn and death materials.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelComponent_Mesh extends SkeletalMeshComponent
	within Rx_Sentinel;

/** Name of parameter in material that sets emissive colour. */
var() name EmissiveColourParameterName;
/** Saturation of emissive channel colour */
var() float EmissiveSaturation;
/** Lightness of emissive channel colour */
var() float EmissiveLightness;
/** Extra multiplier applied to emissive channel colour to control bloom effect (values > 1.0 result in bloom). */
var() float EmissiveBloom;

/** Material to apply when spawning. */
var() MaterialInterface SpawnMaterial;
/** Material to apply once dead. */
var() MaterialInterface DeadMaterial;

/** Name of spawn effect parameter. */
var() name SpawnMaterialParameterName;
/** Name of spawn material colour parameter. */
var() name SpawnMaterialColourParameterName;
/** Controls spawn effect. */
var() InterpCurveFloat SpawnMaterialParameterCurve;

/** Name of parameter for default material damage effect. */
var() name DamageParamName;
/** Scale for strongest damage effect. */
var() float DamageParamMax;

/** Name of the material parameter that controls visibility. */
var() name VisibilityParamName;

/** Name of burn out effect. */
var() name DeadMaterialParameterName;
/** Controls burn out effect. */
var() InterpCurveFloat DeadMaterialParameterCurve;
/** Maximum force to apply to "gib" when killed. */
var() Vector DeadExplodeForce;
/** Maximum angular velocity of "gib" applied when killed. */
var() float DeadExplodeAngular;
/** If this is true and there is a PhysicsAsset, then this component can be turned into a gib. */
var() bool bCanGib;

/** Name of root bone. */
var() name RootBone;

var MaterialInstanceConstant ComponentMaterialInstance;
var UTGib_Vehicle ComponentGib;

/**
 * Sets colour of emissive channel and any other team-coloured things.
 */
function SetTeamColour()
{
	//local HSLColour HSLTeamColour;
	local LinearColor RGBTeamColour;

	if(ComponentMaterialInstance == none)
	{
		ComponentMaterialInstance = CreateAndSetMaterialInstanceConstant(0);
	}

	//Take hue from team colour, set saturation and lightness, and also bloom.
	//HSLTeamColour = class'Rx_Sentinel_Utils'.static.RGBToHSL(TeamColour);
	//HSLTeamColour.S = EmissiveSaturation;
	//HSLTeamColour.L = EmissiveLightness;
	//HSLTeamColour.Bloom = EmissiveBloom;
	//RGBTeamColour = class'Rx_Sentinel_Utils'.static.HSLToRGB(HSLTeamColour);
	RGBTeamColour = class'Rx_Sentinel_Utils'.static.RENXIFY(TeamColour, EmissiveSaturation, EmissiveLightness, EmissiveBloom);

	ComponentMaterialInstance.SetVectorParameterValue(EmissiveColourParameterName, RGBTeamColour);
}

/**
 * Changes skin to the spawn material and sets it going.
 */
function PlaySpawnEffect()
{
	local MaterialInstanceTimeVarying SpawnMaterialInstance;
	local InterpCurveFloat ParameterCurve;

	if(ComponentMaterialInstance == none)
	{
		ComponentMaterialInstance = CreateAndSetMaterialInstanceConstant(0);
	}
	else if(ComponentMaterialInstance != Materials[0])
	{
		//Material already changed, probably already spawning in.
		return;
	}

	SpawnMaterialInstance = new(self) class'MaterialInstanceTimeVarying';
	SpawnMaterialInstance.SetParent(SpawnMaterial);

	//Adjust curve times to match SpawnInTime.
	ParameterCurve = SpawnMaterialParameterCurve;
	class'Rx_Sentinel_Utils'.static.AdjustCurveTime(ParameterCurve, SpawnInTime);
	SpawnMaterialInstance.SetScalarCurveParameterValue(SpawnMaterialParameterName, ParameterCurve);

	SpawnMaterialInstance.SetVectorParameterValue(SpawnMaterialColourParameterName, TeamColour);
	SetMaterial(0, SpawnMaterialInstance);
	SpawnMaterialInstance.SetScalarStartTime(SpawnMaterialParameterName, 0.0);

	SetTimer(SpawnInTime, false, 'StopSpawnEffect', self);
}

/**
 * Resets skin to normal material.
 */
function StopSpawnEffect()
{
	SetMaterial(0, ComponentMaterialInstance);
	SpawnEffectCompleted();
}

/**
 * Called when spawn effect has finished playing.
 */
delegate SpawnEffectCompleted();

/**
 * Sets damage parameter of skin.
 *
 * @param DamageScale	amount of damage from 0.0 = no damage to 1.0 = maximum damage.
 */
function UpdateDamageEffects(float DamageScale)
{
	if(ComponentMaterialInstance != none)
	{
		ComponentMaterialInstance.SetScalarParameterValue(DamageParamName, DamageScale * DamageParamMax);
	}
}

/**
 * Sets the visibility of the mesh using the material's built-in visibility scalar parameter. Only Material[0] is done like this, other materials are simply set to an invisible material when Visibility < 0.5
 */
function SetVisibility(float Visibility)
{
	local int i;

	if(ComponentMaterialInstance != none)
	{
		ComponentMaterialInstance.SetScalarParameterValue(VisibilityParamName, Visibility);

		//If the mesh uses more than one material, deal with those.
		if(SkeletalMesh.Materials.length > 1)
		{
			for(i = 1; i < SkeletalMesh.Materials.length; i++)
			{
				SetMaterial(i, Visibility < 0.5 ? Material'RX_BU_Refinery.Materials.M_Transparent' : none);
			}
		}
	}
}

/**
 * Attempts to spawn a gib and hide self, to give the impression that the component has been broken off.
 *
 * @param ExplodeDirection	direction to apply force in.
 * @return	true if not visible, either because a gib was spawned succesfully, or because no mesh was assigned in the first place
 */
function bool TurnToGib(Rotator ExplodeDirection)
{
	/*
	local Vector Force;
	
	if(bCanGib && PhysicsAsset != none)
	{
		ComponentGib = Spawn(class'UTGib_Sentinel', Owner,, GetPosition(), Rotation,, true);

		if(ComponentGib != none)
		{
			SetHidden(true);
			SetTraceBlocking(false, false);
			SetActorCollision(false, false);

			ComponentGib.SentinelGibMesh.SetScale(Scale);
			ComponentGib.SentinelGibMesh.SetSkeletalMesh(SkeletalMesh);
			ComponentGib.SentinelGibMesh.SetPhysicsAsset(PhysicsAsset);
			ComponentGib.SentinelGibMesh.SetHasPhysicsAssetInstance(true);
			ComponentGib.TurnOnCollision();

			Force.X = 2.0 * (FRand() - 0.5) * DeadExplodeForce.X;
			Force.Y = 2.0 * (FRand() - 0.5) * DeadExplodeForce.Y;
			Force.Z = FRand() * DeadExplodeForce.Z;
			Force = Force >> ExplodeDirection;
			ComponentGib.SentinelGibMesh.SetRBLinearVelocity(Force, true);
			ComponentGib.SentinelGibMesh.SetRBAngularVelocity(VRand() * DeadExplodeAngular, true);

			ComponentGib.LifeSpan = DeadLifeSpan;
		}
	}
	*/
	return (ComponentGib != none || SkeletalMesh == none);
}

/**
 * Changes skin (or gib's skin, if a gib has been spawned) to the burn-out material, but doesn't set it actually burning yet.
 */
function PlayBurnEffect()
{
	local MaterialInstanceTimeVarying DeadMaterialInstance;
	local InterpCurveFloat ParameterCurve;

	DeadMaterialInstance = new(self) class'MaterialInstanceTimeVarying';
	DeadMaterialInstance.SetParent(DeadMaterial);

	//Adjust curve to match actual burn time.
	ParameterCurve = DeadMaterialParameterCurve;
	class'Rx_Sentinel_Utils'.static.AdjustCurveTime(ParameterCurve, BurnTime);
	DeadMaterialInstance.SetScalarCurveParameterValue(DeadMaterialParameterName, ParameterCurve);

	if(ComponentGib != none)
	{
		ComponentGib.GibMeshComp.SetMaterial(0, DeadMaterialInstance);
	}
	else
	{
		SetMaterial(0, DeadMaterialInstance);
	}
}

/**
 * Sets the burn material burning. Note that PlayBurnEffect must have been called beforehand.
 */
function StartBurn()
{
	if(ComponentGib != none)
	{
		MaterialInstanceTimeVarying(ComponentGib.GibMeshComp.GetMaterial(0)).SetScalarStartTime(DeadMaterialParameterName, 0.0);
	}
	else
	{
		MaterialInstanceTimeVarying(GetMaterial(0)).SetScalarStartTime(DeadMaterialParameterName, 0.0);
	}
}

defaultproperties
{
	EmissiveColourParameterName=Emissive_Colour
	EmissiveSaturation=1.0
	EmissiveLightness=0.52
	EmissiveBloom=6.5

	SpawnMaterialParameterName=ResInAmount
	SpawnMaterialColourParameterName=ResInColour
	SpawnMaterialParameterCurve=(Points=((InVal=0.0,OutVal=0.0),(InVal=1.0,OutVal=1.0)))

	DamageParamName=Damage
	DamageParamMax=2.5

	VisibilityParamName=Visibility

	DeadMaterialParameterName=BurnTime
	DeadMaterialParameterCurve=(Points=((InVal=0.0,OutVal=3.5),(InVal=0.3,OutVal=2.5),(InVal=3.5,OutVal=-0.2)))

	bCanGib=true

	RootBone=Root

	AbsoluteRotation=true
	CollideActors=true
	BlockActors=false
	BlockZeroExtent=true
	BlockNonZeroExtent=true
	BlockRigidBody=false
}