class Rx_Defence_GuardTowerController extends Rx_Defence_Controller;

state Engaged
{
   ignores SeePlayer;
   
   function EnemyNotVisible()
   {
      if ( IsTargetRelevant( Enemy ) )
      {
         Pawn.StopFire(0);
         GotoState('WaitForTarget');
         return;
      }
   }

	function BeginState(Name PreviousStateName)
	{
    	Focus = Enemy;
    	Pawn.BotFire(false);
	}
	
   function EndState(Name NextStateName)
   {
      Pawn.StopFire(0);
   }


Begin:
   Sleep(1.2);
   if ( !IsTargetRelevant( Enemy ))
      GotoState('Searching');
      
   Focus = Enemy;
   Goto('Begin');
}

function Rotator GetAdjustedAimFor( Weapon W, vector StartFireLoc )
{
	local rotator rot;
	local Vector AimSpot;
	rot = super.GetAdjustedAimFor(W,StartFireLoc);
	
	if(AimAhead > 0.0 && Enemy != None && Focus != None && IsInState('Engaged')) {
		FindAimToHit(Focus, StartFireLoc, AimSpot, AimAheadAimRotation);
		SetFocalPoint(AimSpot);
	}	
	if(AimAheadAimRotation != rot(0,0,0)) {
		rot = AimAheadAimRotation;
	}
	return rot;
}

function float GetPredictionTime(vector AimSpot, Vector Origin) {
	return class'Rx_Defence_GuardTower_Projectile'.static.StaticGetTimeToLocation(AimSpot, Origin, Self);
}

function float GetWaitForTargetTime()
{
	return (2 + 5 * FRand());
}

defaultproperties
{
	RotationRate=(Pitch=32768,Yaw=60000,Roll=0)
}