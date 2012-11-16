// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.managers.fileSystemProviders.url
{
	import flash.events.Event;
	
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.ITraverseAllDirectoriesOperation;
	import flox.app.entities.URI;
	import flox.app.operations.CompoundOperation;
	
	public class TraverseAllDirectoriesOperation extends CompoundOperation implements ITraverseAllDirectoriesOperation
	{
		protected var _uri					:URI
		protected var _fileSystemProvider	:URLFileSystemProvider;
		protected var _baseURL				:String;
		
		private var _contents				:Array;
		
		public function TraverseAllDirectoriesOperation( uri:URI, fileSystemProvider:URLFileSystemProvider, baseURL:String )
		{
			_uri = uri;
			_fileSystemProvider = fileSystemProvider;
			_baseURL = baseURL;
			
			_contents = [];
			
			var operation:GetDirectoryContentsOperation = new GetDirectoryContentsOperation( uri, _fileSystemProvider, _baseURL );
			addOperation(operation);
		}
		
		override protected function operationCompleteHandler(event:Event):void
		{
			if ( event.target is GetDirectoryContentsOperation ) {
				var operation:GetDirectoryContentsOperation = GetDirectoryContentsOperation(event.target);
				_contents.push( { uri:operation.uri, contents:operation.contents } );
				
				for ( var i:uint = 0; i < operation.contents.length; i ++ ) {
					var uri:URI = operation.contents[i];
					if ( uri.isDirectory() ) {
						var newOperation:GetDirectoryContentsOperation = new GetDirectoryContentsOperation( uri, _fileSystemProvider, _baseURL );
						addOperation(newOperation);
					}
				}
			}
			
			super.operationCompleteHandler(event);
		}
		
		public function get contents():Array
		{
			return _contents;
		}
		
		public function get uri():URI
		{
			return _uri;
		}
		
		public function get fileSystemProvider():IFileSystemProvider
		{
			return _fileSystemProvider;
		}
	}
}