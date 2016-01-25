class Rx_Building_TechBuilding_Internals extends Rx_Building_Team_Internals
	notplaceable
	implements(RxIfc_Capturable);

// The way the sound arrays are setup did not consider changing ownership. I ain't going to rip out the system and replace it, so I'll just use the shit that's there and be efficent at memory usage seeing as I can't do anything else :D
const GDI_CAPTURED = 1;
const NOD_CAPTURED = 2;
const GDI_LOST = 3;
const NOD_LOST = 4;
const GDI_UNDERATTACK = 5;
const NOD_UNDERATTACK = 6;

`define GdiCapSound	FriendlyBuildingSounds[BuildingRepaired]
`define GdiLostSound	FriendlyBuildingSounds[BuildingDestroyed]
`define NodCapSound	EnemyBuildingSounds[BuildingRepaired]
`define NodLostSound	EnemyBuildingSounds[BuildingDestroyed]
`define GdiUnderAttackForGdiSound FriendlyBuildingSounds[BuildingUnderAttack]
`define GdiUnderAttackForNodSound FriendlyBuildingSounds[BuildingDestructionImminent]
`define NodUnderAttackForGdiSound EnemyBuildingSounds[BuildingUnderAttack]
`define NodUnderAttackForNodSound EnemyBuildingSounds[BuildingDestructionImminent]

var TEAM ReplicatedTeamID;
var repnotify TEAM FlagTeam;
var MaterialInstanceConstant MICFlag;

var Rx_CapturePoint_TechBuilding CP;

var float LastUnderAttackAnnouncement;
var float UnderAttackAnnouncementCooldown;

replication
{
	if(bNetDirty || bNetInitial)
		ReplicatedTeamID,FlagTeam,CP;
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'FlagTeam' ) 
		FlagChanged();
	else
		super.ReplicatedEvent(VarName);
}

simulated function Init(Rx_Building Visuals, bool isDebug )
{
	super.Init(Visuals, isDebug);
	//SetupCapturePoint();
	MICFlag = BuildingSkeleton.CreateAndSetMaterialInstanceConstant(0);
	FlagChanged();
	Armor=0;
}


simulated function int GetTrueMaxHealth() 
{
	return HealthMax; 
}


simulated function FlagChanged() 
{
 	if(FlagTeam == TEAM_NOD)
 		MICFlag.SetScalarParameterValue('FlagTeamNum', 1);
 	else if(FlagTeam == TEAM_GDI)
 		MICFlag.SetScalarParameterValue('FlagTeamNum', 0);
 	else
 		MICFlag.SetScalarParameterValue('FlagTeamNum', 2);	
}

function ChangeFlag(TEAM ToTeam)
{
	FlagTeam = ToTeam;
	FlagChanged();
}

function SetupCapturePoint()
{
   local Vector L;
   local Rotator R;

   BuildingSkeleton.GetSocketWorldLocationAndRotation('CapturePoint', L, R);
   CP = Spawn(class'Rx_CapturePoint_TechBuilding',self,,L,R);
}

function ChangeTeamReplicate(TEAM ToTeam, optional bool bChangeFlag=false)
{
	TeamID = ToTeam;
	ReplicatedTeamID = ToTeam;
	if (bChangeFlag)
		ChangeFlag(ToTeam);
}

// damage is ignored, can only be captured through the MCT
function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser);

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
		return True;
	}

	return False;
}

function TriggerUnderAttack()
{
	if (WorldInfo.TimeSeconds < LastUnderAttackAnnouncement + UnderAttackAnnouncementCooldown)
		return;

	if (TeamID == TEAM_GDI)
		BroadcastLocalizedMessage(MessageClass,GDI_UNDERATTACK,,,self);
	else if (TeamID == TEAM_Nod)
		BroadcastLocalizedMessage(MessageClass,NOD_UNDERATTACK,,,self);

	LastUnderAttackAnnouncement = WorldInfo.TimeSeconds;
}

function NotifyBeginCaptureBy(byte TeamIndex)
{
	if (TeamIndex == TEAM_GDI)
	{
		ChangeFlag(TEAM_GDI);
	}
	else if (TeamIndex == TEAM_Nod)
	{
		ChangeFlag(TEAM_Nod);
	}
}

