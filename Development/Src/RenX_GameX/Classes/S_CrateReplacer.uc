class S_CrateReplacer extends Rx_Mutator;

function bool CheckReplacement(Actor Other)
{
    if (Rx_CratePickup(Other) != None)
  	{
        Rx_CratePickup(Other).DefaultCrateTypes.RemoveItem(class'Rx_CrateType_Spy');
        Rx_CratePickup(Other).DefaultCrateTypes.RemoveItem(class'Rx_CrateType_Character');
        Rx_CratePickup(Other).DefaultCrateTypes.RemoveItem(class'Rx_CrateType_ClassicVehicle');
        Rx_CratePickup(Other).DefaultCrateTypes.RemoveItem(class'Rx_CrateType_EpicCharacter');

        Rx_CratePickup(Other).DefaultCrateTypes.AddItem(class'S_CrateType_Spy');
        Rx_CratePickup(Other).DefaultCrateTypes.AddItem(class'S_CrateType_Character');
        Rx_CratePickup(Other).DefaultCrateTypes.AddItem(class'S_CrateType_ClassicVehicle');
        Rx_CratePickup(Other).DefaultCrateTypes.AddItem(class'S_CrateType_EpicCharacter');
        Rx_CratePickup(Other).DefaultCrateTypes.AddItem(class'S_CrateType_GDICharacter');        
    }
    return true;
}