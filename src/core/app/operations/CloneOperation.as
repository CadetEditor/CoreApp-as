// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.operations
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.core.serialization.Deserializer;
	import core.app.core.serialization.ISerializationPlugin;
	import core.app.core.serialization.Serializer;
	import core.app.events.OperationProgressEvent;
	import core.app.events.SerializeProgressEvent;
	
	[Event(type="core.app.events.OperationProgressEvent", name="progress")]
	[Event(type="flash.events.Event", name="complete")]
	[Event(type="flash.events.ErrorEvent", name="error")]
	
	/**
	 * This Operation wraps up a call to the bones.core.serialization.Serializer.cloneAsync() method.
	 * The Serializer dispatches its own progress and complete events, which this Operation re-dispatches
	 * as OperationEvent's. 
	 * @author Jonathan
	 * 
	 */	
	public class CloneOperation extends EventDispatcher implements IAsynchronousOperation
	{
		private var serializer		:Serializer;
		private var deserializer	:Deserializer;
		private var result			:*;
		private var item			:*;
		
		public function CloneOperation( item:*, plugins:Vector.<ISerializationPlugin> = null )
		{
			this.item = item;
			
			serializer = new Serializer();
			serializer.addEventListener( Event.COMPLETE, serializeCompleteHandler );
			serializer.addEventListener( SerializeProgressEvent.PROGRESS, serializeProgressHandler );
			
			deserializer = new Deserializer();
			deserializer.addEventListener( Event.COMPLETE, deserializeCompleteHandler );
			deserializer.addEventListener( SerializeProgressEvent.PROGRESS, deserializeProgressHandler );
			
			if ( plugins )
			{
				for each ( var plugin:ISerializationPlugin in plugins )
				{
					serializer.addPlugin( plugin );
					deserializer.addPlugin( plugin );
				}
			}
		}

		public function execute():void
		{
			serializer.serializeAsync( item );
		}
		
		private function serializeCompleteHandler( event:Event ):void
		{
			deserializer.deserializeAsync( serializer.getResult() );
		}
		
		private function deserializeCompleteHandler( event:Event ):void
		{
			result = deserializer.getResult();
			dispose();
			
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function serializeProgressHandler( event:SerializeProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, (event.numItems / event.totalItems) * 0.2 ) );
		}
		
		private function deserializeProgressHandler( event:SerializeProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, 0.2 + (event.numItems / event.totalItems) * 0.8 ) );
		}
		
		private function dispose():void
		{
			serializer.removeEventListener( Event.COMPLETE, serializeCompleteHandler );
			serializer.removeEventListener( SerializeProgressEvent.PROGRESS, serializeProgressHandler );
			deserializer.removeEventListener( Event.COMPLETE, deserializeCompleteHandler );
			deserializer.removeEventListener( SerializeProgressEvent.PROGRESS, deserializeProgressHandler );
		}
		
		public function getResult():* { return result; }
		
		public function get label():String
		{
			return "Clone";
		}
	}
}