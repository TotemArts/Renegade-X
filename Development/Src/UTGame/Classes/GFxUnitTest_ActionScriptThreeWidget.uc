/**
 * GFxUnitTest_ActionScriptThreeWidget.uc
 * Widget used in the unit test to verify Scaleform 4, ActionScript 3 functionality.
 *
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class GFxUnitTest_ActionScriptThreeWidget extends GFxObject;

/** Simple test struct with multiple data types */
struct UnitTestMultiMemberStruct
{
	var bool	BoolMember1;
	var bool	BoolMember2;
	var float	FloatMember1;
	var float	FloatMember2;
	var string	StringMember1;
	var bool	BoolMember3;
	var float	FloatMember3;
};

/** Float to be used for testing purposes; Matches corresponding test value in ActionScript 3 */
var transient float TestFloat;

/** Int to be used for testing purposes; Matches corresponding test value in ActionScript 3 */
var transient int TestInt;

/** Int to be used for unsigned integer testing purposes (passed to AS3 function with uint param); Matches corresponding test value in ActionScript 3 */
var transient int TestUInt;

/** Bool to be used for testing purposes; Matches corresponding test value in ActionScript 3 */
var transient bool TestBool;

/** String to be used for testing purposes; Matches corresponding test value in ActionScript 3 */
var transient string TestString;

/** Array to be used for testing purposes; Matches corresponding test values in ActionScript 3 */
var transient array<float> TestArray;

/** Struct to be used for testing purposes; Matches corresponding object in ActionScript 3 */
var transient UnitTestMultiMemberStruct TestStruct;

/** Delegate specifying function signature that will be set to an ActionScript 3 function */
delegate DelegateTest();

/** Helper function to run all of the UE3 -> AS3 tests */
function RunUnrealScriptTests()
{
	local GFXObject ReturnObj;
	local UnitTestMultiMemberStruct ReturnStruct;
	local array<GFXObject> ReturnArray;
	local int Idx;
	local bool bArrayVerified;

	// Int parameter passing tests
	AS_IntParam( TestInt );
	AS_IntParamInvoke( TestInt );

	// UInt parameter passing tests
	AS_UIntParam( TestUInt );
	AS_UIntParamInvoke( TestUInt );

	// Number/float parameter passing tests
	AS_NumberParam( TestFloat );
	AS_NumberParamInvoke( TestFloat );

	// Bool parameter passing tests
	AS_BoolParam( TestBool );
	AS_BoolParamInvoke( TestBool );

	// String parameter passing tests
	AS_StringParam( TestString );
	AS_StringParamInvoke( TestString );

	// Mixed parameter type passing tests
	AS_MixedParam( TestFloat, TestBool, TestString );
	AS_MixedParamInvoke( TestFloat, TestBool, TestString );

	// Array parameter passing test
	AS_ArrayParam( TestArray );

	// Struct parameter passing test
	AS_StructParam( TestStruct );

	// Int return value verification test
	AS_ReturnValueIntVerification( AS_ReturnValueIntTest() == TestInt );

	// Number/float return value verification test
	AS_ReturnValueNumberVerification( AS_ReturnValueNumberTest() ~= TestFloat );

	// String return value verification test
	AS_ReturnValueStringVerification( AS_ReturnValueStringTest() == TestString );
	
	// Object return value verification test
	ReturnObj = AS_ReturnValueGFxObjectTest();
	if ( ReturnObj != None )
	{
		// Populate a test struct from the object members
		ReturnStruct.BoolMember1 = ReturnObj.GetBool( "BoolMember1" );
		ReturnStruct.BoolMember2 = ReturnObj.GetBool( "BoolMember2" );
		ReturnStruct.BoolMember3 = ReturnObj.GetBool( "BoolMember3" );
		ReturnStruct.FloatMember1 = ReturnObj.GetFloat( "FloatMember1" );
		ReturnStruct.FloatMember2 = ReturnObj.GetFloat( "FloatMember2" );
		ReturnStruct.FloatMember3 = ReturnObj.GetFloat( "FloatMember3" );
		ReturnStruct.StringMember1 = ReturnObj.GetString( "StringMember1" );
	}
	AS_ReturnValueGFxObjectVerification( IsSameAsTestStruct( ReturnStruct ) );
	
	// Object array return value verification test
	ReturnArray = AS_ReturnValueObjArrayTest();
	bArrayVerified = true;
	if ( ReturnArray.length != TestArray.length )
	{
		bArrayVerified = false;
	}
	else
	{
		for ( Idx = 0; Idx < ReturnArray.length; ++Idx )
		{
			if ( !( ReturnArray[Idx].GetFloat( "FloatMember1" ) ~= TestArray[Idx] ) )
			{
				bArrayVerified = false;
				break;
			}
		}
	}
	AS_ReturnValueObjArrayVerification( bArrayVerified );

	// Array as an object return value verification test
	bArrayVerified = true;
	ReturnObj = AS_ReturnValueArrayAsObjTest();
	if ( ReturnObj != None )
	{
		for ( Idx = 0; Idx < TestArray.length; ++Idx )
		{
			if ( !( ReturnObj.GetElementFloat( Idx ) ~= TestArray[Idx] ) )
			{
				bArrayVerified = false;
				break;
			}
		}
	}
	else
	{
		bArrayVerified = false;
	}
	AS_ReturnValueArrayAsObjVerification( bArrayVerified );

	// Non-existant function call tests
	AS_NonExistantFunction( TestFloat, TestBool, TestString );
	AS_NonExistantFunctionInvoke( TestFloat, TestBool, TestString );

	// Delegate tests
	AS_SetDelegateTest( Callback_Delegate );
	AS_ForceCallDelegate();

	AS_EndUnrealScriptTests();
}

