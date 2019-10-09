class Rx_StatModifierInfo_Kamikaze extends Rx_StatModifierInfo; //Buffs/Debuffs/Special functions

/*No... Islamic..... slur jokes.... I promise*/

static function bool bAffectsWeapons() //Should this modify what our weapon looks like? 
{
	return true;
}

DefaultProperties
{
	//Buff/Debuff modifiers//
	SpeedModifier 	= 0.10 //-0.10 //*X

	//Weapons
	DamageBoostMod 	= 0.0  //*X
	RateOfFireMod 	= 0.00
	ReloadSpeedMod 	= 0.0 

	//Survivablity
	DamageResistanceMod = -0.33 //0.10 //Justification: Super Man Tanks... that is all
	RegenerationMod 	= 0.0  // Unused as of this comment

	//Modifier stats
	Mod_Length = 10.0 //20.0
	ModificationName = "KAMIKAZE"

	EffectColor		= (R=1.0,G=0.0,B=5.0,A=1.0)
	EffectOpacity	= 0.8
	EffectInflation	= 0.7
	EffectPriority	= 1 //Looks similar enough to PTP

	PawnMIC = MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_PowerUp_Nod2'
}