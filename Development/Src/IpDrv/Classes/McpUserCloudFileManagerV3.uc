/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * This is the MCP3 version of the inventory manager
 */
class McpUserCloudFileManagerV3 extends McpServiceBase
	implements(UserCloudFileInterface)
	config(Engine);

/** Web resource paths */
var config String FileResourcePath;
var config String LastNResourcePath;

/** Holds information about a file downloaded (or available for download) from EMS */
struct EmsUserFile extends OnlineSubsystem.EmsFile
{
	/** The Mcp id of the user that owns this file */
	var String McpId;
	/** The read state for the file */
	var EOnlineEnumerationReadState ReadState;
	/** The data for the file */
	var array<byte> Data;
};

/** List of EMS files we know about */
var array<EmsUserFile> EmsFiles;

/** The last known set of people that have written files to the server */
var array<String> LastNCloudSaveOwners;

struct FileRequest
{
	/** The file name that was requested for by the client */
	var string FileToRead;
	/** The request object for this request */
	var HttpRequestInterface Request;
};

struct UserRequest
{
	/** The user that this call is for */
	var string McpId;
	/** The request object for this request */
	var HttpRequestInterface Request;
};

struct UserFileRequest
{
	/** The user that this call is for */
	var string McpId;
	/** The file name that was requested by the client */
	var string FileName;
	/** The request object for this request */
	var HttpRequestInterface Request;
	/** Used to determine how long this task took */
	var int StartTime;
	/** Differentiate between reads/writes */
	var bool bIsWrite;
};

/** Holds async requests */
var array<FileRequest> FileRequests;
var array<UserRequest> UserRequests;
var array<UserFileRequest> UserFileRequests;

/** The list of delegates to notify when the user file list enumeration is complete */
var private array<delegate<OnEnumerateUserFilesComplete> > EnumerateUserFilesCompleteDelegates;
/** The list of delegates to notify when a user file read is complete */
var private array<delegate<OnReadUserFileComplete> > ReadUserFileCompleteDelegates;
/** The list of delegates to notify when a user file write is complete */
var private array<delegate<OnWriteUserFileComplete> > WriteUserFileCompleteDelegates;
/** The list of delegates to notify when a user file delete is complete */
var private array<delegate<OnDeleteUserFileComplete> > DeleteUserFileCompleteDelegates;
var private array<delegate<OnReadLastNCloudSaveOwnersComplete> > ReadLastNCloudSaveOwnersCompleteDelegates;

/**
 * Delegate fired when the list of files has been returned from the network store
 *
 * @param bWasSuccessful whether the file list was successful or not
 * @param UserId User owning the storage
 */
delegate OnEnumerateUserFilesComplete(bool bWasSuccessful,string UserId);

/**
 * Delegate fired when a user file read from the network platform's storage is complete
 *
 * @param bWasSuccessful whether the file read was successful or not
 * @param UserId User owning the storage
 * @param FileName the name of the file this was for
 *
 */
delegate OnReadUserFileComplete(bool bWasSuccessful,string UserId,string FileName);

/**
 * Delegate fired when a user file write to the network platform's storage is complete
 *
 * @param bWasSuccessful whether the file Write was successful or not
 * @param UserId User owning the storage
 * @param FileName the name of the file this was for
 *
 */
delegate OnWriteUserFileComplete(bool bWasSuccessful,string UserId,string FileName);

/**
 * Delegate fired when a user file delete from the network platform's storage is complete
 *
 * @param bWasSuccessful whether the file read was successful or not
 * @param UserId User owning the storage
 * @param FileName the name of the file this was for
 */
delegate OnDeleteUserFileComplete(bool bWasSuccessful,string UserId,string FileName);

/**
 * Delegate fired when the list of last people that saved files is done
 *
 * @param bWasSuccessful whether the read was successful or not
 */
delegate OnReadLastNCloudSaveOwnersComplete(bool bWasSuccessful);

/**
 * @return the path to the user's file resource
 */