/**
 * Helper function to determine if the specified struct is equivalent to the test value struct. Performs
 * approximate comparison on the float members to handle potential inaccuracies from single<->double precision
 * conversions going from UE3 <-> ActionScript.
 *
 * @param InStruct	Struct to test for equality
 *
 * @return True if the specified struct is equivalent to the test value struct
 */
function bool IsSameAsTestStruct( const out UnitTestMultiMemberStruct InStruct )
{
	return ( InStruct.BoolMember1 == TestStruct.BoolMember1 &&
			InStruct.BoolMember2 == TestStruct.BoolMember2 && 
			InStruct.BoolMember3 == TestStruct.BoolMember3 &&
			InStruct.FloatMember1 ~= TestStruct.FloatMember1 &&
			InStruct.FloatMember2 ~= TestStruct.FloatMember2 &&
			InStruct.FloatMember3 ~= TestStruct.FloatMember3 &&
			InStruct.StringMember1 == TestStruct.StringMember1 );
}

/** UE3 -> AS3 Call: Signify the end of UE3 -> AS3 tests so that AS3 knows to check for tests it didn't receive */
function AS_EndUnrealScriptTests()
{
	ActionScriptVoid( "Callback_EndUnrealScriptTests" );
}

/**
 * UE3 -> AS3 Test: Integer parameter passing
 *
 * @param IntParam	Parameter to pass to AS3
 */
function AS_IntParam( int IntParam )
{
	ActionScriptVoid( "Callback_IntParam" );
}

/**
 * UE3 -> AS3 Test: Integer parameter passing via Invoke
 *
 * @param IntParam	Parameter to pass to AS3
 */
function AS_IntParamInvoke( int IntParam )
{
	local array<ASValue> Params;
	local ASValue ASVal;

	// @todo: This is wrong, needs to be updated to actually be an integer but that type support doesn't exist yet (pending integration)
	ASVal.Type = AS_Number;
	ASVal.n = IntParam;
	Params.AddItem( ASVal );

	Invoke( "Callback_IntParamInvoke", Params );
}

/**
 * UE3 -> AS3 Test: Unsigned integer parameter passing. Note that UnrealScript does not support unsigned integers, but ActionScript 3 does.
 * The function that will be called on the AS3 side takes an unsigned int parameter and we are passing an integer parameter here to verify
 * that the function is called with the parameter coerced.
 *
 * @param UIntParam	Parameter to pass to AS3
 */
