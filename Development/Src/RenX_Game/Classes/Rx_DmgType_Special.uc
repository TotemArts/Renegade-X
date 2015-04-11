class Rx_DmgType_Special extends Rx_DmgType
	abstract;

var bool bPiercesArmor;
var bool bCausesBleed;
var class<DamageType> BleedType;
var float BleedDamageFactor;
var int BleedCount;

DefaultProperties
{
	bPiercesArmor=false
	bCausesBleed=false
	BleedDamageFactor=0.10
	BleedCount=5
}
