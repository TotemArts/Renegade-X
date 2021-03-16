class Rx_HUD_VignetteComponent extends Rx_HUD_Component; 

var LinearColor VignetteColour, DamageColour, HealingColour, SpecialColour; //Colours that can be modified in game
var float VignetteAlpha, MinAlpha, DesiredVignetteAlpha; 
var float MaxIntensity, MaxDamageAlpha, MaxHealingAlpha, MaxSpecialAlpha; //Base Intensity is used as a 'zero' point for intensity. It keeps you from having to multiply the intensity of small additions (Like bleed damage) to make them affect the vignette 


var float DamageIntensity, HealingIntensity, SpecialIntensity, AvgIntensity ; //Highest Intensity will be used when it comes time to draw 

var float VignetteFadeSpeed, IntensityFadeSpeed;

var MaterialInstanceConstant VignetteMIC;

var bool bCriticalHealth; 

var bool bUsingSpecial; //Are we using a special vignette?

var float FadeDamageTimer, FadeHealingTimer; //If the vignette should fade now 

function InitMaterial()
{
	VignetteMIC = new(Outer) class'MaterialInstanceConstant';	
	VignetteMIC.SetParent(Material'RenxHUD.Vignettes.M_Camera_Vignette_Blank');
}

function SetDamageColour(float RC, float GC, float BC)
{
	DamageColour.R = RC;
	DamageColour.G = GC;
	DamageColour.B = BC;
}

function SetHealingColour(float RC, float GC, float BC)
{
	HealingColour.R = RC;
	HealingColour.G = GC;
	HealingColour.B = BC;
}

function SetSpecialColour(float RC, float GC, float BC)
{
	SpecialColour.R = RC;
	SpecialColour.G = GC;
	SpecialColour.B = BC;
}

function Update(float DeltaTime, Rx_HUD HUD)
{
	super.Update(DeltaTime, HUD);

	if(HUD != none)
	{
		
		UpdateIntensity(DeltaTime); 
		UpdateVignetteAlpha(DeltaTime);
		
		if(bCriticalHealth)
		{
			DamageColour = default.DamageColour; 
			DamageIntensity = default.DamageIntensity*1.50; 
		}
		
			
		
			//Special (buffs basically) trump everything 
			if(SpecialIntensity > default.SpecialIntensity)
			{
				VignetteColour = SpecialColour;
				DesiredVignetteAlpha = fmin(SpecialIntensity/MaxIntensity, MaxSpecialAlpha);
			}
			else
			if (DamageIntensity > default.DamageIntensity)
			{
				VignetteColour = DamageColour;
				DesiredVignetteAlpha = fmin(DamageIntensity/MaxIntensity, MaxDamageAlpha);
			}
			else if(HealingIntensity > default.HealingIntensity)
			{
				VignetteColour = HealingColour;
				DesiredVignetteAlpha = fmin(HealingIntensity/MaxIntensity, MaxHealingAlpha);
			}
			else
			{
				VignetteColour = default.VignetteColour;
				DesiredVignetteAlpha = 0;
			}
	}
}

function UpdateVignetteAlpha(float DeltaTime)
{
	if(VignetteAlpha > DesiredVignetteAlpha)
	{
		VignetteAlpha = fmin(VignetteAlpha-(VignetteFadeSpeed*DeltaTime), DesiredVignetteAlpha);
	}
	else if(VignetteAlpha < DesiredVignetteAlpha)
	{
		VignetteAlpha = fmax(VignetteAlpha+(VignetteFadeSpeed*DeltaTime), DesiredVignetteAlpha);
	}
}

