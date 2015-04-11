/*********************************************************
*
* File: Rx_CharInfo_Singleplayer.uc
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
class Rx_BotCharInfo extends UTCharInfo;

DefaultProperties
{
	Families.Empty
	Families.Add(class'Rx_FamilyInfo_GDI_Soldier')
	Families.Add(class'Rx_FamilyInfo_Nod_Soldier')
}
