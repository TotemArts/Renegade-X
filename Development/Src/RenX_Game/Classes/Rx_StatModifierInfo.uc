class Rx_StatModifierInfo extends Object; //Buffs/Debuffs/Special functions

//Buff/Debuff modifiers//

var float SpeedModifier; 

//Weapons
var float DamageBoostMod; 
var float RateOfFireMod;
var float ReloadSpeedMod;

//Survivablity
var float DamageResistanceMod;
var float RegenerationMod;

//Other vars
var float Mod_Length; //Length of time to modify stats 
var string ModificationName; 

var LinearColor EffectColor;
var float		EffectOpacity;
var float		EffectInflation; 
var byte		EffectPriority; //Lower is higher priority 

var MaterialInstanceConstant PawnMIC; //MIC to use for infantry pawns affected by this. Vehicles use a different overlay system

//static function ProcessSpecial(); //Processed if it contains anything

static function bool bAffectsWeapons() //Should this modify what our weapon looks like? 
{
	return default.DamageBoostMod != 0 || default.RateOfFireMod != 0 || default.ReloadSpeedMod != 0 ;
}

DefaultProperties
{
//Buff/Debuff modifiers//
SpeedModifier 	= 0.0 //*X Higher = spood beast

//Weapons
DamageBoostMod 	= 0.0  //*X Higher is faster
RateOfFireMod 	= 0.0 //*X Higher = faster
ReloadSpeedMod 	= 0.0 //*X Higher is faster

//Survivablity
DamageResistanceMod = 0.0 //*X (Yes, higher is MORE damage resistance)
RegenerationMod 	= 0.0  //+X

//Modifier stats
Mod_Length = 60.0
ModificationName = "Default Name"

EffectColor		= (R=1.0,G=1.0,B=1.0,A=10.0)
EffectOpacity	= 1.0
EffectInflation	= 1.0
EffectPriority	= 255

PawnMIC = MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_PowerUp_Main'
}