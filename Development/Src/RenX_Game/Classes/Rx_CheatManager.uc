class Rx_CheatManager extends UTCheatManager;

exec function Ghost()
{
	if ( (Pawn != None))
	{
		bCheatFlying = true;
		if(Pawn.CheatGhost())
			Outer.GotoState('PlayerFlying');
		else
			bCheatFlying = false;
	}
	else
	{
		bCollideWorld = false;
	}

	ClientMessage("You feel ethereal");
}

exec function SetSpeed( float F )
{
	local Rx_Pawn RxP;

	RxP = Rx_Pawn(Pawn);

	if(RxP != None)
	{
		RxP.CheatSpeedMult = F;
		RxP.SetGroundSpeed();
	}
	else
		Super.SetSpeed(F);
}

exec function ChangeCharacter( String CharacterClassStr, optional string ModifyPlayer="" )
{
	local PlayerController c;
	local class<Rx_FamilyInfo> CharacterClass;

	if(ModifyPlayer == "")
	{
		`log("ChangeCharacter() Player was empty");
		c = GetALocalPlayerController();
		`log("ChangeCharacter()"@`showvar(c));
	}
	else
	{
		foreach WorldInfo.AllControllers(class'PlayerController', c)
		{
			if(c.PlayerNum == int(ModifyPlayer) || c.PlayerReplicationInfo.PlayerName == ModifyPlayer)
			{
				`log("ChangeCharacter() other player pawn found");
				break;
			}
		}
	}

	CharacterClass = class<Rx_FamilyInfo>(DynamicLoadObject(CharacterClassStr, class'Class'));

	if(CharacterClass != none && UTPlayerController(c) != none)
		Rx_PRI(Rx_Controller(c).PlayerReplicationInfo).SetChar(CharacterClass, c.Pawn, false);
	else
	{
		`log("ChangeCharacter() Missing class or pawn"@`ShowVar(CharacterClassStr)@`ShowVar(CharacterClass)@`ShowVar(c));

	}
}

exec function Bleed(optional int Damage = 1, optional int Duration = 10)
{
	local Rx_Pawn PlayerPawn;
	PlayerPawn = Rx_Pawn(Pawn);
	if (PlayerPawn != None) {
		PlayerPawn.AddBleed(Damage, Duration, GetALocalPlayerController(), class'Rx_DmgType_Burn'.Default.BleedType);
	}
}

exec function Refill()
{
	local Rx_Pawn PlayerPawn;
	PlayerPawn = RX_Pawn(Pawn);
	if (PlayerPawn != None) {
		PlayerPawn.PerformRefill();
	}
}

exec function EchoLog(string text)
{
	`Log(text);
}

exec function ServerListSelection(int index)
{
	Rx_GameViewportClient(class'Engine'.static.GetEngine().GameViewport).FrontEnd.MultiplayerView.ServerList.SetInt("selectedIndex", index);
}

exec function DestroyBuilding(String building, TEAM team)
{
	local Rx_Building b;
	local int dmgLodLevel;

	foreach AllActors(class'Rx_building', b)
	{
		`logd(`showvar(caps(string(b.Class)))@`showvar(caps(building))@`showvar(b.TeamID));

		if(b.TeamID == team && caps(string(b.Class)) == caps(building))
			break;
	}

	`logd(`showvar(b)@`showvar(b.BuildingInternals)@`showvar(Rx_Building_Team_Internals(b.BuildingInternals)));
	Rx_Building_Team_Internals(b.BuildingInternals).Armor = 0;
	Rx_Building_Team_Internals(b.BuildingInternals).Health = 0;	
	Rx_Building_Team_Internals(b.BuildingInternals).bDestroyed = true;
	Rx_Building_Team_Internals(b.BuildingInternals).PlayDestructionAnimation();
	Rx_Game(WorldInfo.Game).CheckBuildingsDestroyed(Rx_Building_Team_Internals(b.BuildingInternals).BuildingVisuals, Rx_Controller(Owner));

	dmgLodLevel = Rx_Building_Team_Internals(b.BuildingInternals).GetBuildingHealthLod();
	if(dmgLodLevel != Rx_Building_Team_Internals(b.BuildingInternals).DamageLodLevel)
	{
		Rx_Building_Team_Internals(b.BuildingInternals).DamageLodLevel = dmgLodLevel;
		Rx_Building_Team_Internals(b.BuildingInternals).ChangeDamageLodLevel(dmgLodLevel);
	}
	Rx_Building_Team_Internals(b.BuildingInternals).OnBuildingDestroyed();

}

DefaultProperties
{
}