function AS_UIntParam( int UIntParam )
{
	ActionScriptVoid( "Callback_UIntParam" );
}

/**
 * UE3 -> AS3 Test: Unsigned integer parameter passing via Invoke. Note that UnrealScript does not support unsigned integers, but ActionScript 3 does.
 * The function that will be called on the AS3 side takes an unsigned int parameter and we are passing an integer parameter here to verify
 * that the function is called with the parameter coerced.
 *
 * @param UIntParam	Parameter to pass to AS3
 */
function AS_UIntParamInvoke( int UIntParam )
{
	local array<ASValue> Params;
	local ASValue ASVal;

	// @todo: This is wrong, needs to be updated to actually be an unsigned integer but that type support doesn't exist yet (pending integration)
	ASVal.Type = AS_Number;
	ASVal.n = UIntParam;
	Params.AddItem( ASVal );

	Invoke( "Callback_UIntParamInvoke", Params );
}

/**
 * UE3 -> AS3 Test: Float/Number parameter passing
 *
 * @param NumParam	Parameter to pass to AS3
 */
function AS_NumberParam( float NumParam )
{
	ActionScriptVoid( "Callback_NumberParam" );
}

/**
 * UE3 -> AS3 Test: Float/Number parameter passing via Invoke
 *
 * @param NumParam	Parameter to pass to AS3
 */
function AS_NumberParamInvoke( float NumParam )
{
	local array<ASValue> Params;
	local ASValue ASVal;

	ASVal.Type = AS_Number;
	ASVal.n = NumParam;
	Params.AddItem( ASVal );

	Invoke( "Callback_NumberParamInvoke", Params );
}

/**
 * UE3 -> AS3 Test: Bool parameter passing
 *
 * @param BoolParam	Parameter to pass to AS3
 */
function AS_BoolParam( bool BoolParam )
{
	ActionScriptVoid( "Callback_BoolParam" );
}

/**
 * UE3 -> AS3 Test: Bool parameter passing via Invoke
 *
 * @param BoolParam	Parameter to pass to AS3
 */
function AS_BoolParamInvoke( bool BoolParam )
{
	local array<ASValue> Params;
	local ASValue ASVal;

	ASVal.Type = AS_Boolean;
	ASVal.b = BoolParam;
	Params.AddItem( ASVal );

	Invoke( "Callback_BoolParamInvoke", Params );
}

/**
 * UE3 -> AS3 Test: String parameter passing
 *
 * @param StringParam	Parameter to pass to AS3
 */
function AS_StringParam( string StringParam )
{
	ActionScriptVoid( "Callback_StringParam" );
}


/**
 * UE3 -> AS3 Test: String parameter passing via Invoke
 *
 * @param StringParam	Parameter to pass to AS3
 */
function AS_StringParamInvoke( string StringParam )
{
	local array<ASValue> Params;
	local ASValue ASVal;

	ASVal.Type = AS_String;
	ASVal.s = StringParam;
	Params.AddItem( ASVal );

	Invoke( "Callback_StringParamInvoke", Params );
}


/**
 * UE3 -> AS3 Test: Multiple, mixed-type parameter passing
 *
 * @param NumParam		First parameter to pass to AS3
 * @param BoolParam		Second parameter to pass to AS3
 * @param StringParam	Third paramter to pass to AS3
 */
function AS_MixedParam( float NumParam, bool BoolParam, string StringParam )
{
	ActionScriptVoid( "Callback_MixedParam" );
}

/**
 * UE3 -> AS3 Test: Multiple, mixed-type parameter passing via Invoke
 *
 * @param NumParam		First parameter to pass to AS3
 * @param BoolParam		Second parameter to pass to AS3
 * @param StringParam	Third paramter to pass to AS3
 */
