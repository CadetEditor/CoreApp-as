package core.app.util
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import core.app.CoreApp;
	import core.app.core.serialization.ISerializationPlugin;
	import core.app.core.serialization.ResourceSerializerPlugin;
	import core.app.operations.SerializeOperation;

	public class SerializationUtil
	{
		private static var _eventDispatcher	:EventDispatcher;
		private static var _result			:XML;
		
		public function SerializationUtil()
		{
		}
		
		static public function serialize( obj:* ):EventDispatcher
		{
			if (!CoreApp.initialised) {
				CoreApp.init();
			}
			
			if (!_eventDispatcher) {
				_eventDispatcher = new EventDispatcher();
			}
			
			var plugins:Vector.<ISerializationPlugin> = new Vector.<ISerializationPlugin>();			
			plugins.push( new ResourceSerializerPlugin( CoreApp.resourceManager ) );
			
			var serializeOperation:SerializeOperation = new SerializeOperation( obj, plugins );
			serializeOperation.addEventListener( Event.COMPLETE, serializeCompleteHandler );
//			serializeOperation.addEventListener(OperationProgressEvent.PROGRESS, progressHandler);
//			serializeOperation.addEventListener(ErrorEvent.ERROR, errorHandler);
			serializeOperation.execute();
			
			return _eventDispatcher;
		}
		
		static private function serializeCompleteHandler( event:Event ):void
		{
			var serializeOperation:SerializeOperation = SerializeOperation(event.target);
			_result = serializeOperation.getResult();
			_eventDispatcher.dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		static public function getResult():XML
		{
			return _result;
		}
	}
}