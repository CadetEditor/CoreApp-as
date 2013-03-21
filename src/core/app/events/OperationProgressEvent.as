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

	public class OperationProgressEvent extends Event
	{
		public static const PROGRESS		:String = "progress"
		
		protected var _progress	:Number;
		
		public function OperationProgressEvent( type:String, progress:Number )
		{
			super(type);
			_progress = progress;
		}
		
		override public function clone():Event
		{
			return new OperationProgressEvent( type, progress );
		}
		
		public function get progress():Number { return _progress; }
	}
}