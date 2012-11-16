// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.operations
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.IReadFileOperation;
	import flox.app.core.operations.IAsynchronousOperation;
	import flox.app.core.serialization.ISerializationPlugin;
	import flox.app.entities.URI;
	import flox.app.events.OperationProgressEvent;

	[Event(type="flox.app.events.OperationProgressEvent", name="progress")]
	[Event(type="flash.events.Event", name="complete")]
	[Event(type="flash.events.ErrorEvent", name="error")]

	public class ReadFileAndDeserializeOperation extends EventDispatcher implements IAsynchronousOperation
	{
		private var readFileOperation		:IReadFileOperation;
		private var deserializeOperation	:DeserializeOperation;
		private var result					:*;
		private var uri						:URI;
		private var fileSystemProvider		:IFileSystemProvider;
		private var plugins					:Vector.<ISerializationPlugin>;
		
		public function ReadFileAndDeserializeOperation( uri:URI, fileSystemProvider:IFileSystemProvider, plugins:Vector.<ISerializationPlugin> = null )
		{
			this.uri = uri;
			this.fileSystemProvider = fileSystemProvider;
			this.plugins = plugins;
		}
		
		public function execute():void
		{
			readFileOperation = fileSystemProvider.readFile( uri );
			readFileOperation.addEventListener( OperationProgressEvent.PROGRESS, readFileProgressHandler );
			readFileOperation.addEventListener( Event.COMPLETE, readFileCompleteHandler );
			readFileOperation.execute();
		}
		
		private function readFileProgressHandler( event:OperationProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, event.progress * 0.2 ) );
		}
		
		private function readFileCompleteHandler( event:Event ):void
		{
			if ( readFileOperation.bytes.length == 0 )
			{
				result = null;
				dispatchEvent( new Event( Event.COMPLETE ) );
				return;
			}
			var xml:XML = XML( readFileOperation.bytes.readUTFBytes( readFileOperation.bytes.length ) );
			deserializeOperation = new DeserializeOperation( xml, plugins );
			deserializeOperation.addEventListener(Event.COMPLETE, deserializeCompleteHandler);
			deserializeOperation.addEventListener( OperationProgressEvent.PROGRESS, deserializeProgressHandler );
			deserializeOperation.execute();
		}
		
		private function deserializeProgressHandler( event:OperationProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, 0.2 + event.progress * 0.8 ) );
		}
		
		private function deserializeCompleteHandler( event:Event ):void
		{
			result = deserializeOperation.getResult();
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		public function get label():String { return "Read file and deserialize : " + uri.getFilename(); }
		
		public function getResult():* { return result; }
		public function getURI():URI { return readFileOperation.uri; }
	}
}