function AS_MixedParamInvoke( float NumParam, bool BoolParam, string StringParam )
{
	local array<ASValue> Params;
	local ASValue ASVal;

	ASVal.Type = AS_Number;
	ASVal.n = NumParam;
	Params.AddItem( ASVal );

	ASVal.Type = AS_Boolean;
	ASVal.b = BoolParam;
	Params.AddItem( ASVal );

	ASVal.Type = AS_String;
	ASVal.s = StringParam;
	Params.AddItem( ASVal );

	Invoke( "Callback_MixedParamInvoke", Params );
}

/**
 * UE3 -> AS3 Test: Array parameter passing
 *
 * @param ArrayParam	Parameter to pass to AS3
 */
function AS_ArrayParam( array<float> ArrayParam )
{
	ActionScriptVoid( "Callback_ArrayParam" );
}

/**
 * UE3 -> AS3 Test: Struct parameter passing
 *
 * @param StructParam	Parameter to pass to AS3
 */
function AS_StructParam( UnitTestMultiMemberStruct StructParam )
{
	ActionScriptVoid( "Callback_StructParam" );
}

/**
 * UE3 -> AS3 Test: Part one of a two-part ActionScript return value verification test with an integer return type.
 * Calls the ActionScript function and returns the value that the AS function returns.
 *
 * @return The return value from the ActionScript function
 */
function int AS_ReturnValueIntTest()
{
	return ActionScriptInt( "Callback_IntReturnVal" );
}

/**
 * UE3 -> AS3 Test: Part two of a two-part ActionScript return value verification test. Calls an AS3 function to alert
 * AS3 as to whether the return value from part one was the expected value or not.
 *
 * @param bVerified	Whether or not the return value of part one was verified
 */
function AS_ReturnValueIntVerification( bool bVerified )
{
	ActionScriptVoid( "Callback_IntReturnValVerification" );
}

/**
 * UE3 -> AS3 Test: Part one of a two-part ActionScript return value verification test with a float return type.
 * Calls the ActionScript function and returns the value that the AS function returns.
 *
 * @return The return value from the ActionScript function
 */
function float AS_ReturnValueNumberTest()
{
	return ActionScriptFloat( "Callback_NumberReturnVal" );
}

/**
 * UE3 -> AS3 Test: Part two of a two-part ActionScript return value verification test. Calls an AS3 function to alert
 * AS3 as to whether the return value from part one was the expected value or not.
 *
 * @param bVerified	Whether or not the return value of part one was verified
 */
function AS_ReturnValueNumberVerification( bool bVerified )
{
	ActionScriptVoid( "Callback_NumberReturnValVerification" );
}

/**
 * UE3 -> AS3 Test: Part one of a two-part ActionScript return value verification test with a string return type.
 * Calls the ActionScript function and returns the value that the AS function returns.
 *
 * @return The return value from the ActionScript function
 */
function string AS_ReturnValueStringTest()
{
	return ActionScriptString( "Callback_StringReturnVal" );
}

/**
 * UE3 -> AS3 Test: Part two of a two-part ActionScript return value verification test. Calls an AS3 function to alert
 * AS3 as to whether the return value from part one was the expected value or not.
 *
 * @param bVerified	Whether or not the return value of part one was verified
 */
function AS_ReturnValueStringVerification( bool bVerified )
{
	ActionScriptVoid( "Callback_StringReturnValVerification" );
}

/**
 * UE3 -> AS3 Test: Part one of a two-part ActionScript return value verification test with an object return type.
 * Calls the ActionScript function and returns the value that the AS function returns.
 *
 * @return The return value from the ActionScript function
 */
function GFXObject AS_ReturnValueGFxObjectTest()
{
	return ActionScriptObject( "Callback_ObjectReturnVal" );
}

/**
 * UE3 -> AS3 Test: Part two of a two-part ActionScript return value verification test. Calls an AS3 function to alert
 * AS3 as to whether the return value from part one was the expected value or not.
 *
 * @param bVerified	Whether or not the return value of part one was verified
 */
function AS_ReturnValueGFxObjectVerification( bool bVerified )
{
	ActionScriptVoid( "Callback_ObjectReturnValVerification" );
}

/**
 * UE3 -> AS3 Test: Part one of a two-part ActionScript return value verification test with an array of objects return type.
 * Calls the ActionScript function and returns the value that the AS function returns.
 *
 * @return The return value from the ActionScript function
 */
