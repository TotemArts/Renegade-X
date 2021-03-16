class S_Nod_EVA extends Rx_Mutator;

function bool CheckReplacement(Actor Other)
{
    local Rx_Building Building;

    ForEach `WorldInfoObject.AllActors(class'Rx_Building', Building)
    {
        Building.GDIColor="#3260FF";

        if(Building.Class == class'Rx_Building_AirTower')
            Building.BuildingInternalsClass=class'S_Building_AirTower_Internals';
        
        if(Building.Class == class'Rx_Building_AirTower_Ramps')
            Building.BuildingInternalsClass=class'S_Building_AirTower_Internals_Ramps';
        
        if(Building.Class == class'Rx_Building_HandOfNod' || Building.Class == class'Rx_Building_HandOfNod_Ramps')
            Building.BuildingInternalsClass=class'S_Building_HandOfNod_Internals';
        
        if(Building.Class == class'Rx_Building_Refinery_Nod' || Building.Class == class'Rx_Building_Refinery_Nod_Ramps')
            Building.BuildingInternalsClass=class'S_Building_Refinery_Nod_Internals';
        
        if(Building.Class == class'Rx_Building_PowerPlant_Nod' || Building.Class == class'Rx_Building_PowerPlant_Nod_Ramps')
            Building.BuildingInternalsClass=class'S_Building_PowerPlant_Nod_Internals';
        
        if(Building.Class == class'Rx_Building_Obelisk')
            Building.BuildingInternalsClass=class'S_Building_Obelisk_Nod_Internals';
        
        if(Building.Class == class'Rx_Building_Silo')
            Building.BuildingInternalsClass=class'S_Building_Silo_Internals';
        
        if(Building.Class == class'Rx_Building_CommCentre')
            Building.BuildingInternalsClass=class'S_Building_CommCentre_Internals';

        if(Building.Class == class'Rx_Building_TeamSilo_Nod')
            Building.BuildingInternalsClass=class'S_Building_TeamSilo_Nod_Internals';
        
        if(Building.Class == class'Rx_Building_RepairFacility_Nod')
            Building.BuildingInternalsClass=class'S_Building_RepairFacility_Nod_Internals';
    }

    return true;
}