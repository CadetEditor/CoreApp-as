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
	import flash.events.Event;
	import flash.filesystem.File;
	
	import flox.app.FloxApp;
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.IGetDirectoryContentsOperation;
	import flox.app.core.managers.fileSystemProviders.operations.ITraverseToDirectoryOperation;
	import flox.app.entities.FileSystemNode;
	import flox.app.entities.URI;
	import flox.app.operations.CompoundOperation;
	
	public class TraverseToDirectoryOperation extends CompoundOperation implements ITraverseToDirectoryOperation
	{
		protected var _rootDirectory		:File;
		protected var _uri					:URI
		protected var _fileSystemProvider	:IFileSystemProvider;
		
		private var directories				:Array;
		private var _contents				:Array;
		
		public function TraverseToDirectoryOperation(rootDirectory:File, uri:URI, fileSystemProvider:IFileSystemProvider)
		{
			_rootDirectory = rootDirectory;
			_uri = uri;
			_fileSystemProvider = fileSystemProvider;
			
			var fileSystem:FileSystemNode = FloxApp.fileSystemProvider.fileSystem;
			var rootDirURI:URI = FileSystemUtil.fileToURI(_rootDirectory, _rootDirectory, _fileSystemProvider.id);
			
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
				var operation:GetDirectoryContentsOperation = new GetDirectoryContentsOperation( _rootDirectory, directoryURI, _fileSystemProvider );
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