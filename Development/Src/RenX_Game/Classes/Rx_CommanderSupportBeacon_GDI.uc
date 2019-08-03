class Rx_CommanderSupportBeacon_GDI extends Rx_CommanderSupportBeacon;


defaultproperties
{

   Begin Object Name=RadialLight
	LightColor=(R=255,G=255,B=0)
   End Object
   LightComp = RadialLight
   Components.Add(RadialLight)
  
   BeaconParticleEffect=ParticleSystem'rx_fx_envy.Fire.P_Flare_Large_Yellow'
  
}