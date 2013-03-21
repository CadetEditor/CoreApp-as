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
	public class DeserializeTask
	{
		public var xml				:XML;
		public var type				:Class;
		public var parentTask		:DeserializeTask
		public var instance			:*;
		public var name				:String;
		public var id				:String;
		public var next				:DeserializeTask;
		public var deserializeFunc	:Function;
		
		public function DeserializeTask()
		{
			
		}
	}
}