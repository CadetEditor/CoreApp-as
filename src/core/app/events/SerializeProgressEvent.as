// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jon
	 */
	public class SerializeProgressEvent extends Event 
	{
		public static const PROGRESS		:String = "progress";
		
		public var numItems	:int;
		public var totalItems:int;
		
		public function SerializeProgressEvent(type:String)
		{
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			var event:SerializeProgressEvent = new SerializeProgressEvent(SerializeProgressEvent.PROGRESS);
			event.numItems = numItems;
			event.totalItems = totalItems;
			return event;
		}
		
	}

}