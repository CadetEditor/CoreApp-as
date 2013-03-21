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
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.core.serialization.Deserializer;
	import core.app.core.serialization.ISerializationPlugin;
	import core.app.events.OperationProgressEvent;
	import core.app.events.SerializeProgressEvent;
	
	[Event(type="core.app.events.OperationProgressEvent", name="progress")]
	[Event(type="flash.events.Event", name="complete")]
	[Event(type="flash.events.ErrorEvent", name="error")]
	
	public class DeserializeOperation extends EventDispatcher implements IAsynchronousOperation
	{
		public var xml:XML;
		private var result	:*;
		private var plugins	:Vector.<ISerializationPlugin>;
		
		public function DeserializeOperation( xml:XML, plugins:Vector.<ISerializationPlugin> = null )
		{
			this.xml = xml;
			this.plugins = plugins;
		}
		
		public function getResult():* { return result; }

		public function execute():void
		{
			var deserializer:Deserializer = new Deserializer();
			if ( plugins )
			{
				for each ( var plugin:ISerializationPlugin in plugins )
				{
					deserializer.addPlugin( plugin );
				}
			}
			deserializer.addEventListener( SerializeProgressEvent.PROGRESS, deserializeProgressHandler );
			deserializer.addEventListener( Event.COMPLETE, deserializeCompleteHandler );
			deserializer.addEventListener(ErrorEvent.ERROR, deserializeErrorHandler);
			deserializer.deserializeAsync( xml );
		}
		
		private function deserializeProgressHandler( event:SerializeProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, event.numItems / event.totalItems ) );
		}
		
		private function deserializeCompleteHandler( event:Event ):void
		{
			var deserializer:Deserializer = Deserializer( event.target );
			deserializer.removeEventListener( SerializeProgressEvent.PROGRESS, deserializeProgressHandler );
			deserializer.removeEventListener( Event.COMPLETE, deserializeCompleteHandler );
			deserializer.removeEventListener(ErrorEvent.ERROR, deserializeErrorHandler);
			result = deserializer.getResult();
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function deserializeErrorHandler( event:ErrorEvent ):void
		{
			dispatchEvent( event );
		}
		
		public function get label():String
		{
			return null;
		}
	}
}