function String BuildFileResourcePath(String McpId, optional String FileName)
{
	local String Path;
	local int Index;

	Path = Repl(FileResourcePath, "{epicId}", McpId);
	// Find the DLName for this file
	if (FileName != "")
	{
		Index = FindUserFileIndex(McpId, FileName);
		if (Index != INDEX_NONE)
		{
			FileName = EmsFiles[Index].DLName;
		}
	}
	Path = Repl(Path, "{uniqueFilename}", FileName);

	return Path;
}

/**
 * Helper function that returns an HttpRequest object with the agent/content type set
 *
 * @param McpId optional user to get the auth token for
 *
 * @return the newly created http request object
 */
function HttpRequestInterface CreateHttpRequest(optional String McpId)
{
	local HttpRequestInterface Request;

	Request = class'HttpFactory'.static.CreateRequest();
	if (Request != none)
	{
		// Set all of the common headers
		Request.SetHeader("X-Game-Agent", GetUserAgent());
		AddUserAuthorization(Request, McpId);
	}
	return Request;
}

/**
 * Requests a list of available User files from the network store
 *
 * @param UserId User owning the storage
 */
function EnumerateUserFiles(string UserId)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(UserId);

	Url = GetBaseURL() $ BuildFileResourcePath(UserId);
	`LogMcp("EnumerateUserFiles URL is GET " $ Url);

	// Build our web request with the above URL
	Request.SetURL(Url);
	Request.SetVerb("GET");
	Request.SetProcessRequestCompleteDelegate(OnEnumerateUserFilesRequestComplete);

	AddAt = UserRequests.Length;
	UserRequests.Length = AddAt + 1;
	UserRequests[AddAt].Request = Request;
	UserRequests[AddAt].McpId = UserId;

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start EnumerateUserFiles web request for URL(" $ Url $ ")");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnEnumerateUserFilesRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local int Index;
	local delegate<OnEnumerateUserFilesComplete> OnRequestComplete;
	local int RequestIndex;

	RequestIndex = UserRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
	{
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
					ErrorString = "EnumerateUserFiles failed to parse JSON:\n ResponseCode (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
				}
			}
		}
		else
		{
			ErrorString = "EnumerateUserFiles failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		if (!bWasSuccessful && Len(ErrorString) > 0)
		{
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		for (Index = 0; Index < EnumerateUserFilesCompleteDelegates.Length; Index++)
		{
			OnRequestComplete = EnumerateUserFilesCompleteDelegates[Index];
			OnRequestComplete(bWasSuccessful, UserRequests[RequestIndex].McpId);
		}
		UserRequests.Remove(RequestIndex, 1);
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
		return true;
	}
	return false;
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
	local String McpId;
	local bool bHasParseError;

	/**
	 * Sample json:
	 *
	 *	[
	 * 		{
	 *			"epicId": "joeg",
	 *			"uniqueFilename": "b6df6321525a448b9ba26fcca4b5e195",
	 *			"filename": "JGEMS.ini",
	 *			"hash": "59a4847e1f3d5bf8bc936d08827c8bd99b3cf698",
	 *			"length": 39
	 *		}
	 *	]
	 */
	if (!JsonNode.HasKey("uniqueFilename") || !JsonNode.HasKey("epicId"))
	{
		return false;
	}
	UniqueFileName = JsonNode.GetStringValue("uniqueFilename");
	McpId = JsonNode.GetStringValue("epicId");

	FileIndex = EmsFiles.Find('DLName', UniqueFileName);
	if (FileIndex == INDEX_NONE)
	{
		// Not in our list, so add it
		FileIndex = EmsFiles.Length;
		EmsFiles.Length = FileIndex + 1;
		EmsFiles[FileIndex].McpId = McpId;
		EmsFiles[FileIndex].DLName = UniqueFileName;
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
		EmsFiles[FileIndex].FileSize = JsonNode.GetIntValue("length");
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
 * Starts an asynchronous read of the specified user file from the network platform's file store
 *
 * @param UserId User owning the storage
 * @param FileToRead the name of the file to read
 *
 * @return true if the calls starts successfully, false otherwise
 */
function bool ReadUserFile(string UserId,string FileName)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	local int FileIndex;
	local delegate<OnReadUserFileComplete> OnRequestComplete;
	local int DelegateIndex;

	// If we already have the data, skip the downloading from the server
	FileIndex = FindUserFileIndex(UserId, FileName);
	if (FileIndex != INDEX_NONE && EmsFiles[FileIndex].Data.Length > 0)
	{
		`LogMcp("Data is already downloaded, skipping server read");
		for (DelegateIndex = 0; DelegateIndex < ReadUserFileCompleteDelegates.Length; DelegateIndex++)
		{
			OnRequestComplete = ReadUserFileCompleteDelegates[DelegateIndex];
			OnRequestComplete(true, UserId, FileName);
		}
		return true;
	}

	Request = CreateHttpRequest(UserId);

	Url = GetBaseURL() $ BuildFileResourcePath(UserId, FileName);
	`LogMcp("ReadUserFile URL is GET " $ Url);

	// Build our web request with the above URL
	Request.SetURL(Url);
	Request.SetVerb("GET");
	// This API does not consume json
	Request.SetHeader("Content-Type", "text/html");
	Request.SetProcessRequestCompleteDelegate(OnReadUserFileRequestComplete);

	AddAt = UserFileRequests.Length;
	UserFileRequests.Length = AddAt + 1;
	UserFileRequests[AddAt].Request = Request;
	UserFileRequests[AddAt].McpId = UserId;
	UserFileRequests[AddAt].FileName = FileName;

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start ReadUserFile web request for URL(" $ Url $ ")");
		return false;
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
function OnReadUserFileRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local array<byte> Data;
	local int Index;
	local delegate<OnReadUserFileComplete> OnRequestComplete;
	local int RequestIndex;

	RequestIndex = UserFileRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
	{
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
			Response.GetContent(Data);
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (bWasSuccessful)
		{
			Index = FindUserFileIndex(UserFileRequests[RequestIndex].McpId, UserFileRequests[RequestIndex].FileName);
			if (Index == INDEX_NONE)
			{
				// This file was requested manually and not discovered through enumeration so automatically add it
				Index = EmsFiles.Length;
				EmsFiles.Length = EmsFiles.Length + 1;
				EmsFiles[Index].McpId = UserFileRequests[RequestIndex].McpId;
				EmsFiles[Index].FileName = UserFileRequests[RequestIndex].FileName;
				EmsFiles[Index].DLName = UserFileRequests[RequestIndex].FileName;
			}
			EmsFiles[Index].Data = Data;
		}
		else
		{
			ErrorString = "ReadUserFile failed with response code (" $ ResponseCode $ ")";
		}
		if (!bWasSuccessful && Len(ErrorString) > 0)
		{
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		for (Index = 0; Index < ReadUserFileCompleteDelegates.Length; Index++)
		{
			OnRequestComplete = ReadUserFileCompleteDelegates[Index];
			OnRequestComplete(bWasSuccessful, UserFileRequests[RequestIndex].McpId, UserFileRequests[RequestIndex].FileName);
		}
		UserFileRequests.Remove(RequestIndex, 1);
	}
}

/**
 * Starts an asynchronous delete of the specified user file from the network platform's file store
 *
 * @param UserId User owning the storage
 * @param FileToRead the name of the file to read
 * @param bShouldCloudDelete ignored
 * @param bShouldLocallyDelete ignored
 *
 * @return true if the calls starts successfully, false otherwise
 */
function bool DeleteUserFile(string UserId,string FileName,bool bShouldCloudDelete,bool bShouldLocallyDelete)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;

	Request = CreateHttpRequest(UserId);

	Url = GetBaseURL() $ BuildFileResourcePath(UserId, FileName);
	`LogMcp("DeleteUserFile URL is DELETE " $ Url);

	// Build our web request with the above URL
	Request.SetURL(Url);
	Request.SetVerb("DELETE");
	Request.SetProcessRequestCompleteDelegate(OnDeleteUserFileRequestComplete);

	AddAt = UserFileRequests.Length;
	UserFileRequests.Length = AddAt + 1;
	UserFileRequests[AddAt].Request = Request;
	UserFileRequests[AddAt].McpId = UserId;
	UserFileRequests[AddAt].FileName = FileName;

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start DeleteUserFile web request for URL(" $ Url $ ")");
		return false;
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
function OnDeleteUserFileRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local int Index;
	local delegate<OnDeleteUserFileComplete> OnRequestComplete;
	local int RequestIndex;

	RequestIndex = UserFileRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
	{
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
			// Delete our local info
			Index = FindUserFileIndex(UserFileRequests[RequestIndex].McpId, UserFileRequests[RequestIndex].FileName);
			if (Index != INDEX_NONE)
			{
				EmsFiles.Remove(Index, 1);
			}
		}
		else
		{
			ErrorString = "DeleteUserFile failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		if (!bWasSuccessful && Len(ErrorString) > 0)
		{
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		for (Index = 0; Index < DeleteUserFileCompleteDelegates.Length; Index++)
		{
			OnRequestComplete = DeleteUserFileCompleteDelegates[Index];
			OnRequestComplete(bWasSuccessful, UserFileRequests[RequestIndex].McpId, UserFileRequests[RequestIndex].FileName);
		}
		UserFileRequests.Remove(RequestIndex, 1);
	}
}

