class Rx_VersionQueryHandler extends Object within Rx_Game
	config(RenegadeX);

`include(Engine\Classes\HttpStatusCodes.uci)

var globalconfig string MasterVersionURL;
var bool bIsBusy;
var HttpRequestInterface Request;
var int QueryedVersionNumber;
var string QueryedVersionName;

delegate NotifyDelegate();

function RegisterNotifyDelegate(delegate<NotifyDelegate> MyNotifyDelegate)
{
	NotifyDelegate = MyNotifyDelegate;
}

function GetFromServer()
{
	if(!bIsBusy)
	{
		Request = class'HttpFactory'.static.CreateRequest();

		Request.SetProcessRequestCompleteDelegate(OnRequestComplete);
		Request.SetURL(MasterVersionURL);
		Request.SetVerb("GET");

		Request.ProcessRequest();

		bIsBusy = true;
	}
}

function ClearDelegates()
{
	Request.OnProcessRequestComplete = none;
}

function OnRequestComplete(HttpRequestInterface Req, 
	HttpResponseInterface Response, 
	bool bDidSucceed)
{
	local JsonObject VersionData;

	if(Response.GetResponseCode() != `HTTP_STATUS_OK)
	{
		`log(Response.GetResponseCode() $ " ERROR: Failed to fetch version data from " $ MasterVersionURL);
	} else if(Response != none && Response.GetResponseCode() == `HTTP_STATUS_OK)
	{
		VersionData = class'JsonObject'.static.DecodeJson(
			Response.GetContentAsString());

		HandleVersionData(VersionData);
	}

	bIsBusy = false;
	
	NotifyDelegate();
}

DefaultProperties
{
	QueryedVersionNumber = 0
	QueryedVersionName = ""
}
