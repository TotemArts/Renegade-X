//! @file ImageInputThumbnailRenderer.uc
//! @author Antoine Gonzalez - Allegorithmic
//! @copyright Allegorithmic. All rights reserved.
//!
//! @brief This thumbnail renderer displays the texture for the object in question

class ImageInputThumbnailRenderer extends ThumbnailRenderer
	native(ThumbnailRenderer);

cpptext
{
	virtual UBOOL SupportsCPUGeneratedThumbnail(UObject *InObject) const
    {
        return TRUE;
    }

	void GetThumbnailSize(UObject* InObject,EThumbnailPrimType,FLOAT Zoom,DWORD& OutWidth,DWORD& OutHeight);

	virtual void Draw(UObject* Object,EThumbnailPrimType,
		INT X,INT Y,DWORD Width,DWORD Height,FRenderTarget*,
		FCanvas* Canvas,EThumbnailBackgroundType /*BackgroundType*/,
		FColor PreviewBackgroundColor,
		FColor PreviewBackgroundColorTranslucent)
	{
	}

	virtual void DrawCPU( UObject* InObject, FObjectThumbnail& OutThumbnailBuffer) const;
}
