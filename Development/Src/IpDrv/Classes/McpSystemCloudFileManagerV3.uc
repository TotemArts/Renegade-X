/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * This is the MCP3 version of the inventory manager
 */
class McpSystemCloudFileManagerV3 extends McpServiceBase
	implements(OnlineTitleFileInterface)
	config(Engine);

/** The list of delegates to notify when a file is read */
var array<delegate<OnReadTitleFileComplete> > ReadTitleFileCompleteDelegates;

/** The list of delegates to notify when a file list read is done */
var array<delegate<OnRequestTitleFileListComplete> > RequestTitleFileListCompleteDelegates;

/** Web resource paths */
var config String FileResourcePath;

/** Holds information about a file downloaded (or available for download) from EMS */
struct Ems3File
{
	/** Filename generated for storage on the backend */
	var String UniqueFileName;
	/** The filename that was uploaded */
	var String FileName;
	/** A hash of the file so you can use detect out of date local files */
	var String Hash;
	/** Size of the file in bytes */
	var int Length;
	/** Whether it is ok to cache the file locally or not */
	var bool bCanCache;
	/** The read state for the file */
	var EOnlineEnumerationReadState ReadState;
	/** The data for the file */
	var array<byte> Data;
};

/** List of EMS files we know about */
var array<Ems3File> EmsFiles;

struct FileRequest
{
	/** The file name that was requested for by the client */
	var string FileToRead;
	/** The request object for this request */
	var HttpRequestInterface Request;
};

/** Holds async file requests */
var array<FileRequest> FileRequests;

/**
 * Helper function that returns an HttpRequest object with the agent/content type set
 *
 * @param McpId not used in this version
 *
 * @return the newly created http request object
 */
function HttpRequestInterface CreateHttpRequest(optional String McpId)
{
	local HttpRequestInterface Request;

	Request = Super.CreateHttpRequest();
	UseGameServiceAuth(Request);

	return Request;
}

/**
 * Delegate fired when the request for a list of files completes
 *
 * @param bWasSuccessful whether the request completed successfully
 * @param ResultStr contains the list of files and associated meta data
 */
delegate OnRequestTitleFileListComplete(bool bWasSuccessful, string ResultStr);

/**
 * Delegate fired when a file read from the network platform's title specific storage is complete
 *
 * @param bWasSuccessful whether the file read was successful or not
 * @param FileName the name of the file this was for
 */
delegate OnReadTitleFileComplete(bool bWasSuccessful,string FileName);

/**
 * Starts an asynchronous read of the specified file from the network platform's
 * title specific file store
 *
 * @param FileToRead the name of the file to read
 *
 * @return true if the calls starts successfully, false otherwise
 */
