class Rx_RangeDummyFactory extends Actor
placeable;

var() class<Rx_RangeDummy_NoArmour>	DummyClass; 
var	  Rx_RangeDummy_NoArmour		MyDummy;

simulated function PostBeginPlay()
{  
	MyDummy = Spawn(DummyClass, self); 
	SetTimer(1.0, true, 'DummyCheckRespawnTimer'); 
}

simulated function Rx_RangeDummy_NoArmour SpawnDummy()
{
	return Spawn(DummyClass, self); 
}

simulated function DummyCheckRespawnTimer()
{
	if(MyDummy == none) 
		MyDummy = Spawn(DummyClass, self);
		MyDummy.TeamIndex = 255; 
}

DefaultProperties
{
	DummyClass=class'Rx_RangeDummy_NoArmour'
	
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_NavP'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Navigation"
	End Object
	Components.Add(Sprite)
} 