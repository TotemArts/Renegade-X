class Rx_StatModifierInfo_Nod_Stealth extends Rx_StatModifierInfo; //Buffs/Debuffs/Special functions

/*Dummy stat modifier for stealth. Possibly add speed buff at some point*/

static function bool bAffectsWeapons() //Should this modify what our weapon looks like? 
{
	return true; 
}

DefaultProperties
{
	//Buff/Debuff modifiers//
	SpeedModifier 	= 0.0 //-0.10 //*X

	//Weapons
	DamageBoostMod 	= 0.0  //*X
	RateOfFireMod 	= 0.0 // Justification: Nod infantry are mostly high ROF laser weapons  
	ReloadSpeedMod 	= 0.0 //*X //Justification: Nod Infantry do not have many high damage/shot weapons on their unique infantry

	//Survivablity
	DamageResistanceMod = 0.0 //0.10 //Justification: Super Man Tanks... that is all
	RegenerationMod 	= 0.0  // Unused as of this comment

	//Modifier stats
	Mod_Length = 60.0 //20.0
	ModificationName = "Lazarus Shield"

	EffectColor		= (R=0.05,G=0.0,B=5.0,A=1.0)
	EffectOpacity	= 0.2
	EffectInflation	= 0.33
	EffectPriority	= 0 //S

	PawnMIC = MaterialInstanceConstant'RX_CH_Nod_SBH.Material.MI_SBH_Cloak_Enemy'
}