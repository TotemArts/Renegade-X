// This Sequence action will cause announcement to be triggered globally

class Rx_SeqAct_BroadcastAnnouncement extends SequenceAction;

var(Broadcast) String Announcement;	//Shown text, duh
var(Broadcast) float Time; // How long the message persists
var(Broadcast) bool bIsWarning;


enum AnnounceColor
{
	MSG_White,
	MSG_Red,
	MSG_Green,
	MSG_LightGreen,
	MSG_Blue,
	MSG_LightBlue,
	MSG_Pink,
	MSG_Yellow,
	MSG_Orange
};

var(Broadcast) AnnounceColor AnnouncementColor;	//What color should this text be
var(Broadcast) byte TeamNum;

event Activated()
{
	Rx_Game(GetWorldInfo().Game).CTextBroadcast(TeamNum,Announcement,GetColor(),Time, 1.0,bIsWarning);
}

function name GetColor()
{
	Switch(AnnouncementColor)
	{
		Case MSG_White:
		return 'White';

		Case MSG_Red:
		return 'Red';

		Case MSG_Green:
		return 'Green';

		Case MSG_LightGreen:
		return 'LightGreen';

		Case MSG_Blue:
		return 'Blue';

		Case MSG_LightBlue:
		return 'LightBlue';

		Case MSG_Pink:
		return 'Pink';

		Case MSG_Yellow:
		return 'Yellow';

		Case MSG_Orange:
		return 'Orange';
	}
}

defaultproperties
{
   ObjName="Broadcast Announcement"
   ObjCategory="Ren X"

   VariableLinks.Empty
   VariableLinks(0)=(ExpectedType=class'SeqVar_String', LinkDesc="String",PropertyName=Announcement)
   bCallHandler=false

   Announcement = "My awesomely obnoxious announcement is here"
   Time = 30.0
   TeamNum = 255
}