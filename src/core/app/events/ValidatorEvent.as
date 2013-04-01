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

	public class ValidatorEvent extends Event
	{
		public static const	STATE_CHANGED	:String = "stateChanged"
		
		private var _state		:Boolean;
		
		public function ValidatorEvent(type:String, state:Boolean)
		{
			super(type);
			_state = state;
		}
		
		override public function clone():Event
		{
			return new ValidatorEvent( type, _state );
		}
		
		public function get state():Boolean { return _state; }
		
	}
}