class Rx_GameViewportClient extends UTGameViewportClient;

var Rx_GFXFrontEnd FrontEnd;

function SetStartupMovie(string leaving_level, string loading_level)
{
	local Rx_SetStartupMovie movie_handler;
	movie_handler = new class'Rx_SetStartupMovie';
	movie_handler.SetStartupMovie(leaving_level, loading_level);
}

function DrawTransition(Canvas Canvas)
{
	local string MapName;
	local int pos;

	if (Outer.TransitionType == TT_Loading)
	{
		MapName = Outer.TransitionDescription;

		// Ensure no file extension is included
		pos = InStr(MapName, ".");
		if (pos != -1)
			MapName = Left(MapName, pos);

		SetStartupMovie(string(class'Engine'.static.GetCurrentWorldInfo().GetPackageName()), MapName);
	}
	else
	{
		super.DrawTransition(Canvas);
	}
}

event SetProgressMessage(EProgressMessageType MessageType, string Message, optional string Title, optional bool bIgnoreFutureNetworkMessages)
{
	local string percentage;
	Super.SetProgressMessage(MessageType, Message, Title, bIgnoreFutureNetworkMessages);

	if (MessageType == PMT_DownloadProgress)
	{
		if (Title == "Success")
		{
			if (FrontEnd.DownloadProgressDialogInstance != None)
				FrontEnd.CloseDownloadProgressDialog();
		}
		else
		{
			percentage = Right(Message, 6);
			switch (Left(percentage, 1))
			{
			case "e":
				percentage = Mid(percentage, 2);
				break;
			case " ":
				percentage = Mid(percentage, 1);
				break;
			default:
				break;
			}
			Message = Left(Message, InStr(Message, ",", false, false, 5));
			if (FrontEnd.DownloadProgressDialogInstance == None)
				FrontEnd.OpenShowDownloadProgressDialog(Title, Message $ "B");
			Message = Mid(Message, 5);
			FrontEnd.UpdateDownloadProgressDialog(float(Message) * float(percentage) / 100.0, float(Message));
			FrontEnd.UpdateDownloadProgressPercentage(percentage);
		}
	}
}

DefaultProperties
{
}