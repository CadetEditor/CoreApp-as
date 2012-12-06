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
	import flash.events.*;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	
	import flox.app.core.managers.fileSystemProviders.ILocalFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.*;
	import flox.app.entities.URI;
	import flox.app.events.FileSystemProviderEvent;
	import flox.app.events.OperationProgressEvent;
		
	[Event( type="flox.app.events.FileSystemProviderEvent", name="operationBegin" )]	
		
	public class LocalFileSystemProvider extends EventDispatcher implements ILocalFileSystemProvider
	{
		private var _id						:String;
		private var _label					:String;
		private var _rootDirectory			:File;
		private var _defaultDirectory		:File;
		
		public function LocalFileSystemProvider( id:String, label:String, rootDirectory:File, defaultDirectory:File )
		{
			_id = id;
			_label = label;
			_rootDirectory = rootDirectory;
			_defaultDirectory = defaultDirectory;
			
			if ( _defaultDirectory.exists == false )
			{
				_defaultDirectory.createDirectory();
			}
		}
		
		private function initOperation( operation:IFileSystemProviderOperation ):void
		{
			operation.addEventListener(ErrorEvent.ERROR, passThroughHandler );
			operation.addEventListener(OperationProgressEvent.PROGRESS, passThroughHandler);
			operation.addEventListener(Event.COMPLETE, passThroughHandler);
			dispatchEvent( new FileSystemProviderEvent( FileSystemProviderEvent.OPERATION_BEGIN, this, operation ) );
		}
		
		private function passThroughHandler( event:Event ):void
		{
			dispatchEvent( event );
		}
		
		public function readFile( uri:URI ):IReadFileOperation
		{
			var operation:ReadFileOperation = new ReadFileOperation( _rootDirectory, uri, this );
			initOperation( operation );
			return operation;
		}
		
		public function writeFile( uri:URI, bytes:ByteArray ):IWriteFileOperation
		{
			var operation:WriteFileOperation = new WriteFileOperation( _rootDirectory, uri, bytes, this );
			initOperation( operation );
			return operation;
		}
		
		public function createDirectory( uri:URI ):ICreateDirectoryOperation
		{
			var operation:CreateDirectoryOperation = new CreateDirectoryOperation( _rootDirectory, uri, this );
			initOperation( operation );
			return operation;
		}
		
		public function getDirectoryContents( uri:URI ):IGetDirectoryContentsOperation
		{
			var operation:GetDirectoryContentsOperation = new GetDirectoryContentsOperation( _rootDirectory, uri, this );
			initOperation( operation );
			return operation;
		}
		public function deleteFile( uri:URI ):IDeleteFileOperation
		{
			var operation:DeleteFileOperation = new DeleteFileOperation( _rootDirectory, uri, this );
			initOperation( operation );
			return operation;
		}
		
		public function doesFileExist( uri:URI ):IDoesFileExistOperation
		{
			var operation:DoesFileExistOperation = new DoesFileExistOperation( _rootDirectory, uri, this );
			initOperation( operation );
			return operation;
		}
		
		public function traverseToDirectory(uri:URI):ITraverseToDirectoryOperation
		{
			var operation:TraverseToDirectoryOperation = new TraverseToDirectoryOperation( _rootDirectory, uri, this );
			initOperation( operation );
			return operation;
		}
		
		public function traverseAllDirectories(uri:URI):ITraverseAllDirectoriesOperation
		{
			var operation:TraverseAllDirectoriesOperation = new TraverseAllDirectoriesOperation( _rootDirectory, uri, this );
			initOperation( operation );
			return operation;
		}
		
		
		public function get id():String { return _id; }
		public function get label():String { return _label; }
		public function get rootDirectoryURI():URI { return new URI(_rootDirectory.url); }
		public function get defaultDirectoryURI():URI { return new URI(_defaultDirectory.url); }
	}
}