class Rx_CommandMenuChoice_SupportPowers_Coop extends Rx_CommandMenuChoice_SupportPowers;

DefaultProperties
{
	GDI_SP(0) = (Title = "Smoke Screen", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_SmokeDrop', CPCost = 200) 
	GDI_SP(1) = (Title = "EMP Strike", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_EMPMissile', CPCost = 500)
	GDI_SP(2) = (Title = "Cruise Missile", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_CruiseMissile', CPCost = 800)
	GDI_SP(3) = (Title = "Call Reinforcement", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_Reinforcement', CPCost = 800)
	GDI_SP(4) = (Title = "Defensive Initiative", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_Buff_GDI_DI', CPCost = 1200)
	GDI_SP(5) = (Title = "Offensive Initiative", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_Buff_GDI_OI', CPCost = 1400)

	Nod_SP(0) = (Title = "Smoke Screen", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_SmokeDrop', CPCost = 200) 
	Nod_SP(1) = (Title = "EMP Strike", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_EMPMissile', CPCost = 500)
	Nod_SP(2) = (Title = "Cruise Missile", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_CruiseMissile', CPCost = 800)
	Nod_SP(3) = (Title = "Brothers in Arms", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_Reinforcement', CPCost = 800)
	Nod_SP(4) = (Title = "Unity Through Peace", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_Buff_Nod_UTP', CPCost = 1200)
	Nod_SP(5) = (Title = "Peace Through Power", bChoiceSelected = false, bInstant = false, BeaconInfo = class'Rx_CommanderSupport_BeaconInfo_Buff_Nod_PTP', CPCost = 1400)

}