/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionTwoSidedSign extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

cpptext
{
	virtual INT Compile(FMaterialCompiler* Compiler, INT OutputIndex);
	virtual FString GetCaption() const;
}

defaultproperties
{
	MenuCategories(0)="Constants"
}
