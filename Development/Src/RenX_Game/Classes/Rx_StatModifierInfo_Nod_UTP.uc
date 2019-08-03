class Rx_StatModifierInfo_Nod_UTP extends Rx_StatModifierInfo; //Buffs/Debuffs/Special functions

/* Defensive Buff for Nod; Focuses slightly more on things that make their infantry tougher*/

DefaultProperties
{
	//Buff/Debuff modifiers//
	SpeedModifier 	= 0.0 //-0.10 //*X

	//Weapons
	DamageBoostMod 	= 0.0  //*X
	RateOfFireMod 	= 0.0 // Justification: Nod infantry are mostly high ROF laser weapons  
	ReloadSpeedMod 	= 0.0 //*X //Justification: Nod Infantry do not have many high damage/shot weapons on their unique infantry

	//Survivablity
	DamageResistanceMod = 0.375 //0.10 //Justification: Super Man Tanks... that is all
	RegenerationMod 	= 2.0  // Unused as of this comment

	//Modifier stats
	Mod_Length = 15.0 //20.0
	ModificationName = "Unity Through Peace"

	EffectColor		= (R=0.05,G=0.0,B=5.0,A=1.0)
	EffectOpacity	= 0.2
	EffectInflation	= 0.33
	EffectPriority	= 2

	PawnMIC = MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_PowerUp_Nod1'
}