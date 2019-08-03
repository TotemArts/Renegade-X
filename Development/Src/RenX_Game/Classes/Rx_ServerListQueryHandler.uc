class Rx_ServerListQueryHandler extends Object within Rx_Game
	config(RenegadeX);

`include(Engine\Classes\HttpStatusCodes.uci)

var globalconfig string MasterServerURL;
var bool bIsBusy;
var HttpRequestInterface Request;

delegate NotifyDelegate();

function GetFromServer()
{
	if(!bIsBusy)
	{
		Request = class'HttpFactory'.static.CreateRequest();

		Request.SetProcessRequestCompleteDelegate(OnRequestComplete);
		Request.SetURL(MasterServerURL $ "?id=" $ `RxEngineObject.HWID);
		Request.SetHeader("User-Agent", "RenX-Game");
		Request.SetVerb("GET");

		Request.ProcessRequest();

		bIsBusy = true;
	}
}

function ClearDelegates()
{
	Request.OnProcessRequestComplete = none;
}

/**
 * TODO: A possible optimization may be to DllBind a JSON parsing library like YAJL, and populate the server list as we receive data, rather than handling it all when the request completes.
 *	This would also mean a player could join a server before the server list request finishes.
 */
function OnRequestComplete(HttpRequestInterface Req, 
	HttpResponseInterface Response, 
	bool bDidSucceed)
{
	local JsonObject MasterServerData;

	if(Response != none && Response.GetResponseCode() == `HTTP_STATUS_OK)
	{
		MasterServerData = class'JsonObject'.static.DecodeJson(
			Response.GetContentAsString());

		HandleServerData(MasterServerData);
	}

	bIsBusy = false;
	
	NotifyDelegate();
}
