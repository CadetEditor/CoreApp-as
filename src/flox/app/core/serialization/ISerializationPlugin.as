// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.core.serialization
{
	public interface ISerializationPlugin
	{
		function get id():String
		function serialize( task:SerializerTask ):XML
		function deserialize( task:DeserializeTask ):void
		function get allowNullValue():Boolean;
	}
}