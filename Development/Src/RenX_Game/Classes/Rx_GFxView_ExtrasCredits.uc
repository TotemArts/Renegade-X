class Rx_GFxView_ExtrasCredits extends Rx_GFxView
	config(UI);

var GFxClikWidget CreditScrollingList;
var GFxClikWidget CreditScrollBar;

var const array<string> CreditContent;

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bWasHandled;

	`log("Rx_GFxView_ExtrasCredits::WidgetInitialized"@`showvar(WidgetName),true,'DevGFxUI');

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

function OnViewLoaded()
{
	ActionScriptVoid("validateNow");
}


DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="CreditScrollingList", WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="CreditScrollBar", WidgetClass=class'GFxClikWidget'))

	// NOTE: Credits list has been removed to prevent confusion; if this class is ever used again, please copy the current list from Rx_GFxFrontEnd_Extras.uc
}
