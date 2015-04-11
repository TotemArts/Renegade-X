class Rx_BuildingAttachment_MCT_TechBuilding extends Rx_BuildingAttachment_MCT;

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser);

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType) 
{
   return false;
}