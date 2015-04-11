/**
 * GFxUnitTest_ActionScriptThree.uc
 * Simple unit test to verify Scaleform 4, ActionScript 3 functionality.
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class GFxUnitTest_ActionScriptThree extends GFxMoviePlayer
	dependson(GFxUnitTest_ActionScriptThreeWidget);

/** Reference to the unit test widget within the scene */
var transient GFxUnitTest_ActionScriptThreeWidget UnitTestWidget;

/** Called after all of the widgets with enableInitCallback set to true have been initialized; Used to kick off all of the tests */
event PostWidgetInit()
{
	local array<ASValue> Params;
	super.PostWidgetInit();
	
	// Need the unit test widget to perform most of the tests
	if ( UnitTestWidget == None )
	{
		`warn("Reached PostWidgetInit without the Unit Test Widget being initialized; All subsequent units tests will fail.");
	}

	// Kick off all of the unit tests, starting with the ActionScript ones
	Params.length = 0;
	UnitTestWidget.Invoke( "Callback_RunUnitTest", Params );
}

/**
 * Callback received when a CLIK widget with enableInitCallback set to TRUE is initialized
 *
 * @param WidgetName	Name of the widget initialized
 * @param WidgetPath	Path of the widget initialized
 * @param Widget		Widget that was initialized
 *
 * @return True if the widget was handled by this function, false if it was not
 */
event bool WidgetInitialized( name WidgetName, name WidgetPath, GFxObject Widget )
{
	local bool bResult;

	super.WidgetInitialized( WidgetName, WidgetPath, Widget );
	
	bResult = false;

	switch( WidgetName )
	{
		case 'UnitTestWidget':
			UnitTestWidget = GFxUnitTest_ActionScriptThreeWidget(Widget);
			bResult = true;
			break;
	}

	return bResult;
}

/**
 * AS3 -> UE3 Test: Call a function with an integer parameter to verify parameter passing
 *
 * @param IntParam	Parameter to verify
 *
 * @return True if the parameter matches the expected value; False if it does not
 */
function bool Callback_IntParam( int IntParam )
{
	return ( IntParam == UnitTestWidget.TestInt );
}

/**
 * AS3 -> UE3 Test: Call a function with an unsigned integer parameter to verify parameter passing. Note
 * that UnrealScript does not support unsigned integers, but that is a valid type that could come from
 * an ActionScript call. Here, the ActionScript calls the function with an unsigned integer passed in, but
 * it should still work and be converted to an integer.
 *
 * @param UIntParam	Parameter to verify
 *
 * @return True if the parameter matches the expected value; False if it does not
 */
function bool Callback_UIntParam( int UIntParam )
{
	return ( UIntParam == UnitTestWidget.TestUInt );
}

/**
 * AS3 -> UE3 Test: Call a function with a float parameter to verify parameter passing
 *
 * @param NumParam	Parameter to verify
 *
 * @return True if the parameter matches the expected value; False if it does not
 */
function bool Callback_NumParam( float NumParam )
{
	return ( NumParam ~= UnitTestWidget.TestFloat );
}

/**
 * AS3 -> UE3 Test: Call a function with a bool parameter to verify parameter passing
 *
 * @param BoolParam	Parameter to verify
 *
 * @return True if the parameter matches the expected value; False if it does not
 */
function bool Callback_BoolParam( bool BoolParam )
{
	return ( BoolParam == UnitTestWidget.TestBool );
}

/**
 * AS3 -> UE3 Test: Call a function with a string parameter to verify parameter passing
 *
 * @param StringParam	Parameter to verify
 *
 * @return True if the parameter matches the expected value; False if it does not
 */
function bool Callback_StringParam( string StringParam )
{
	return ( StringParam == UnitTestWidget.TestString );
}

/**
 * AS3 -> UE3 Test: Call a function with multiple, mixed-type parameters to verify parameter passing
 *
 * @param NumParam		First parameter to verify
 * @param BoolParam		Second parameter to verify
 * @param StringParam	Third parameter to verify
 *
 * @return True if the parameters match the expected value; False if any of them do not
 */
function bool Callback_MixedParam( float NumParam, bool BoolParam, string StringParam )
{
	return ( NumParam ~= UnitTestWidget.TestFloat && BoolParam == UnitTestWidget.TestBool && StringParam == UnitTestWidget.TestString );
}

/**
 * AS3 -> UE3 Test: Call a function with an array parameter to verify parameter passing
 *
 * @param ArrayParam	Parameter to verify
 *
 * @return True if all of the members of the array match their expected values; False if any of them do not
 */
function bool Callback_ArrayParam( array<float> ArrayParam )
{
	local bool bSuccess;
	local int Idx;

	bSuccess = true;

	if ( ArrayParam.length == UnitTestWidget.TestArray.length )
	{
		for ( Idx = 0; Idx < ArrayParam.length; ++Idx )
		{
			if ( !( ArrayParam[Idx] ~= UnitTestWidget.TestArray[Idx] ) )
			{
				bSuccess = false;
				break;
			}
		}
	}
	else
	{
		bSuccess = false;
	}

	return bSuccess;
}

/**
 * AS3 -> UE3 Test: Call a function with a struct parameter to verify parameter passing
 *
 * @param StructParam	Parameter to verify
 *
 * @return True if all of the members of the struct match their expected values; False if any of them do not
 */
function bool Callback_StructParam( UnitTestMultiMemberStruct StructParam )
{
	return UnitTestWidget.IsSameAsTestStruct( StructParam );
}

/**
 * AS3 -> UE3 Call: Kick off all of the UnrealScript -> AS3 tests
 *
 * @return True always to signify to AS3 that the call was handled
 */
function bool Callback_RunUnrealScriptTests()
{
	UnitTestWidget.RunUnrealScriptTests();
	return true;
}

defaultproperties
{
	bAutoPlay=true

	WidgetBindings.Add((WidgetName="UnitTestWidget",WidgetClass=class'GFxUnitTest_ActionScriptThreeWidget'))
}