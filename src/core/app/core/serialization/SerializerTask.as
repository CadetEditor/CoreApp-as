// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.core.serialization
{
	public class SerializerTask
	{
		public var obj				:Object;
		public var propertyName		:String;
		public var propertyAlias	:String;
		public var value			:*
		public var id				:int;
		public var parentXML		:XML;
		public var manifest			:Manifest;
		public var serializeFunc	:Function;
		
		public function SerializerTask()
		{
			
		}
	}
}