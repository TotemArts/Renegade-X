class Rx_StatModifierInfo_Crate_Defense extends Rx_StatModifierInfo; //Buffs/Debuffs/Special functions

/*Defence for Geeds*/

DefaultProperties
{
	//Buff/Debuff modifiers//
	SpeedModifier 	= -0.075 //*X

	//Weapons
	DamageBoostMod 	= 0.0  //*X
	RateOfFireMod 	= 0.0 //*X 
	ReloadSpeedMod 	= 0.0 //*X

	//Survivablity
	DamageResistanceMod = 0.20 //0.10 //*X
	RegenerationMod 	= 0.0  //+X

	//Modifier stats
	Mod_Length = 300.0 //5 minutes
	ModificationName = "Damage Resistance"

	EffectColor		= (R=0.0,G=0.0,B=1.0,A=1.0)
	EffectOpacity	= 0.15
	EffectInflation	= 0.5
	EffectPriority	= 5

	PawnMIC = MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_PowerUp_DamageResistance'

}