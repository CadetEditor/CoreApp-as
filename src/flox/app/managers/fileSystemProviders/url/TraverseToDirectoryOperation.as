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
	
	import flox.app.FloxApp;
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.ITraverseToDirectoryOperation;
	import flox.app.entities.FileSystemNode;
	import flox.app.entities.URI;
	import flox.app.operations.CompoundOperation;
	
	public class TraverseToDirectoryOperation extends CompoundOperation implements ITraverseToDirectoryOperation
	{
		private var _uri				:URI;
		private var _fileSystemProvider	:URLFileSystemProvider;
		private var _baseURL			:String;
		private var _fileExists			:Boolean = false;
		
		private var directories				:Array;
		private var _contents				:Array;
		
		public function TraverseToDirectoryOperation( uri:URI, fileSystemProvider:URLFileSystemProvider, baseURL:String )
		{
			_uri = uri;
			_fileSystemProvider = fileSystemProvider;
			_baseURL = baseURL;
			
			var fileSystem:FileSystemNode = FloxApp.fileSystemProvider.fileSystem;
			var rootDirURI:URI = new URI("cadet.url/");
			
			_contents = [];
			directories = [];
			directories.push(_uri);
			
			var directoryURI:URI = _uri.getParentURI();
			while ( directoryURI.path != rootDirURI.path )
			{
				node = fileSystem.getChildWithPath( directoryURI.path, true );
				if ( !(node && node.isPopulated) ) {
					directories.push(directoryURI);
				}
				directoryURI = directoryURI.getParentURI();
			}
		
			// add rootDir
			directoryURI = rootDirURI;
			var node:FileSystemNode = fileSystem.getChildWithPath( directoryURI.path, true );
			if ( !(node && node.isPopulated) ) {
				directories.push(directoryURI);
			}
			
			//trace("directories "+directories);
			directories.reverse();
			
			for ( var i:uint = 0; i < directories.length; i ++ )
			{
				directoryURI = directories[i];
				var operation:GetDirectoryContentsOperation = new GetDirectoryContentsOperation( directoryURI, _fileSystemProvider, _baseURL );
				addOperation(operation);
			}
		}
		
		override protected function operationCompleteHandler( event:Event ):void
		{
			if ( event.target is GetDirectoryContentsOperation ) {
				var operation:GetDirectoryContentsOperation = GetDirectoryContentsOperation(event.target);
				_contents.push( { uri:operation.uri, contents:operation.contents } );
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
		
		public function get fileSystemProvider():IFileSystemProvider { return _fileSystemProvider; }
	}
}