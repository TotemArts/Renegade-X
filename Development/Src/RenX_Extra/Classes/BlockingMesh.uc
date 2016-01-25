//=============================================================================
// FoliageCollisionVolume:  a vehicle collision solution
// used to collide certain classes of actors
// primary use is to provide collision for non-zero extent traces around static meshes
// Created by Pinheiro, https://forums.epicgames.com/threads/913559-How-to-enable-collision-on-foliage
// Modified by Ruud033
//=============================================================================

class BlockingMesh extends DynamicSMActor_Spawnable; 

defaultproperties 
{ 
    Begin Object Name=StaticMeshComponent0 
        HiddenGame = true //we don't wanna draw this, it's just used to test collision 
        BlockRigidBody=true //DynamicSMActors have collision disabled by default 
		CastShadow=false
		MaxDrawDistance = 500
		bAllowCullDistanceVolume=true
		AlwaysLoadOnServer=false
    End object 
    bCollideActors=true //same here 
    bTickIsDisabled = true //greatly improves performance on the game thread 
	bStatic=false
	bNoDelete=false
}