function NotifyCapturedBy(byte TeamIndex)
{
	`LogRx("GAME"`s "Captured;" `s class'Rx_Game'.static.GetTeamName(TeamID)$","$self.class `s "id" `s GetRightMost(self) `s"by"`s class'Rx_Game'.static.GetTeamName(TeamIndex) );
	if (TeamIndex == TEAM_GDI)
		BroadcastLocalizedMessage(MessageClass,GDI_CAPTURED,,,self);
	else
		BroadcastLocalizedMessage(MessageClass,NOD_CAPTURED,,,self);

	if (TeamIndex == TEAM_GDI)
		ChangeTeamReplicate(TEAM_GDI);
	else if (TeamIndex == TEAM_Nod)
		ChangeTeamReplicate(TEAM_Nod);
}

function NotifyBeginNeutralizeBy(byte TeamIndex)
{
	TriggerUnderAttack();
}

function NotifyNeutralizedBy(byte TeamIndex, byte PreviousOwner)
{
	`LogRx("GAME"`s "Neutralized;"`s class'Rx_Game'.static.GetTeamName(TeamID)$","$self.class `s "id" `s GetRightMost(self) `s "by" `s class'Rx_Game'.static.GetTeamName(TeamIndex) );
	if (TeamID == TEAM_GDI)
		BroadcastLocalizedMessage(MessageClass,GDI_LOST,,,self);
	else
		BroadcastLocalizedMessage(MessageClass,NOD_LOST,,,self);

	ChangeTeamReplicate(255);
	if (TeamIndex == TEAM_GDI)
		ChangeFlag(TEAM_GDI);
	else if (TeamIndex == TEAM_Nod)
		ChangeFlag(TEAM_Nod);
}

function NotifyRestoredNeutral()
{
	ChangeFlag(255);
}

function NotifyRestoredCaptured();


simulated function SoundNodeWave GetAnnouncment(int alarm, int teamNum )
{
	switch ( alarm )
	{
	case GDI_CAPTURED:
		if (teamNum == TEAM_GDI)
			return `GdiCapSound;
		break;
	case NOD_CAPTURED:
		if (teamNum == TEAM_Nod)
			return `NodCapSound;
		break;
	case GDI_LOST:
		if (teamNum == TEAM_GDI)
			return `GdiLostSound;
		break;
	case NOD_LOST:
		if (teamNum == TEAM_Nod)
			return `NodLostSound;
		break;
	case GDI_UNDERATTACK:
		if (teamNum == TEAM_Nod)
			return `GdiUnderAttackForNodSound;
		else
			return `GdiUnderAttackForGDISound;
	case NOD_UNDERATTACK:
		if (teamNum == TEAM_Nod)
			return `NodUnderAttackForNodSound;
		else
			return `NodUnderAttackForGDISound;
	}
	return None;
}

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	local string str;
	
	if (RelatedPRI_1 != None)
	{
		switch (Switch)
		{
		case GDI_CAPTURED:
		case NOD_CAPTURED:
			str = Repl(class'Rx_Message_Buildings'.default.BuildingBroadcastMessages[2], "`PlayerName`", RelatedPRI_1.PlayerName);
			return Repl(str, "`BuildingName`", default.BuildingName);
		case GDI_LOST:
		case NOD_LOST:
			str = Repl(class'Rx_Message_Buildings'.default.BuildingBroadcastMessages[3], "`PlayerName`", RelatedPRI_1.PlayerName);
			return Repl(str, "`BuildingName`", default.BuildingName);
		}
	}
	else
	{
		switch (Switch)
		{
		case GDI_CAPTURED:
			str = Repl(class'Rx_Message_Buildings'.default.BuildingBroadcastMessages[2], "`PlayerName`", "GDI");
			return Repl(str, "`BuildingName`", default.BuildingName);
		case NOD_CAPTURED:
			str = Repl(class'Rx_Message_Buildings'.default.BuildingBroadcastMessages[2], "`PlayerName`", "Nod");
			return Repl(str, "`BuildingName`", default.BuildingName);
		case GDI_LOST:
			str = Repl(class'Rx_Message_Buildings'.default.BuildingBroadcastMessages[3], "`PlayerName`", "Nod");
			return Repl(str, "`BuildingName`", default.BuildingName);
		case NOD_LOST:
			str = Repl(class'Rx_Message_Buildings'.default.BuildingBroadcastMessages[3], "`PlayerName`", "GDI");
			return Repl(str, "`BuildingName`", default.BuildingName);
		}
	}
	return "";
}

DefaultProperties
{
	MessageClass=class'Rx_Message_TechBuilding'

	`GdiCapSound	= SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_TechBuilding_Captured'
	`GdiLostSound	= SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_TechBuilding_Lost'

	`NodCapSound	= SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_TechBuilding_Captured'
	`NodLostSound	= SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_TechBuilding_Lost'

	
	`GdiUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_GDITech_UnderAttack'
	`GdiUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_GDITech_UnderAttack'

	`NodUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_NodTech_UnderAttack'
	`NodUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_NodTech_UnderAttack'
	
	/**`GdiUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDISilo_UnderAttack'
	`GdiUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDISilo_UnderAttack'

	`NodUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodSilo_UnderAttack'
	`NodUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodSilo_UnderAttack'
	*/
	//AttachmentClasses.Remove(Rx_BuildingAttachment_MCT)
	//AttachmentClasses.Add(Rx_BuildingAttachment_MCT_TechBuilding)

	ReplicatedTeamID=255
	FlagTeam=255

	UnderAttackAnnouncementCooldown = 15
}
