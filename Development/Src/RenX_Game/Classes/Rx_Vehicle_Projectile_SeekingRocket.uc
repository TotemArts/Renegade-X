/*********************************************************
*
* File: Rx_Vehicle_Projectile_SeekingRocket.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
* Class for the overwriting of the explosion method to match up with the system for bullet impact.
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/

class Rx_Vehicle_Projectile_SeekingRocket extends Rx_Projectile_Rocket;


simulated function Explode(vector HitLocation, vector HitNormal)
{
	Super.Explode(HitLocation, HitNormal);
	SetTimer(0.0,false);
}

simulated function float GetBotDamagePercentage()
{
	return BotDamagePercentage;
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	
	if(DamageRadius == 0.0 && TryHeadshot(Other, HitLocation, HitNormal, Damage)) {
		return;
	} else {
		super.ProcessTouch(Other, HitLocation, HitNormal);
	}
}

simulated function bool TryHeadshot(Actor Other, Vector HitLocation, Vector HitNormal, float DamageAmount)
{
	local float Scaling;
	local ImpactInfo Impact;
	
	if (Instigator == None || VSize(Instigator.Velocity) < Instigator.GroundSpeed * Instigator.CrouchedPct)
	{
		Scaling = SlowHeadshotScale;
	}
	else
	{
		Scaling = RunningHeadshotScale;
	}

	DamageAmount *= HeadShotDamageMult;
	
	Impact.HitActor = Other;
	Impact.HitLocation = HitLocation;
	Impact.HitNormal = HitNormal;
	Impact.RayDir = vector(Rotation); 
	
	if( Rx_Pawn(Other) != None )
	{
		UTPawn(Other).Mesh.ForceSkelUpdate();
		CheckHitInfo(Impact.HitInfo, UTPawn(Other).Mesh, Impact.RayDir, Impact.HitLocation);
		return Rx_Pawn(Other).TakeHeadShot(Impact, HeadShotDamageType, DamageAmount, Scaling, InstigatorController, true);
	}
	
	return False;
}


DefaultProperties
{
   ExplosionDecal=none
    
   bWaitForEffects=True
   bAttachExplosionToVehicles=False
// bAttachExplosionToPawns=False    This needs to return
}
