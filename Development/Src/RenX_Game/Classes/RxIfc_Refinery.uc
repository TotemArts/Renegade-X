interface RxIfc_Refinery;

simulated function HarvesterDocked(Rx_Vehicle_HarvesterController HarvesterController);

function bool ShouldSpawnHarvester();

simulated function float GetCreditsPerTick();

simulated function Rx_Ref_NavigationPoint GetRefNavPoint();

simulated function SetRefNavPoint(Rx_Ref_NavigationPoint NewPoint);

function NotifyHarvesterDestroyed();

function NotifyHarvesterCreated();

function RequestHarvester();

function Rx_Vehicle_HarvesterController GetDockedHarvester();
function SetDockedHarvester(Rx_Vehicle_HarvesterController NewHarv);

function bool GetHarvEMPd();
function SetHarvEMPd(bool bEMPd);

function float GetHarvesterHarvestTime();

simulated function StartCreditsFlowSound();

simulated function StopCreditsFlowSound();