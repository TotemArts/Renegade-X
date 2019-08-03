class Rx_StatModifierInfo_GDI_OI extends Rx_StatModifierInfo; //Buffs/Debuffs/Special functions

/*Offensive buff*/

DefaultProperties
{
	//Buff/Debuff modifiers//
	SpeedModifier 	= 0.0 //*X

	//Weapons
	DamageBoostMod 	= 0.10 //0.20  //*X GDI has lots of OHKO potential 
	RateOfFireMod 	= 0.20 //*X GDI is not notorious for high ROF weapons
	ReloadSpeedMod 	= 0.20 //0.15 //*X //GDI has high damage high reload times 

	//Survivablity
	DamageResistanceMod = 0.10 //0.10 //*X //GDI units in general are already pretty tough 
	RegenerationMod 	= 2.0  //+X

	//Modifier stats
	Mod_Length = 15.0 //20.0
	ModificationName = "Offensive Initiative"

	EffectColor		= (R=5.0,G=5.0,B=0.0,A=6.0)
	EffectOpacity	= 0.5
	EffectInflation	= 1.0
	EffectPriority	= 0

	PawnMIC = MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_PowerUp_GDI2'

}