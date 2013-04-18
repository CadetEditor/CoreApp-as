// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.managers.fileSystemProviders.local
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import core.app.CoreApp;
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.managers.fileSystemProviders.operations.ITraverseToDirectoryOperation;
	import core.app.entities.FileSystemNode;
	import core.app.entities.URI;
	import core.app.events.OperationProgressEvent;
	import core.app.operations.CompoundOperation;
	
	public class TraverseToDirectoryOperation extends CompoundOperation implements ITraverseToDirectoryOperation
	{
		protected var _rootDirectory		:File;
		protected var _uri					:URI;
		protected var _finalURI				:URI;
		protected var _fileSystemProvider	:IFileSystemProvider;
		
		private var directories				:Array;
		private var _contents				:Array;
		
		public function TraverseToDirectoryOperation(rootDirectory:File, uri:URI, fileSystemProvider:IFileSystemProvider)
		{
			_rootDirectory = rootDirectory;
			_uri = uri;
			_finalURI = uri;
			_fileSystemProvider = fileSystemProvider;
			
			var fileSystem:FileSystemNode = CoreApp.fileSystemProvider.fileSystem;
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
				operation.addEventListener( ErrorEvent.ERROR, getDirectoryErrorHandler );
				addOperation(operation);
			}
		}
		
		private function getDirectoryErrorHandler( event:Event ):void
		{
			operations.splice(currentIndex+1, operations.length);
			
			var operation:GetDirectoryContentsOperation = GetDirectoryContentsOperation( event.target );
			operation.removeEventListener( Event.COMPLETE, operationCompleteHandler );
			operation.removeEventListener( OperationProgressEvent.PROGRESS, operationProgressHandler );
			operation.removeEventListener( ErrorEvent.ERROR, operationErrorHandler );
			//trace("Undoable Compound Operation. Child operation complete : " + operation.label);
			
			// The current operation is made to be the last so the CompoundOperation can quit,
			// so take the second to last operation as the final valid URI
			if ( operations.length > 1 ) {
				operation = operations[operations.length-2];
				_finalURI = operation.uri;
			}
			
			update();
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
		
		public function get finalURI():URI
		{
			return _finalURI;
		}
		
		public function get fileSystemProvider():IFileSystemProvider { return _fileSystemProvider; }
	}
}