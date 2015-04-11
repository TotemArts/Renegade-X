/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class UTCTFGame_Content extends UTCTFGame;

defaultproperties
{
	HUDType=class'UTGame.UTCTFHUD'

	AnnouncerMessageClass=class'UTCTFMessage'
 	TeamScoreMessageClass=class'UTGameContent.UTTeamScoreMessage'
}