/**
 * Starts an asynchronous write of the specified user file to the network platform's file store
 *
 * @param UserId User owning the storage
 * @param FileToWrite the name of the file to write
 * @param FileContents the out buffer to copy the data into
 *
 * @return true if the calls starts successfully, false otherwise
 */
function bool WriteUserFile(string UserId,string FileName,const out array<byte> FileContents)
{
	local String Url;
	local HttpRequestInterface Request;
	local int AddAt;
	local int RequestIndex;
	local McpUserManagerBase UserManager;
	local String AuthToken;
	local delegate<OnWriteUserFileComplete> OnRequestComplete;
	local int Index;
	
	RequestIndex = UserFileRequests.Find('FileName', FileName);
	if (RequestIndex != INDEX_NONE && UserFileRequests[RequestIndex].bIsWrite)
	{
		`Log("Cloud save already in progress for McpId (" $ UserId $ ") and file (" $ FileName $ ")");
		return false;
	}

	// See if the user is logged in. If not, skip trying to enumerate
	UserManager = class'McpUserManagerBase'.static.CreateInstance();
	if (UserManager != None)
	{
		AuthToken = UserManager.GetAuthToken(UserId);
	}
	if (AuthToken == "")
	{
		`Log("No auth token for the user; can't cloud save the file");
		for (Index = 0; Index < WriteUserFileCompleteDelegates.Length; Index++)
		{
			OnRequestComplete = WriteUserFileCompleteDelegates[Index];
			OnRequestComplete(false, UserFileRequests[RequestIndex].McpId, UserFileRequests[RequestIndex].FileName);
		}
		return false;
	}

	Request = CreateHttpRequest(UserId);

	Url = GetBaseURL() $ BuildFileResourcePath(UserId, FileName) $ "?filename=" $ FileName;
	`LogMcp("WriteUserFile URL is PUT " $ Url);

	// Build our web request with the above URL
	Request.SetURL(Url);
	Request.SetContent(FileContents);
	Request.SetVerb("PUT");
	Request.SetProcessRequestCompleteDelegate(OnWriteUserFileRequestComplete);

	AddAt = UserFileRequests.Length;
	UserFileRequests.Length = AddAt + 1;
	UserFileRequests[AddAt].Request = Request;
	UserFileRequests[AddAt].McpId = UserId;
	UserFileRequests[AddAt].FileName = FileName;
	UserFileRequests[AddAt].StartTime = class'WorldInfo'.static.GetWorldInfo().TimeSeconds;
	UserFileRequests[AddAt].bIsWrite = true;

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start WriteUserFile web request for URL(" $ Url $ ")");
		return false;
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
function OnWriteUserFileRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local int Index;
	local delegate<OnWriteUserFileComplete> OnRequestComplete;
	local int RequestIndex;
	local String Url;

	RequestIndex = UserFileRequests.Find('Request', Request);
	if (RequestIndex != INDEX_NONE)
	{
		Url = GetBaseURL() $ BuildFileResourcePath(UserFileRequests[RequestIndex].McpId, UserFileRequests[RequestIndex].FileName) $ "?filename=" $ UserFileRequests[RequestIndex].FileName;
		if (Url != "")
		{
			`Log("Elapsed time (" $ class'WorldInfo'.static.GetWorldInfo().TimeSeconds - UserFileRequests[RequestIndex].StartTime $ ") for URL " $ Url);
		}
		ResponseCode = 500;
		if (Response != none)
		{
			ResponseCode = Response.GetResponseCode();
			ResponseString = Response.GetContentAsString();
		}
		// Both of these need to be true for the request to be a success
		bWasSuccessful = bWasSuccessful && IsSuccessCode(ResponseCode);
		if (!bWasSuccessful)
		{
			ErrorString = "WriteUserFile failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
		}
		if (!bWasSuccessful && Len(ErrorString) > 0)
		{
			`LogMcp(ErrorString);
		}
		// Notify anyone waiting on this
		for (Index = 0; Index < WriteUserFileCompleteDelegates.Length; Index++)
		{
			OnRequestComplete = WriteUserFileCompleteDelegates[Index];
			OnRequestComplete(bWasSuccessful, UserFileRequests[RequestIndex].McpId, UserFileRequests[RequestIndex].FileName);
		}
		UserFileRequests.Remove(RequestIndex, 1);
	}
}

/**
 * @return the index of the specified user file or INDEX_NONE if not found
 */
function int FindUserFileIndex(String McpId, String FileName)
{
	local int FileIndex;

	for (FileIndex = 0; FileIndex < EmsFiles.Length; FileIndex++)
	{
		if (EmsFiles[FileIndex].McpId == McpId &&
			EmsFiles[FileIndex].FileName == FileName)
		{
			return FileIndex;
		}
	}
	return INDEX_NONE;
}

/**
 * Returns the list of User files that was returned by the network store
 *
 * @param UserId User owning the storage
 * @param UserFiles out array of file metadata
 */
function GetUserFileList(string UserId,out array<EmsFile> UserFiles)
{
	local int FileIndex;
	local EmsFile File;

	UserFiles.Length = 0;
	for (FileIndex = 0; FileIndex < EmsFiles.Length; FileIndex++)
	{
		if (EmsFiles[FileIndex].McpId == UserId)
		{
			File.DLName = EmsFiles[FileIndex].DLName;
			File.FileName = EmsFiles[FileIndex].FileName;
			File.Hash = EmsFiles[FileIndex].Hash;
			File.FileSize = EmsFiles[FileIndex].FileSize;
			UserFiles.AddItem(File);
		}
	}
}

/**
 * Copies the file data into the specified buffer for the specified file
 *
 * @param UserId User owning the storage
 * @param FileName the name of the file to read
 * @param FileContents the out buffer to copy the data into
 *
 * @return true if the data was copied, false otherwise
 */
function bool GetFileContents(string UserId,string FileName,out array<byte> FileContents)
{
	local int FileIndex;

	FileContents.Length = 0;
	FileIndex = FindUserFileIndex(UserId, FileName);
	if (FileIndex != INDEX_NONE)
	{
		FileContents = EmsFiles[FileIndex].Data;
		return true;
	}
	return false;
}

/**
 * Empties the set of downloaded files if possible (no async tasks outstanding)
 *
 * @param UserId User owning the storage
 *
 * @return true if they could be deleted, false if they could not
 */
function bool ClearFiles(string UserId)
{
	local int FileIndex;

	do
	{
		FileIndex = EmsFiles.Find('McpId', UserId);
		if (FileIndex != INDEX_NONE)
		{
			EmsFiles.Remove(FileIndex, 1);
		}
	}
	until (FileIndex == INDEX_NONE);
	return true;
}

/**
 * Empties the cached data for this file if it is not being downloaded currently
 *
 * @param UserId User owning the storage
 * @param FileName the name of the file to remove from the cache
 *
 * @return true if it could be deleted, false if it could not
 */
function bool ClearFile(string UserId,string FileName)
{
	local int FileIndex;

	for (FileIndex = 0; FileIndex < EmsFiles.Length; FileIndex++)
	{
		if (EmsFiles[FileIndex].McpId == UserId &&
			EmsFiles[FileIndex].FileName == FileName)
		{
			EmsFiles[FileIndex].Data.Length = 0;
			return true;
		}
	}
	return false;
}

/** clears all delegates for e.g. end of level cleanup */
function ClearAllDelegates()
{
	EnumerateUserFilesCompleteDelegates.length = 0;
	ReadUserFileCompleteDelegates.length = 0;
	WriteUserFileCompleteDelegates.length = 0;
	DeleteUserFileCompleteDelegates.length = 0;
}

/**
 * Adds the delegate to the list to be notified when all files have been enumerated
 *
 * @param EnumerateUserFileCompleteDelegate the delegate to add
 *
 */
function AddEnumerateUserFileCompleteDelegate(delegate<OnEnumerateUserFilesComplete> AddDelegate)
{
	if (EnumerateUserFilesCompleteDelegates.Find(AddDelegate) == INDEX_NONE)
	{
		EnumerateUserFilesCompleteDelegates[EnumerateUserFilesCompleteDelegates.Length] = AddDelegate;
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param EnumerateUserFileCompleteDelegate the delegate to remove
 *
 */
function ClearEnumerateUserFileCompleteDelegate(delegate<OnEnumerateUserFilesComplete> ClearDelegate)
{
	local int RemoveIndex;

	RemoveIndex = ReadUserFileCompleteDelegates.Find(ClearDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		ReadUserFileCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Adds the delegate to the list to be notified when a requested file has been read
 *
 * @param ReadUserFileCompleteDelegate the delegate to add
 */
function AddReadUserFileCompleteDelegate(delegate<OnReadUserFileComplete> AddDelegate)
{
	if (ReadUserFileCompleteDelegates.Find(AddDelegate) == INDEX_NONE)
	{
		ReadUserFileCompleteDelegates[ReadUserFileCompleteDelegates.Length] = AddDelegate;
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param ReadUserFileCompleteDelegate the delegate to remove
 */
function ClearReadUserFileCompleteDelegate(delegate<OnReadUserFileComplete> ClearDelegate)
{
	local int RemoveIndex;

	RemoveIndex = ReadUserFileCompleteDelegates.Find(ClearDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		ReadUserFileCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Adds the delegate to the list to be notified when a requested file has been written
 *
 * @param WriteUserFileCompleteDelegate the delegate to add
 */
function AddWriteUserFileCompleteDelegate(delegate<OnWriteUserFileComplete> AddDelegate)
{
	if (WriteUserFileCompleteDelegates.Find(AddDelegate) == INDEX_NONE)
	{
		WriteUserFileCompleteDelegates[WriteUserFileCompleteDelegates.Length] = AddDelegate;
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param WriteUserFileCompleteDelegate the delegate to remove
 */
function ClearWriteUserFileCompleteDelegate(delegate<OnWriteUserFileComplete> ClearDelegate)
{
	local int RemoveIndex;

	RemoveIndex = WriteUserFileCompleteDelegates.Find(ClearDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		WriteUserFileCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Adds the delegate to the list to be notified when a requested file has been deleted
 *
 * @param DeleteUserFileCompleteDelegate the delegate to add
 */
function AddDeleteUserFileCompleteDelegate(delegate<OnDeleteUserFileComplete> AddDelegate)
{
	if (DeleteUserFileCompleteDelegates.Find(AddDelegate) == INDEX_NONE)
	{
		DeleteUserFileCompleteDelegates[DeleteUserFileCompleteDelegates.Length] = AddDelegate;
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param DeleteUserFileCompleteDelegate the delegate to remove
 */
function ClearDeleteUserFileCompleteDelegate(delegate<OnDeleteUserFileComplete> ClearDelegate)
{
	local int RemoveIndex;

	RemoveIndex = DeleteUserFileCompleteDelegates.Find(ClearDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		DeleteUserFileCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Reads the list of people that most recently
 */
function ReadLastNCloudSaveOwners(int Count = 10, String FileName = "")
{
	local String Url;
	local HttpRequestInterface Request;

	Request = CreateHttpRequestGameAuth();

	Url = GetBaseURL() $ LastNResourcePath $ "?count=" $ Count;
	if (FileName != "")
	{
		Url $= "&fileName=" $ FileName;
	}
	`LogMcp("ReadLastNCloudSaveOwners URL is GET " $ Url);

	// Build our web request with the above URL
	Request.SetURL(Url);
	Request.SetVerb("GET");
	Request.SetProcessRequestCompleteDelegate(OnReadLastNCloudSaveOwnersRequestComplete);

	// Now kick off the request
	if (!Request.ProcessRequest())
	{
		`LogMcp("Failed to start ReadLastNCloudSaveOwners web request for URL(" $ Url $ ")");
	}
}

/**
 * Called once the request/response has completed
 * 
 * @param Request the request object that was used
 * @param Response the response object that was generated
 * @param bWasSuccessful whether or not the request completed successfully
 */
function OnReadLastNCloudSaveOwnersRequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bWasSuccessful)
{
	local int ResponseCode;
	local string ErrorString;
	local String ResponseString;
	local String McpId;
	local JsonObject ParsedJson;
	local int JsonIndex;
	local delegate<OnReadLastNCloudSaveOwnersComplete> OnRequestComplete;
	local int Index;

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
			ParsedJson = class'JsonObject'.static.DecodeJson(ResponseString);
			for (JsonIndex = 0; JsonIndex < ParsedJson.ValueArray.Length; JsonIndex++)
			{
				McpId = ParsedJson.ValueArray[JsonIndex];
				if (LastNCloudSaveOwners.Find(McpId) == INDEX_NONE)
				{
					LastNCloudSaveOwners.AddItem(McpId);
				}
			}
		}
	}
	else
	{
		ErrorString = "ReadLastNCloudSaveOwners failed with response code (" $ ResponseCode $ ") and payload:\n" $ ResponseString;
	}
	if (!bWasSuccessful && Len(ErrorString) > 0)
	{
		`LogMcp(ErrorString);
	}
	// Notify anyone waiting on this
	for (Index = 0; Index < ReadLastNCloudSaveOwnersCompleteDelegates.Length; Index++)
	{
		OnRequestComplete = ReadLastNCloudSaveOwnersCompleteDelegates[Index];
		OnRequestComplete(bWasSuccessful);
	}
}

/**
 * Adds the delegate to the list to be notified when a requested file has been deleted
 *
 * @param CompleteDelegate the delegate to add
 */
function AddReadLastNCloudSaveOwnersCompleteDelegate(delegate<OnReadLastNCloudSaveOwnersComplete> CompleteDelegate)
{
	if (ReadLastNCloudSaveOwnersCompleteDelegates.Find(CompleteDelegate) == INDEX_NONE)
	{
		ReadLastNCloudSaveOwnersCompleteDelegates[ReadLastNCloudSaveOwnersCompleteDelegates.Length] = CompleteDelegate;
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param CompleteDelegate the delegate to remove
 */
function ClearReadLastNCloudSaveOwnersCompleteDelegate(delegate<OnReadLastNCloudSaveOwnersComplete> CompleteDelegate)
{
	local int RemoveIndex;

	RemoveIndex = ReadLastNCloudSaveOwnersCompleteDelegates.Find(CompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		ReadLastNCloudSaveOwnersCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Reads the list of people that most recently
 *
 * @param McpIds the out array to copy the data into
 */
function GetLastNCloudSaveOwners(out array<String> McpIds)
{
	McpIds = LastNCloudSaveOwners;
}
