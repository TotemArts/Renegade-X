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

	ActionScriptVoid("validateNow");
}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bWasHandled;

	`log("Rx_GFxFrontEnd_Extra::WidgetInitialized"@`showvar(WidgetName),true,'DevGFxUI');

	bWasHandled = false; 

	switch (WidgetName)
	{
		case 'CreditScrollingList':
			if (CreditScrollingList == none || CreditScrollingList != Widget) {
				CreditScrollingList = GFxClikWidget(Widget);
			}
            SetUpDataProvider(CreditScrollingList);
			CreditScrollingList.SetInt("rowCount", 11);
			bWasHandled = true;
			break;
		case 'CreditScrollBar':
			if (CreditScrollBar == none || CreditScrollBar != Widget) {
				CreditScrollBar = GFxClikWidget(Widget);
			}
			bWasHandled = true;
			break;
        default:
            break;
	}
	return bWasHandled;
}


function SetUpDataProvider(GFxClikWidget Widget)
{
	local GFxObject DataProvider;
	local byte i;

	`log("Rx_GFxFrontEnd_Extras::SetupDataProvider"@Widget.GetString("name"),true,'DevGFxUI');


	DataProvider = CreateObject("scaleform.clik.data.DataProvider");
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
	CreditContent.Add("Jessica 'Agent' James")
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
	CreditContent.Add("Sean 'Yosh56' Nolan")
	CreditContent.Add("Rob 'Schmitzenbergh' Smit")
	CreditContent.Add("Waldemar 'KrypTheBear' Meschalin")
	CreditContent.Add("Craig 'ShrewdTactician' Emmott")
	CreditContent.Add("Mark 'AlienX' Phillips")
	CreditContent.Add("Sarah 'buttons' Evans")
	CreditContent.Add("Randy 'SonnyX' von der Weide")
	CreditContent.Add("Isa 'Handepsilon' Handoyo")
	CreditContent.Add("Mike Geig")
	CreditContent.Add("one1")
	CreditContent.Add("Kil")
	CreditContent.Add("nBab")
	CreditContent.Add("--nn")
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
	CreditContent.Add("Ruud 'Ruud003' Gunnewiek")
	CreditContent.Add("Jos 'Henk' Vermeulen")
	CreditContent.Add("Thom 'TK0104' Keuken")
	CreditContent.Add("Sam 'SMayhew' Mayhew")
	CreditContent.Add("Ryan Wongwai")
	CreditContent.Add("James Bruner")
	CreditContent.Add("Denis dos Santos")
	CreditContent.Add("Fedor Kurmazov")
	CreditContent.Add("Yaroslav Baryshev")
	CreditContent.Add("Kamal Afiq Kamarul Bahri")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Public Relations & Web Development ]")
	CreditContent.Add("")
	CreditContent.Add("Aaron 'Jam' Imming")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Web Development Assistant ]")
	CreditContent.Add("")
	CreditContent.Add("Remy 'Uncut' Lagerweij")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Information Technology ]")
	CreditContent.Add("")
	CreditContent.Add("David 'Speedy' Ellsworth")
	CreditContent.Add("Danny 'fffreak9999' Blake")
	CreditContent.Add("Bryan Kloosterboer")
	CreditContent.Add("Cronus")
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
	CreditContent.Add("Shaun 'WNxKain' Slater")
	CreditContent.Add("Alexander 'Deathlink' Trautmann")
	CreditContent.Add("Craig 'Glacious' Cooper")
	CreditContent.Add("Bruno 'owhenky' Freitas")
	CreditContent.Add("Rafael Morais")
	CreditContent.Add("Shaikh Zhafri")
	CreditContent.Add("Cody Vogel")
	CreditContent.Add("Juan Villegas")
	CreditContent.Add("Jakub Janiak")
	CreditContent.Add("Jordan Brooker")
	CreditContent.Add("Benjamin Allen")
	CreditContent.Add("Daniel Kamentsky")
	CreditContent.Add("Nathan Elliott")
	CreditContent.Add("Alec Claravall")
	CreditContent.Add("Mason Rosenquist")
	CreditContent.Add("KatzSmile")
	CreditContent.Add("Stoy79")
	CreditContent.Add("Tugodoomer")
	CreditContent.Add("")
	CreditContent.Add("")
	CreditContent.Add("[ Motion Designer ]")
	CreditContent.Add("David Kashevsky")
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
	CreditContent.Add("MPF Community")
	CreditContent.Add("Jarzey for Wiki contributions")
	CreditContent.Add("Tiberian Aftermath")
	CreditContent.Add("Tiberian Sun: Reborn")
	CreditContent.Add("Our loyal fans")
}