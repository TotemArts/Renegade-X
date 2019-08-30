class Rx_CapturableMCT_Internals_Kismet extends Rx_Building_TechBuilding_Internals
   notplaceable;

/* We rewrite this because we're going to insert an action. In my opinion it's much easier to tackle this way than using Super.HealDamage()
*/
function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
   local int RealAmount;
   local float Scr;

   if ((Health < HealthMax || Healer.GetTeamNum() != GetTeamNum()) && Amount > 0 && Healer != None ) {
      RealAmount = Min(Amount, HealthMax - Health);

      if (RealAmount > 0) {

         if (Health >= HealthMax && SavedDmg > 0.0f) {
            SavedDmg = FMax(0.0f, SavedDmg - Amount);
            Scr = SavedDmg * HealPointsScale;
            Rx_PRI(Healer.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
         }

         Scr = RealAmount * HealPointsScale;
         Rx_PRI(Healer.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
      }

      if(Healer.GetTeamNum() != GetTeamNum()) {
         Amount = -1 * Amount;
      }
      
      Health = Min(HealthMax, Health + Amount);
      
      if(Health <= 1) {
         Health = 1;   
         if(GetTeamNum() != TEAM_NOD && GetTeamNum() != TEAM_GDI) {
            if(Healer.GetTeamNum() == TEAM_NOD) {   
               `LogRx("GAME"`s "Captured;"`s class'Rx_Game'.static.GetTeamName(TeamID)$","$self.class `s "id" `s GetRightMost(self) `s "by" `s `PlayerLog(Healer.PlayerReplicationInfo) );
               BroadcastLocalizedMessage(MessageClass,NOD_CAPTURED,Healer.PlayerReplicationInfo,,self);
               ChangeTeamReplicate(TEAM_NOD,true);
            } else {
               `LogRx("GAME"`s "Captured;"`s class'Rx_Game'.static.GetTeamName(TeamID)$","$self.class `s "id" `s GetRightMost(self) `s "by" `s `PlayerLog(Healer.PlayerReplicationInfo) );
               BroadcastLocalizedMessage(MessageClass,GDI_CAPTURED,Healer.PlayerReplicationInfo,,self);
               ChangeTeamReplicate(TEAM_GDI,true);
            }


         } else {
            if (TeamID == TEAM_NOD)
               BroadcastLocalizedMessage(MessageClass,NOD_LOST,Healer.PlayerReplicationInfo,,self);
            else if (TeamID == TEAM_GDI)
               BroadcastLocalizedMessage(MessageClass,GDI_LOST,Healer.PlayerReplicationInfo,,self);
            `LogRx("GAME"`s "Neutralized;"`s class'Rx_Game'.static.GetTeamName(TeamID)$","$self.class `s "id" `s GetRightMost(self) `s "by" `s `PlayerLog(Healer.PlayerReplicationInfo) );
            ChangeTeamReplicate(255,true);
            Health = BuildingVisuals.HealthMax;

         }
      }
      else if (Amount < 0)
         TriggerUnderAttack();
                        
                        // We can actually make another event here for the Under Attack event

      return True;
   }

   return False;
}
 

DefaultProperties
{
   TeamID          = 255
}