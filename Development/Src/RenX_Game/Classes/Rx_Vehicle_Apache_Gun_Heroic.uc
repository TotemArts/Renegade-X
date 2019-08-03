class Rx_Vehicle_Apache_Gun_Heroic extends Rx_Vehicle_Apache_Gun;

simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
    Super.SetExplosionEffectParameters(ProjExplosion);

    ProjExplosion.SetScale(2.1f); //(0.5f);
}

DefaultProperties
{    
    
    MyDamageType=Class'RenX_Game.Rx_DmgType_Apache_Gun'
    DrawScale= 2.5
}
