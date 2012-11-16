// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.managers.fileSystemProviders.local
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.ITraverseAllDirectoriesOperation;
	import flox.app.entities.URI;
	import flox.app.events.OperationProgressEvent;
	import flox.app.operations.CompoundOperation;
	import flox.app.util.AsynchronousUtil;
	
	public class TraverseAllDirectoriesOperation extends CompoundOperation implements ITraverseAllDirectoriesOperation
	{
		protected var _rootDirectory		:File;
		protected var _uri					:URI
		protected var _fileSystemProvider	:IFileSystemProvider;
		
		//private var directories				:Array;
		private var _contents				:Array;
		
		public function TraverseAllDirectoriesOperation(rootDirectory:File, uri:URI, fileSystemProvider:IFileSystemProvider)
		{
			_rootDirectory = rootDirectory;
			_uri = uri;
			_fileSystemProvider = fileSystemProvider;
			
			_contents = [];

			var operation:GetDirectoryContentsOperation = new GetDirectoryContentsOperation( _rootDirectory, uri, _fileSystemProvider );
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
						var newOperation:GetDirectoryContentsOperation = new GetDirectoryContentsOperation( _rootDirectory, uri, _fileSystemProvider );
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