function UpdateIntensity(float DeltaTime)
{
	if(FadeDamageTimer == 0 && DamageIntensity > default.DamageIntensity)
		DamageIntensity = fmax(default.DamageIntensity, DamageIntensity - IntensityFadeSpeed*DeltaTime);
	
	if(FadeHealingTimer == 0 && HealingIntensity > default.HealingIntensity)
		HealingIntensity = fmax(default.HealingIntensity, HealingIntensity - IntensityFadeSpeed*DeltaTime);
	
	//Works on a simple boolean principle. 
	if(SpecialIntensity > default.SpecialIntensity && !bUsingSpecial)
		SpecialIntensity = fmax(default.SpecialIntensity, SpecialIntensity - IntensityFadeSpeed*DeltaTime);
	
	FadeDamageTimer = FadeDamageTimer > 0.f ? fmax(0.f, FadeDamageTimer - DeltaTime) : 0.f;
	FadeHealingTimer = FadeHealingTimer > 0.f ? fmax(0.f, FadeHealingTimer - DeltaTime) : 0.f; 	
}

function AddDamageIntensity(float Intensity)
{
	DamageIntensity = fmin(DamageIntensity+Intensity, MaxIntensity); 
}

function AddHealIntensity(float Intensity)
{
	HealingIntensity = fmin(HealingIntensity+Intensity, MaxIntensity); 
}

function AddSpecialIntensity(float Intensity)
{
	SpecialIntensity = fmin(SpecialIntensity+Intensity, MaxIntensity); 
}

function Draw()
{
	VignetteColour.A = VignetteAlpha; //Set the alpha right before you draw 
	VignetteMIC.SetVectorParameterValue('VignetteColour', VignetteColour);
	
	Canvas.SetPos(0,0);
	Canvas.DrawMaterialTile(VignetteMIC, Canvas.SizeX, Canvas.SizeY);
}

//Taking a hit takes priority over everything 
function VignetteTakeHit(LinearColor DmgColour, float Intensity)
{
	SetDamageColour(DmgColour.R, DmgColour.G, DmgColour.B);
	AddDamageIntensity(Intensity);
	FadeDamageTimer = 0.1; //Don't immediatly start fading out intensity
}

//Take heals 
function VignetteTakeHeals(LinearColor HealColour, float Intensity)
{
	SetHealingColour(HealColour.R, HealColour.G, HealColour.B);
	AddHealIntensity(Intensity); //Heals are more or less always more consistent than they are burst 
	FadeHealingTimer = 0.1; //Don't immediatly start fading out intensity
}

//Special 
function SetSpecialVignette(bool bUseSpecial, optional LinearColor SpecColour, optional int Intensity)
{
	SetUsingSpecial(bUseSpecial);
	
	if(bUseSpecial)
	{
		SetSpecialColour(SpecColour.R, SpecColour.G, SpecColour.B);
		if(Intensity > SpecialIntensity)
			SpecialIntensity=Intensity;
	}
		
}

function SetUsingSpecial(bool Using)
{
	bUsingSpecial = Using;
}

function SetCritical (bool bSet)
{
	bCriticalHealth = bSet;
}

function Reset()
{
	SetCritical(false);
	SetUsingSpecial(false);
	VignetteAlpha = default.VignetteAlpha; 
	DamageIntensity = default.DamageIntensity;
	HealingIntensity = default.HealingIntensity;
	SpecialIntensity = default.SpecialIntensity;
}

DefaultProperties 
{
	//Linear Colors
	MinAlpha = 0 

	DamageIntensity = 20.0 //Default is slightly higher so it's easier for it to be the most visible 
	HealingIntensity = 10.0
	SpecialIntensity = 1.0
	
	VignetteFadeSpeed = 0.25 //Per second 
	IntensityFadeSpeed = 40
	
	MaxIntensity = 100
	
	MaxDamageAlpha = 1.0 //give even small intensity bursts some visibility 
	MaxHealingAlpha = 0.33 //Healing tends to be always done in very fast, very gradual increments 
	MaxSpecialAlpha = 1.0 //Specials will pretty much always just be one big ass burst 
	
	/*Defaults; changeable by damagetype*/
	DamageColour = (R = 0.33, G = 0.0, B = 0.0, A = 1.0)
	HealingColour = (R = 0.0, G = 0.5, B = 0.5, A = 1.0)
	SpecialColour = (R = 1.0, G = 1.0, B = 1.0, A = 1.0)
}
