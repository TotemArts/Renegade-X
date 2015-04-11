class Rx_BuildingAttachment_DmgFx extends Rx_BuildingAttachment
	abstract;

`define DMG_LVL_MAX 4
`define DMG_LVL_MIN 0-`DMG_LVL_MAX

var ParticleSystemComponent Particles;

var bool bOn;
var bool bNonLooping;

simulated function Init( Rx_Building_Internals inBuilding, optional name SocketName )
{
	local int lvl;
	super.Init(inBuilding, SocketName);

	if (Rx_Building_Team_Internals(inBuilding) != None)
	{
		lvl = int( Left(Split(SocketName, SocketPattern, true), InStr(Split(SocketName, SocketPattern, true), "_") ) );
		if  (lvl >= `DMG_LVL_MIN && lvl <= `DMG_LVL_MAX)
			Rx_Building_Team_Internals(inBuilding).AddDmgFx(self, lvl);
		else
			`log("DMGFX ERROR -"@self@"("$SocketPattern$") has an invalid damagelevel value");
	}
}

function StartEffects()
{
	Particles.ActivateSystem();
	Particles.LastRenderTime = WorldInfo.TimeSeconds;
}

function StopEffects()
{
	Particles.DeactivateSystem();
	Particles.LastRenderTime = WorldInfo.TimeSeconds;
}

function TurnOn(bool bSkipNonLooping)
{
	if ((bSkipNonLooping && bNonLooping) || bOn)
		return;
	bOn=true;
	StartEffects();
}

function TurnOff()
{
	if (!bOn)
		return;
	bOn=false;
	StopEffects();
}

DefaultProperties
{
	bSpawnOnClient=true

	Begin Object Class=ParticleSystemComponent Name=ParticleComp
		bAutoActivate=false
	End Object
	Components.Add(ParticleComp)
	Particles=ParticleComp

	bNonLooping=false
}
