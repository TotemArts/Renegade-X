class Rx_Building_PowerPlant_Internals extends Rx_Building_Team_Internals;


event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) {

	local Rx_Building_Team_Internals building;

	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	if(GetHealth() <= 0) {
		foreach AllActors(class'Rx_Building_Team_Internals', building) {

			if(TeamID != building.TeamID)
				continue;
			else
				building.PowerLost();
		}
	}
}

DefaultProperties
{

	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh = SkeletalMesh'RX_BU_PowerPlant.Mesh.SK_BU_PowerPlant'
		PhysicsAsset = PhysicsAsset'RX_BU_PowerPlant.Mesh.SK_BU_PowerPlant_Physics'
	End Object

}
