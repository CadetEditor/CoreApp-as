// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.events 
{
	import flash.events.Event;
	
	public class PropertyChangeEvent extends Event 
	{
		private var _propertyName	:String;
		private var _oldValue		:*;
		private var _newValue		:*;
		
		public function PropertyChangeEvent( type:String, oldValue:*, newValue:* ):void
		{
			super( type, false, false );
			
			if ( type.indexOf( "propertyChange_" ) == -1 )
			{
				throw( new Error( "Invalid event type for PropertyChangeEvent. Must be of the form 'propertyChange_<propertyName>' " ) );
				return;
			}
			
			_propertyName = type.substring( 15 );
			_oldValue = oldValue;
			_newValue = newValue;
		}
		
		override public function clone():Event
		{
			return new PropertyChangeEvent( type, _oldValue, _newValue );
		}
		
		public function get propertyName():String
		{
			return _propertyName;
		}
		
		public function get oldValue():*
		{
			return _oldValue;
		}
		
		public function get newValue():*
		{
			return _newValue;;
		}
	}
}