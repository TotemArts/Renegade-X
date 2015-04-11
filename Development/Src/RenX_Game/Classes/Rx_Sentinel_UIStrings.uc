//=============================================================================
// Exists purely because localization files are not pushed by servers.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_Sentinel_UIStrings extends Object
	abstract;

var string MenuTitle;
var string AvailableWeapons;
var string CurrentWeapon;
var string AvailableUpgrades;
var string CurrentUpgrades;
var string Description;
var string AvailableComponents;
var string Status;
var string Cost;
var string InvalidUpgrade;
var string NoUpgrade;
var string NoDescription;
var string Recycle;
var string RecycleConfimMessage;
var string Lock;
var string Unlock;
var string Configure;
var string SentinelClass;
var string Owner;
var string Condition;
var string Target;
var string Armour;
var string Shield;
var string Peers;
var string Scanning;
var string UID;

//Mutator config menu strings.
var string MainTabTitle;
var string AllowUpgrades;
var string MaxSentinels;
var string MaxTeamSentinels;
var string MaxTeamAdvantageSentinels;

var string RandomAmmoTabTitle;
var string SpawnRandomAmmo;
var string InitialAmmo;
var string AmmoPerPlayer;

var string AmmoReplacementTabTitle;
var string ReplacedPickups;
var string ReplacementClasses;
var string ReplacementPercent;

var string AdvancedTabTitle;
var string StartWithDeployer;
var string OverrideMapSettings;

//Upgrade strings.
var string ShellTypes;
var string Elevation;

defaultproperties
{
	MenuTitle="Sentinel Upgrade Menu"
	AvailableWeapons="Available Weapons"
	CurrentWeapon="CurrentWeapon"
	AvailableUpgrades="Available Upgrades"
	CurrentUpgrades="Current Upgrades"
	Description="Description"
	AvailableComponents="Available Components"
	Status="Sentinel Status"
	Cost="Cost"
	InvalidUpgrade="Error, invalid upgrade."
	NoUpgrade="No upgrade selected."
	NoDescription="No description available."
	Recycle="RECYCLE"
	RecycleConfimMessage="Are you sure you want to break up this Sentinel for spare parts?"
	Lock="LOCK"
	Unlock="UNLOCK"
	Configure="CONFIGURE"
	SentinelClass="Class"
	Owner="Owner"
	Condition="Condition"
	Target="Target"
	Armour="Armour"
	Shield="Shield"
	Peers="Network Peers"
	Scanning="Scanning..."
	UID="UID"

	MainTabTitle="Main"
	AllowUpgrades="Allow Upgrades"
	MaxSentinels="Max. Sentinels Per Player"
	MaxTeamSentinels="Max. Sentinels Per Team"
	MaxTeamAdvantageSentinels="Max. Difference In Deployed Sentinels Per Team"

	RandomAmmoTabTitle="Random Ammo"
	SpawnRandomAmmo="Spawn Random Ammo"
	InitialAmmo="Initial Spawned Ammo"
	AmmoPerPlayer="Extra Ammo Spawned Per Player"

	AmmoReplacementTabTitle="Ammo Replacement"
	ReplacedPickups="Replaceable Pickups"
	ReplacementClasses="Replacement Ammo Size"
	ReplacementPercent="Percent Replaced"

	AdvancedTabTitle="Advanced"
	StartWithDeployer="Start With Deployer"
	OverrideMapSettings="Override Map Settings"

	ShellTypes="Shell Types"
	Elevation="Elevation"
}