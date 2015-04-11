/** 
 * Geometry exporter interface used for navmesh generation (Recast)
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

interface Interface_PylonGeometryProvider
	native(AI);

cpptext
{
	/**
	 * Exports all path colliding geometry within pylon's bounds
	 * @param Pylon - bounding pylon
	 * @param Verts - list of exported vertices 
	 * @param Faces - list of exported triangles, 3 indices to Verts array for each item
	 */
	virtual void GetPathCollidingGeometry(APylon* Pylon, TArray<FVector>& Verts, TArray<INT>& Faces) {};
}
