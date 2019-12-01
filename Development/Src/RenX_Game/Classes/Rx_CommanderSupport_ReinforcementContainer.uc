class Rx_CommanderSupport_ReinforcementContainer extends Actor;

var Array<class<Rx_FamilyInfo> > GDIInfClasses, NodInfClasses;

static function Array<class<Rx_FamilyInfo> > GetInfClasses(byte TeamIndex)
{
	if(TeamIndex == 0)
		return default.GDIInfClasses;
	else 
		return default.NodInfClasses;


}

DefaultProperties
{
	GDIInfClasses[0] = Rx_FamilyInfo_GDI_Officer	
	GDIInfClasses[1] = Rx_FamilyInfo_GDI_Officer	
	GDIInfClasses[2] = Rx_FamilyInfo_GDI_Patch	
	GDIInfClasses[3] = Rx_FamilyInfo_GDI_RocketSoldier	
	GDIInfClasses[4] = Rx_FamilyInfo_GDI_RocketSoldier	
	GDIInfClasses[5] = Rx_FamilyInfo_GDI_Gunner	
	NodInfClasses[0] = Rx_FamilyInfo_Nod_Mendoza	
	NodInfClasses[1] = Rx_FamilyInfo_Nod_LaserChainGunner	
	NodInfClasses[2] = Rx_FamilyInfo_Nod_LaserChainGunner	
	NodInfClasses[3] = Rx_FamilyInfo_Nod_LaserChainGunner	
}