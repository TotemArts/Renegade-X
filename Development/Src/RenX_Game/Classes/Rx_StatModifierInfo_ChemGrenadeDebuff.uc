class Rx_StatModifierInfo_ChemGrenadeDebuff extends Rx_StatModifierInfo; //Buffs/Debuffs/Special functions

/*Defence for Geeds*/

DefaultProperties
{
	//Buff/Debuff modifiers//
	SpeedModifier 	= -0.15 //*X

	//Weapons
	DamageBoostMod 	= 0.0  //*X
	RateOfFireMod 	= 0.0 //*X 
	ReloadSpeedMod 	= -0.15 //*X

	//Survivablity
	DamageResistanceMod = 0.0 //Corrode 
	RegenerationMod 	= 0.0  //+X

	//Modifier stats
	Mod_Length = 6.0
	ModificationName = "Corrosion"

	EffectColor		= (R=0.0.0,G=0.025,B=0.0,A=1.0)
	EffectOpacity	= 0.10
	EffectInflation	= 0.25
	EffectPriority	= 5

	PawnMIC = MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_PowerUp_Poisoned'
}