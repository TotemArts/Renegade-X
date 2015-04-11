//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Rx_GFxFrontEnd_Extras extends Rx_GFxFrontEnd_View;

var Rx_GFXFrontEnd MainFrontEnd;

var GFxClikWidget CreditScrollingList;
var GFxClikWidget CreditScrollBar;

var const array<string> CreditContent;

function OnViewLoaded(Rx_GFXFrontEnd FrontEnd)
{
	MainFrontEnd = FrontEnd;
}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch (WidgetName)
	{
		case 'CreditScrollingList':
			if (CreditScrollingList == none || CreditScrollingList != Widget) {
				CreditScrollingList = GFxClikWidget(Widget);
			}
            SetUpDataProvider(CreditScrollingList);
			CreditScrollingList.SetInt("rowCount", 11);
			break;
		case 'CreditScrollBar':
			if (CreditScrollBar == none || CreditScrollBar != Widget) {
				CreditScrollBar = GFxClikWidget(Widget);
			}
			break;
        default:
            break;
	}
	return false;
}


function SetUpDataProvider(GFxClikWidget Widget)
{
	local GFxObject DataProvider;
	local byte i;


	DataProvider = CreateArray();
	switch(Widget)
	{
		case (CreditScrollingList):
			for (i=0; i < CreditContent.Length; i++) {
				DataProvider.SetElementString(i, CreditContent[i]);
			}
			break;
        default:
            return;
	}
    Widget.SetObject("dataProvider", DataProvider);
}
DefaultProperties
{

	SubWidgetBindings.Add((WidgetName="CreditScrollingList", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CreditScrollBar", WidgetClass=class'GFxClikWidget'))

	CreditContent.Add("[ Project Lead and Sound Engineer ]")
	CreditContent.Add("Bilal Bakri")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Lead Artist and Producer ]")
	CreditContent.Add("Waqas Iqbal")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Lead Programmer ]")
	CreditContent.Add("Daniel 'RypeL' Böckmann")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Programmers ]")
	CreditContent.Add("")
	CreditContent.Add("John 'Avalanche' Melton")
	CreditContent.Add("Tom 'halo2pac' Cables")
	CreditContent.Add("Eugen 'Pr0eX' Gerner")
	CreditContent.Add("Joe 'coffeeburrito' Wakefield")
	CreditContent.Add("Shahman 'Roxez' Teh")
	CreditContent.Add("Jeroen 'Chaos_Alfa' Houttuin")
	CreditContent.Add("Uzochukwu 'Franklin' Iheanacho")
	CreditContent.Add("Wiebe 'GreaseMonk' Geertsma")
	CreditContent.Add("Zach 'triggerhippy' Gray")
	CreditContent.Add("Mike Geig")
	CreditContent.Add("one1")
	CreditContent.Add("Kil")
	CreditContent.Add("Justin 'Agent' James");
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ General Artist ]")
	CreditContent.Add("")
	CreditContent.Add("Richard 'Ric' Jeffery")
	CreditContent.Add("Robin 'Nielsen' Nielsen")
	CreditContent.Add("Martin 'JeepRubi' Palko")
	CreditContent.Add("Martin 'tintin' Sanchez")
	CreditContent.Add("Sander 'ZixXer' Vereecken")
	CreditContent.Add("Evan 'HappyConscript' Brooks")
	CreditContent.Add("Matthew 'maty' McDonald")
	CreditContent.Add("Simon 'kenz3001' Mckenzie")
	CreditContent.Add("Ryan Wongwai")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Public Relations & Web Develpment ]")
	CreditContent.Add("")
	CreditContent.Add("Aaron 'Jam' Imming")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("Web Development Assistant")
	CreditContent.Add("")
	CreditContent.Add("Remy 'Uncut' Lagerweij")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Server Hosting ]")
	CreditContent.Add("")
	CreditContent.Add("David 'Speedy' Ellsworth (DME Hosting)")
	CreditContent.Add("Ben 'dog02' Rayeske (Finezt Hosting)")
	CreditContent.Add("MPF Community")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Animators ]")
	CreditContent.Add("")
	CreditContent.Add("Kris 'PermaGrin' Ducote")
	CreditContent.Add("Paolo 'Sinfect' Damaso")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Contributing Artists ]")
	CreditContent.Add("")
	CreditContent.Add("Robert 'Killa' Baker")
	CreditContent.Add("Kevin 'DrGuppy' Butt")
	CreditContent.Add("Elizabeth 'tomato' Deacon")
	CreditContent.Add("Chris 'MightyBOB!' Kohl")
	CreditContent.Add("Rafael Morais")
	CreditContent.Add("Shaun 'WNxKain' Slater")
	CreditContent.Add("Alexander 'Deathlink' Trautmann")
	CreditContent.Add("Shaikh Zhafri")
	CreditContent.Add("Cody Vogel")
	CreditContent.Add("Juan Villegas")
	CreditContent.Add("Jakub Janiak")
	CreditContent.Add("Juan Villegas")
	CreditContent.Add("KatzSmile")
	CreditContent.Add("Jordan Brooker")
	CreditContent.Add("Benjamin Allen")
	CreditContent.Add("Daniel Kamentsky")
	CreditContent.Add("Nathan Elliott")
	CreditContent.Add("Stoy79")
	CreditContent.Add("Tugodoomer")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Voice Actors ]")
	CreditContent.Add("")
	CreditContent.Add("Sonya Cerdan")
	CreditContent.Add("Ty Konzak")
	CreditContent.Add("CJ Williams")
	CreditContent.Add("Justin 'theGunrun' Ignacio")
	CreditContent.Add("Isaak 'Kraftsman' Kraft van Ermel")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Music & Sound Engineer ]")
	CreditContent.Add("")
	CreditContent.Add("Sebastian Aav")
	CreditContent.Add("Paul Curtis")
	CreditContent.Add("Niels van der Leest")
	CreditContent.Add("Adam Prack")
	CreditContent.Add("Maarten Bonder")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Special Thanks ]")
	CreditContent.Add("")
	CreditContent.Add("Electronic Arts")
	CreditContent.Add("Epic Games")
	CreditContent.Add("Westwood Studios")
	CreditContent.Add("C&C Community")
	CreditContent.Add("UDK Community")
	CreditContent.Add("Renegade X Beta Testers")
	CreditContent.Add("TREK Industries")
	CreditContent.Add("WillyG for the Gemini Online Service")
	CreditContent.Add("Our loyal fans")
}