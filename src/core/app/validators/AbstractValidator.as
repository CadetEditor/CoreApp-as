// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.validators
{
	import flash.events.EventDispatcher;
	
	import core.app.core.validators.IValidator;
	import core.app.events.ValidatorEvent;

	[Event(name="stateChanged", type="core.app.events.ValidatorEvent")]
	
	public class AbstractValidator extends EventDispatcher implements IValidator
	{
		protected var _state		:Boolean = false;
		
		private var firstSet		:Boolean = false;
		
		public function AbstractValidator()
		{
			
		}

		public function dispose():void {}
		
		public function get state():Boolean { return _state; }
		protected function setState( value:Boolean ):void
		{
			if ( value == _state && !firstSet ) return;
			firstSet = true;
			_state = value;
			dispatchEvent( new ValidatorEvent( ValidatorEvent.STATE_CHANGED, _state ) );
		}
	}
}