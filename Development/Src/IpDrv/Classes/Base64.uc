/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 *
 * Class for encoding/decoding Base64 data
 */
class Base64 extends Object
	native;

/**
 * Encodes the binary array of data as a string in Base64
 *
 * @param Source the binary data to encode
 *
 * @return the string form of the data
 */
static native function String Encode(const out array<byte> Source);

/**
 * Decodes the string array of Base64 data as a byte array
 *
 * @param Source the string data to decode
 * @param Dest the buffer the data is copied into
 */
static native function Decode(String Source, out array<byte> Dest);

/**
 * Encodes a string in Base64
 *
 * @param Source the binary data to encode
 *
 * @return the Base64 string form of the data
 */
static native function String EncodeString(String Source);

/**
 * Decodes the Base64 string into the original string form
 *
 * @param Source the string data to decode
 *
 * @return the original string
 */
static native function String DecodeString(String Source);


/**
 * Runs a series of tests to verify the encoding/decoding are consistent
 */
static function TestStringVersion()
{
	local String ThreeByteString;
	local String FourByteString;
	local String FiveByteString;
	local String InternetSample;
	local String EncodedString;
	local String DecodedString;

	ThreeByteString = "123";
	FourByteString = "1234";
	FiveByteString = "12345";
	// See the padding section of: http://en.wikipedia.org/wiki/Base64
	InternetSample = "any carnal pleasure.";

	// Encode ThreeByteString which should return a 4 byte string
	EncodedString = EncodeString(InternetSample);
	if (EncodedString != "YW55IGNhcm5hbCBwbGVhc3VyZS4=")
	{
		`Log("Encoding of InternetSample returned different data than expected, got (" $ EncodedString $ "), expected (YW55IGNhcm5hbCBwbGVhc3VyZS4=)");
	}
	else
	{
		`Log("InternetSample encoding test passed");
	}
	DecodedString = DecodeString(EncodedString);
	if (DecodedString != InternetSample)
	{
		`Log("Decoding of InternetSample returned the wrong string, got (" $ DecodedString $ "), expected (" $ InternetSample $ ")");
	}
	else
	{
		`Log("InternetSample decoding test passed");
	}

	// Encode ThreeByteString which should return a 4 byte string
	EncodedString = EncodeString(ThreeByteString);
	if (Len(EncodedString) != 4)
	{
		`Log("Encoding of ThreeByteString returned the wrong number of characters, got (" $ Len(EncodedString) $ "), expected (4)");
	}
	DecodedString = DecodeString(EncodedString);
	if (DecodedString != ThreeByteString)
	{
		`Log("Decoding of ThreeByteString returned the wrong string, got (" $ DecodedString $ "), expected (" $ ThreeByteString $ ")");
	}
	else
	{
		`Log("ThreeByteString test passed");
	}

	// Encode FourByteString which should return a 8 byte string
	EncodedString = EncodeString(FourByteString);
	if (Len(EncodedString) != 8)
	{
		`Log("Encoding of FourByteString returned the wrong number of characters, got (" $ Len(EncodedString) $ "), expected (8)");
	}
	DecodedString = DecodeString(EncodedString);
	if (DecodedString != FourByteString)
	{
		`Log("Decoding of FourByteString returned the wrong string, got (" $ DecodedString $ "), expected (" $ FourByteString $ ")");
	}
	else
	{
		`Log("FourByteString test passed");
	}

	// Encode FiveByteString which should return a 8 byte string
	EncodedString = EncodeString(FiveByteString);
	if (Len(EncodedString) != 8)
	{
		`Log("Encoding of FiveByteString returned the wrong number of characters, got (" $ Len(EncodedString) $ "), expected (8)");
	}
	DecodedString = DecodeString(EncodedString);
	if (DecodedString != FiveByteString)
	{
		`Log("Decoding of FiveByteString returned the wrong string, got (" $ DecodedString $ "), expected (" $ FiveByteString $ ")");
	}
	else
	{
		`Log("FiveByteString test passed");
	}
}