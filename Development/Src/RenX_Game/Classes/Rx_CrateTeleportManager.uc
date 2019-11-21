class Rx_CrateTeleportManager extends Actor
	placeable;

var(TeleportManager) array<Actor> DestinationList;
var(TeleportManager) bool bIsEnabled;

//Crate Modifier
var(CrateProps) SoundCue PickupSound;
var(CrateProps) String PickupMessage;
var(CrateProps) String PickupBroadcastMessage;

function OnToggle(SeqAct_Toggle Action)
{

	if(Action.InputLinks[0].bHasImpulse)
		bIsEnabled = true;

	else if (Action.InputLinks[1].bHasImpulse)
		bIsEnabled = false;

	else
		bIsEnabled = !bIsEnabled;
	
}

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Teleport'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Navigation"
	End Object
	Components.Add(Sprite)

	bIsEnabled = true;
	PickupBroadcastMessage = "`PlayerName` has been beamed up somewhere else!"
	PickupMessage = "You've been translocated away!"
}