class Rx_Barrel extends Actor hidecategories(Attachment, Physics, Debug, Mobile, Object, Movement, Display, Advanced, Collision);
var int BarrelHealth;
var(RenegadeX) bool EnableRespawn;
var(RenegadeX) float RespawnTime;
var SoundCue SoundCue1;

function PostBeginPlay()
{


}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation,
vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo,
optional Actor DamageCauser)
{
 if (DamageType == class'Rx_DmgType_Pistol' || DamageType == class'Rx_DmgType_TacticalRifle' ||
 DamageType == class'Rx_DmgType_AutoRifle')
 {
     BarrelHealth--;
 }

 else
 {
     DestroyBarrel();

 }

    if(BarrelHealth==0)
    FullRespawn();
}

function FullRespawn()
{

if(EnableRespawn==true)
{
    Boom();
    DespawnBarrel();
    SetTimer(RespawnTime, false,'SpawnBarrel');
}
else
{
    Boom();
    self.Destroy();
}
}

function DespawnBarrel()
{
    self.SetHidden(true);
    self.SetCollision(false,false);


}
function SpawnBarrel()
{
    RestoreHealth();
    self.SetHidden(false);
    self.SetCollision(true,true);

}


function Boom()
{
    `log("Function boom===========================");
     WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium_Air', Location, Rotation);
     PlaySound(SoundCue1);
}

function DestroyBarrel()
{
do
{
    BarrelHealth--;

} until (BarrelHealth==0);
if(BarrelHealth==0)
FullRespawn();

}

function RestoreHealth()
{
BarrelHealth=5;
}


defaultproperties
{
    SoundCue1 = SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Medium_2'
    RespawnTime=30.0
    EnableRespawn=true
    BarrelHealth=5
    bAlwaysRelevant=true
    bCollideActors=true
    bBlockActors=true
    
    Begin Object Class=DynamicLightEnvironmentComponent         Name=MyLightEnvironment
    bEnabled=true
    End Object
    Components.Add(MyLightEnvironment)

        Begin Object Class=StaticMeshComponent Name=ExplodingBarrel
        StaticMesh=StaticMesh'RX_Deco_Containers.Meshes.SM_Barrel_01'
        //Materials(0)=Material'EditorMaterials.WidgetMaterial_Z'
        //Scale3D=(X=1,Y=1,Z=1)
        End Object
        Components.Add(ExplodingBarrel)

}