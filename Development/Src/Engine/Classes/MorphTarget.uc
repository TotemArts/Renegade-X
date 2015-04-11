/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class MorphTarget extends Object
	native(Anim)
	noexport
	hidecategories(Object);
	
/** morph mesh vertex data for each LOD */
var	const native array<int>		MorphLODModels; 

/** Material Parameter control **/
var(Material)				INT							MaterialSlotId;
var(Material)				Name						ScalarParameterName;
