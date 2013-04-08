// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package core.app.operations
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.core.serialization.ISerializationPlugin;
	import core.app.core.serialization.Serializer;
	import core.app.events.OperationProgressEvent;
	import core.app.events.SerializeProgressEvent;
	
	[Event(type="core.app.events.OperationProgressEvent", name="progress")]
	[Event(type="flash.events.Event", name="complete")]
	
	public class SerializeOperation extends EventDispatcher implements IAsynchronousOperation
	{
		private var item	:*;
		private var plugins:Vector.<ISerializationPlugin>;
		private var result	:XML;
		
		public function SerializeOperation( item:*, plugins:Vector.<ISerializationPlugin> = null)
		{
			this.item = item;
			this.plugins = plugins;
		}
		
		public function getResult():XML { return result; }

		public function execute():void
		{
			var serializer:Serializer = new Serializer();
			if ( plugins )
			{
				for each ( var plugin:ISerializationPlugin in plugins )
				{
					serializer.addPlugin( plugin );
				}
			}
			serializer.addEventListener( SerializeProgressEvent.PROGRESS, serializeProgressHandler );
			serializer.addEventListener( Event.COMPLETE, serializeCompleteHandler );
			serializer.serializeAsync( item );
		}
		
		private function serializeProgressHandler( event:SerializeProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, event.numItems / event.totalItems ) );
		}
		
		private function serializeCompleteHandler( event:Event ):void
		{
			var serializer:Serializer = Serializer( event.target );
			serializer.removeEventListener( SerializeProgressEvent.PROGRESS, serializeProgressHandler );
			serializer.removeEventListener( Event.COMPLETE, serializeCompleteHandler );
			result = serializer.getResult();
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		public function get label():String
		{
			return null;
		}
	}
}