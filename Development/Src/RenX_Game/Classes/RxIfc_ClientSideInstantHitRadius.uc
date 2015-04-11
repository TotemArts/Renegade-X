interface RxIfc_ClientSideInstantHitRadius;

struct ClientSideHit {
	var Actor Actor;
	var float Distance;
};

simulated function float CalcRadiusDmgDistance(vector HurtOrigin);

function TakeDamageFromDistance (
	float               GivenDistance,
	Controller			InstigatedBy,
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	bool				bFullDamage,
	Actor               DamageCauser,
	optional float      DamageFalloffExponent=1.f
);

simulated function bool ClientHitIsNotRelevantForServer();