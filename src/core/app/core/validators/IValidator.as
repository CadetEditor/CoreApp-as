// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.core.validators
{
	import flash.events.IEventDispatcher;
	
	[Event(type="core.app.events.ValidatorEvent", name="stateChanged")]
	
	public interface IValidator extends IEventDispatcher
	{
		function dispose():void;
		function get state():Boolean;
	}
}