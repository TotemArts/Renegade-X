/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
//=============================================================================
// GenericBrowserType_TextureCube: Generic browser type for cubemaps
//=============================================================================

class GenericBrowserType_TextureCube
	extends GenericBrowserType_Texture
	native;

cpptext
{
	/** Initialize this generic browser type */
	virtual void Init();
}
	
defaultproperties
{
	Description="TextureCubes"
}
