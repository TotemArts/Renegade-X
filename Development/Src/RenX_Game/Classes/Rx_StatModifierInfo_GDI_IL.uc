class Rx_StatModifierInfo_GDI_IL extends Rx_StatModifierInfo; //Buffs/Debuffs/Special functions


//DEPRECATED

/*Defence for Geeds*/

DefaultProperties
{
//Buff/Debuff modifiers//
SpeedModifier 	= -0.075 //*X

//Weapons
DamageBoostMod 	= 0.0  //*X
RateOfFireMod 	= 0.0 //*X 
ReloadSpeedMod 	= 0.15 //*X

//Survivablity
DamageResistanceMod = 0.20 //0.10 //*X Add a little toughness, cuz we Geeds
RegenerationMod 	= 0.0  //+X

//Modifier stats
Mod_Length = 60.0
ModificationName = "Inspiring Leadership"

EffectColor		= (R=0.0.0,G=2.0,B=1.0,A=1.0)
EffectOpacity	= 0.25
EffectInflation	= 0.33
EffectPriority	= 10

PawnMIC = MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_PowerUp_GDI1'

}