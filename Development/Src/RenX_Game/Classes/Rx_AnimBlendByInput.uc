/*********************************************************
*
* File: Rx_AnimBlendByDriving.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/

class Rx_AnimBlendByInput extends UDKAnimBlendBase;


event TickAnim(FLOAT DeltaSeconds)
{
	local Rx_Vehicle titan;

	if(SkelComponent.Owner != None) 
	{
		titan = Rx_Vehicle(SkelComponent.Owner);

		if(titan.Throttle == 0.0 && titan.Steering == 0.0)
		{
			SetActiveChild(1, 5.0);
		} else 
		{
			SetActiveChild(0, 0.0);
		}
	}
	

}


defaultproperties
{
	Children(0)=(Name="In")
	Children(1)=(Name="Inactive")
	bFixNumChildren=true
	bTickAnimInScript = true
}
