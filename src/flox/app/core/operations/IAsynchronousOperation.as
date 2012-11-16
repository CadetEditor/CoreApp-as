// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.core.operations
{
	import flash.events.IEventDispatcher;
	import flox.app.core.operations.IOperation;

	[Event(type="flox.app.events.OperationProgressEvent", name="progress")]
	[Event(type="flash.events.Event", name="complete")]
	[Event(type="flash.events.ErrorEvent", name="error")]
	
	/**
	 * This interface extends the basic IOperation interface. Whereas an IOperation will be
	 * treated as synchronous, any operation implementing this will be treated asynchronously.
	 * @author Jonathan
	 * 
	 */	
	public interface IAsynchronousOperation extends IOperation, IEventDispatcher
	{
		
	}
}