function array<GFxObject> AS_ReturnValueObjArrayTest()
{
	return ActionScriptArray( "Callback_ObjArrayReturnVal" );
}

/**
 * UE3 -> AS3 Test: Part two of a two-part ActionScript return value verification test. Calls an AS3 function to alert
 * AS3 as to whether the return value from part one was the expected value or not.
 *
 * @param bVerified	Whether or not the return value of part one was verified
 */
function AS_ReturnValueObjArrayVerification( bool bVerified )
{
	ActionScriptVoid( "Callback_ObjArrayReturnValVerification" );
}

/**
 * UE3 -> AS3 Test: Part one of a two-part ActionScript return value verification test with an array as an object return type.
 * Calls the ActionScript function and returns the value that the AS function returns.
 *
 * @return The return value from the ActionScript function
 */
function GFXObject AS_ReturnValueArrayAsObjTest()
{
	return ActionScriptObject( "Callback_ArrayAsObjReturnVal" );
}

/**
 * UE3 -> AS3 Test: Part two of a two-part ActionScript return value verification test. Calls an AS3 function to alert
 * AS3 as to whether the return value from part one was the expected value or not.
 *
 * @param bVerified	Whether or not the return value of part one was verified
 */
function AS_ReturnValueArrayAsObjVerification( bool bVerified )
{
	ActionScriptVoid( "Callback_ArrayAsObjReturnValVerification" );
}

/**
 * UE3 -> AS3 Test: Set a function in AS3 to call the specified delegate
 *
 * @param Callback	Delegate that should be called from AS3
 */
function AS_SetDelegateTest( delegate<DelegateTest> Callback )
{
	ActionScriptSetFunction( "Callback_DelegateTest" );
}

/** AS3 -> UE3 Test: Delegate function that should be called by ActionScript if the function-setting test succeeds. */
function Callback_Delegate()
{
	ActionScriptVoid( "Callback_DelegateReceived" );
}

/** UE3 -> AS3 Test: Force ActionScript to call the delegate that should be hooked up from AS_SetDelegateTest() */
function AS_ForceCallDelegate()
{
	ActionScriptVoid( "Callback_ForceCallDelegate" );
}

/**
 * UE3 -> AS3 Test: Call a function that doesn't exist in ActionScript 3 to verify that it doesn't crash
 *
 * @param NumParam		Unused, dummy param
 * @param BoolParam		Unused, dummy param
 * @param StringParam	Unused, dummy param
 */
function AS_NonExistantFunction( float NumParam, bool BoolParam, string StringParam )
{
	ActionScriptVoid( "NonsenseFunctionThatDoesntExist" );
}

/**
 * UE3 -> AS3 Test: Call a function that doesn't exist in ActionScript 3 via Invoke to verify that it doesn't crash
 *
 * @param NumParam		Unused, dummy param
 * @param BoolParam		Unused, dummy param
 * @param StringParam	Unused, dummy param
 */
function AS_NonExistantFunctionInvoke( float NumParam, bool BoolParam, string StringParam )
{
	local array<ASValue> Params;
	local ASValue ASVal;

	ASVal.Type = AS_Number;
	ASVal.n = NumParam;
	Params.AddItem( ASVal );

	ASVal.Type = AS_Boolean;
	ASVal.b = BoolParam;
	Params.AddItem( ASVal );

	ASVal.Type = AS_String;
	ASVal.s = StringParam;
	Params.AddItem( ASVal );

	Invoke( "NonsenseFunctionThatDoestExistInvoke", Params );
}

defaultproperties
{
	TestFloat=175.75f
	TestInt=-225
	TestUInt=100
	TestBool=true
	TestString="Hello, World!"
	TestArray(0)=255.25
	TestArray(1)=105.2
	TestArray(2)=2.66
	TestStruct=(BoolMember1=true,BoolMember2=true,BoolMember3=true,FloatMember1=255.25,FloatMember2=105.2,FloatMember3=2.66,StringMember1="Hello, World!")
}