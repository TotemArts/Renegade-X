class Rx_GFxFrontEnd_ExitDialog extends Rx_GFxFrontEnd_Dialog;

var Rx_GFXFrontEnd MainFrontEnd;

//test purpose at the moment
var GFxClikWidget submitBtn;
var GFxClikWidget cancelBtn;
var GFxClikWidget closeBtn;
var GFxClikWidget drageBar;

function OnViewLoaded(Rx_GFXFrontEnd FrontEnd)
{
	MainFrontEnd = FrontEnd;
	SetString("messageField", "Are you sure you want to exit?");

}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case 'submitBtn':
			submitBtn = GFxClikWidget(Widget);
			submitBtn.AddEventListener('CLIK_Press', OnSubmitBtnPress);
			//ScriptTrace();
			break;
		case 'cancelBtn':
			cancelBtn = GFxClikWidget(Widget);
			cancelBtn.AddEventListener('CLIK_Press', OnCancelBtnPress);
			break;
		case 'closeBtn':
			closeBtn = GFxClikWidget(Widget);
			break;
		case 'drageBar':
			drageBar = GFxClikWidget(Widget);
			break;
		default:
			break;
	}
	return false;
}

function OnCancelBtnPress(GFxClikWidget.EventData ev)
{
	MainFrontEnd.ReturnToBackground();
}
function OnSubmitBtnPress(GFxClikWidget.EventData ev)
{
	MainFrontEnd.ExitGame();
}
DefaultProperties
{
    SubWidgetBindings.Add((WidgetName="submitBtn",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="cancelBtn",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="closeBtn",WidgetClass=class'GFxClikWidget'))
    SubWidgetBindings.Add((WidgetName="drageBar",WidgetClass=class'GFxClikWidget'))
}