function bool ReadTitleFile(string FileToRead)
{
	local int FileIndex;
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	FileIndex = GetFileIndex(FileToRead);
	if (FileIndex == INDEX_NONE)
	{
		OnReadTitleFileComplete(false, "Could not find header information for file: " $ FileToRead);
		return false;
	}
	Request = CreateHttpRequestGameAuth();
	if (Request != none)
	{
		Url = GetBaseURL() $ FileResourcePath $ "/" $ EmsFiles[FileIndex].UniqueFileName;
		`LogMcp("ReadTitleFile URL is GET " $ Url);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("GET");
		Request.SetProcessRequestCompleteDelegate(OnReadTitleFileRequestComplete);

		AddAt = FileRequests.Length;
		FileRequests.Length = AddAt + 1;
		FileRequests[AddAt].Request = Request;
		FileRequests[AddAt].FileToRead = FileToRead;

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start ReadTitleFile web request for URL(" $ Url $ ")");
		}
	}
	return true;
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnReadTitleFileRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local int Index;
	local delegate<OnReadTitleFileComplete> OnRequestComplete;
	local int RequestIndex;
	local int FileIndex;
	local String FileName;
	local array<byte> Data;

	RequestIndex = FileRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (bWasSuccessful)
		{
			FileName = FileRequests[RequestIndex].FileToRead;
			// Save the data to the in memory cache
			FileIndex = GetFileIndex(FileName);
			if (FileIndex != INDEX_NONE)
			{
				Response.GetContent(Data);
				EmsFiles[FileIndex].Data = Data;
			}
			else
			{
				ErrorString = "ReadTitleFile received data for a file (" $ FileName $ ") it does not have in its list with response code (" $ ResponseCode $ ")";
			}
		}
		else
		{
			ErrorString = "ReadTitleFile failed with response code (" $ ResponseCode $ ")";
		}
		if (!bWasSuccessful && Len(ErrorString) > 0)
		{
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		for (Index = 0; Index < ReadTitleFileCompleteDelegates.Length; Index++)
		{
			OnRequestComplete = ReadTitleFileCompleteDelegates[Index];
			OnRequestComplete(bWasSuccessful, FileRequests[RequestIndex].FileToRead);
		}
		FileRequests.Remove(RequestIndex, 1);
	}
}

/**
 * Adds the delegate to the list to be notified when a requested file has been read
 *
 * @param ReadTitleFileCompleteDelegate the delegate to add
 */
function AddReadTitleFileCompleteDelegate(delegate<OnReadTitleFileComplete> ReadTitleFileCompleteDelegate)
{
	if (ReadTitleFileCompleteDelegates.Find(ReadTitleFileCompleteDelegate) == INDEX_NONE)
	{
		ReadTitleFileCompleteDelegates[ReadTitleFileCompleteDelegates.Length] = ReadTitleFileCompleteDelegate;
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param ReadTitleFileCompleteDelegate the delegate to remove
 */
function ClearReadTitleFileCompleteDelegate(delegate<OnReadTitleFileComplete> ReadTitleFileCompleteDelegate)
{
	local int RemoveIndex;

	RemoveIndex = ReadTitleFileCompleteDelegates.Find(ReadTitleFileCompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		ReadTitleFileCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Copies the file data into the specified buffer for the specified file
 *
 * @param FileName the name of the file to read
 * @param FileContents the out buffer to copy the data into
 *
 * @return true if the data was copied, false otherwise
 */
function bool GetTitleFileContents(string FileName, out array<byte> FileContents)
{
	local int FileIndex;

	FileIndex = GetFileIndex(FileName);
	if (FileIndex == INDEX_NONE)
	{
		return false;
	}
	FileContents = EmsFiles[FileIndex].Data;

	return true;
}

/**
 * Determines the async state of the tile file read operation
 *
 * @param FileName the name of the file to check on
 *
 * @return the async state of the file read
 */
function EOnlineEnumerationReadState GetTitleFileState(string FileName)
{
	local int FileIndex;

	FileIndex = GetFileIndex(FileName);
	if (FileIndex == INDEX_NONE)
	{
		return OERS_Failed;
	}
	return EmsFiles[FileIndex].ReadState;
}

/**
 * Empties the set of downloaded files if possible (no async tasks outstanding)
 *
 * @return true if they could be deleted, false if they could not
 */
function bool ClearDownloadedFiles()
{
	local int FileIndex;

	// Make sure no items are in progress
	for (FileIndex = 0; FileIndex < EmsFiles.Length; FileIndex++)
	{
		if (EmsFiles[FileIndex].ReadState == OERS_InProgress)
		{
			return false;
		}
	}
	EmsFiles.Length = 0;
	
	return true;
}

/**
 * Returns the index into the EmsFiles array
 *
 * @param FileName the file to find
 *
 * @return the index into the array or INDEX_NONE if not found
 */
function int GetFileIndex(String FileName)
{
	local int FileIndex;

	FileIndex = EmsFiles.Find('UniqueFileName', FileName);
	if (FileIndex == INDEX_NONE)
	{
		// Try the friendly name
		FileIndex = EmsFiles.Find('FileName', FileName);
	}

	return FileIndex;
}

/**
 * Empties the cached data for this file if it is not being downloaded currently
 *
 * @param FileName the name of the file to remove from the cache
 *
 * @return true if it could be deleted, false if it could not
 */
function bool ClearDownloadedFile(string FileName)
{
	local int FileIndex;

	FileIndex = GetFileIndex(FileName);
	if (FileIndex == INDEX_NONE)
	{
		return false;
	}
	// Empty the data for the file
	EmsFiles[FileIndex].Data.Length = 0;

	return true;
}

/**
 * Async call to request a list of files (returned as string) from EMS
 */
function RequestTitleFileList()
{
	local String Url;
	local HttpRequestInterface Request;

	Request = CreateHttpRequestGameAuth();
	if (Request != none)
	{
		Url = GetBaseURL() $ FileResourcePath;
		`LogMcp("RequestTitleFileList URL is GET " $ Url);
		// Build our web request with the above URL
		Request.SetURL(Url);
		Request.SetVerb("GET");
		Request.SetProcessRequestCompleteDelegate(OnReadTitleFileListRequestComplete);

		// Now kick off the request
		if (!Request.ProcessRequest())
		{
			`LogMcp("Failed to start RequestTitleFileList web request for URL(" $ Url $ ")");
		}
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnReadTitleFileListRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local int Index;
	local delegate<OnRequestTitleFileListComplete> OnRequestComplete;

	ResponseCode = 500;
	if (Response != none)
	{
		ResponseCode = Response.GetResponseCode();
		ResponseString = Response.GetContentAsString();
	}
	// Both of these need to be true for the request to be a success
	bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
	if (bWasSuccessful)
	{
		// If there was content
		if (ResponseCode != 204 && ResponseString != "")
		{
			bWasSuccessful = ParseFiles(ResponseString);
			if (!bWasSuccessful)
			{
				ErrorString = "RequestTitleFileList failed to parse JSON:\n" $ ResponseString;
			}
		}
	}
	else
	{
		ErrorString = "RequestTitleFileList failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
	}
	// Notify anyone waiting on this
	for (Index = 0; Index < RequestTitleFileListCompleteDelegates.Length; Index++)
	{
		OnRequestComplete = RequestTitleFileListCompleteDelegates[Index];
		OnRequestComplete(bWasSuccessful, ErrorString);
	}
}

/**
 * Parses a JSON payload into a set of EmsFile entries
 *
 * @param Json the json string to parse
 *
 * @return true if the payload parsed correctly, false otherwise
 */
function bool ParseFiles(String Json)
{
	local JsonObject ParsedJson, JsonElement;
	local int JsonIndex;

	ParsedJson = class'JsonObject'.static.DecodeJson(Json);
	if (ParsedJson != None)
	{
		// Parse each file, adding them if needed
		for (JsonIndex = 0; JsonIndex < ParsedJson.ObjectArray.Length; JsonIndex++)
		{
			JsonElement = ParsedJson.ObjectArray[JsonIndex];
			if (!ParseFile(JsonElement))
			{
				return false;
			}
		}
	}
	return true;
}

/**
 * Copies the properties from a JSON node to a EmsFile struct entry
 *
 * @param JsonNode the json object to copy data from
 *
 * @return true if the payload parsed correctly, false otherwise
 */
function bool ParseFile(JsonObject JsonNode)
{
	local int FileIndex;
	local String UniqueFileName;
	local bool bHasParseError;

	/**
	 * Sample json:
	 *
	 *	[
	 * 		{
	 *			"uniqueFilename":"b6df6321525a448b9ba26fcca4b5e195",
	 *			"filename":"JGEMS.ini",
	 *			"hash":"59a4847e1f3d5bf8bc936d08827c8bd99b3cf698",
	 *			"length":39,
	 *			"doNotCache":false
	 *		}
	 *	]
	 */
	if (!JsonNode.HasKey("uniqueFilename"))
	{
		return false;
	}
	// Since this is unique globally, it makes a pretty good key ;)
	UniqueFileName = JsonNode.GetStringValue("uniqueFilename");
	FileIndex = EmsFiles.Find('UniqueFileName', UniqueFileName);
	if (FileIndex == INDEX_NONE)
	{
		// Not in our list, so add it
		FileIndex = EmsFiles.Length;
		EmsFiles.Length = FileIndex + 1;
		EmsFiles[FileIndex].UniqueFileName = UniqueFileName;
	}
	if (JsonNode.HasKey("filename"))
	{
		EmsFiles[FileIndex].FileName = JsonNode.GetStringValue("filename");
	}
	else
	{
		bHasParseError = true;
	}
	if (JsonNode.HasKey("hash"))
	{
		EmsFiles[FileIndex].Hash = JsonNode.GetStringValue("hash");
	}
	else
	{
		bHasParseError = true;
	}
	if (JsonNode.HasKey("length"))
	{
		EmsFiles[FileIndex].Length = JsonNode.GetIntValue("length");
	}
	else
	{
		bHasParseError = true;
	}
	if (JsonNode.HasKey("doNotCache"))
	{
		EmsFiles[FileIndex].bCanCache = !JsonNode.GetBoolValue("doNotCache");
	}
	else
	{
		bHasParseError = true;
	}
	if (bHasParseError)
	{
		// Clear out any data that might be there from a partial parse
		EmsFiles.Remove(FileIndex, 1);
	}
	return !bHasParseError;
}

/**
 * Adds the delegate to the list to be notified when the list of requested files has been received
 *
 * @param RequestTitleFileListDelegate the delegate to add
 */
function AddRequestTitleFileListCompleteDelegate(delegate<OnRequestTitleFileListComplete> RequestTitleFileListDelegate)
{
	if (RequestTitleFileListCompleteDelegates.Find(RequestTitleFileListDelegate) == INDEX_NONE)
	{
		RequestTitleFileListCompleteDelegates.AddItem(RequestTitleFileListDelegate);
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param RequestTitleFileListDelegate the delegate to remove
 */
function ClearRequestTitleFileListCompleteDelegate(delegate<OnRequestTitleFileListComplete> RequestTitleFileListDelegate)
{
	local int RemoveIndex;

	RemoveIndex = RequestTitleFileListCompleteDelegates.Find(RequestTitleFileListDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		RequestTitleFileListCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Provides the caller with the list of files available for download
 *
 * @param FileNames the out value the names are copied into
 */
function GetTitleFileList(out array<EmsFile> FileList)
{
	local int FileIndex;
	local EmsFile FileData;

	FileList.Length = 0;
	// Loop through our list copying file names
	for (FileIndex = 0; FileIndex < EmsFiles.Length; FileIndex++)
	{
		FileData.DLName = EmsFiles[FileIndex].UniqueFileName;
		FileData.FileName = EmsFiles[FileIndex].FileName;
		FileData.Hash = EmsFiles[FileIndex].Hash;
		FileData.FileSize = EmsFiles[FileIndex].Length;
		FileList.AddItem(FileData);
	}
}