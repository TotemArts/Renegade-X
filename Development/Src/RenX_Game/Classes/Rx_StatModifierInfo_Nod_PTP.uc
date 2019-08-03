class Rx_StatModifierInfo_Nod_PTP extends Rx_StatModifierInfo; //Buffs/Debuffs/Special functions

/*Offensive buff for Nod*/

DefaultProperties
{
	//Buff/Debuff modifiers//
	SpeedModifier 	= 0.125 //0.075 //*X Shpeed SHPEED, SHPEEEEEED! 

	//Weapons
	DamageBoostMod 	= 0.10 //0.20  //*X Some Power
	RateOfFireMod 	= 0.20 //0.15 //*X Some ROF cuz Nod eats it up (E.G Flame Tanks/LCGs) 
	ReloadSpeedMod 	= 0.20 //*X

	//Survivablity
	DamageResistanceMod = 0.0 //0.10 //*X Not built to be resilient 
	RegenerationMod 	= 2.0  //+X

	//Modifier stats
	Mod_Length = 15.0 //20.0
	ModificationName = "Peace Through Power"

	EffectColor		= (R=1.0,G=0.0,B=0.0,A=3.0)
	EffectOpacity	= 1.0
	EffectInflation	= 0.75
	EffectPriority	= 1

	PawnMIC = MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_PowerUp_Nod2'

}