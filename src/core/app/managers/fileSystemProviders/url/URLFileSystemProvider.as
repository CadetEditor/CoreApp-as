// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.managers.fileSystemProviders.url
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.managers.fileSystemProviders.operations.*;
	import core.app.entities.URI;
	import core.app.events.FileSystemErrorCodes;
	import core.app.events.FileSystemProviderEvent;
	import core.app.events.OperationProgressEvent;
	
	[Event( type="core.app.events.FileSystemProviderEvent", name="operationBegin" )]	
	
	public class URLFileSystemProvider extends EventDispatcher implements IFileSystemProvider
	{
		private var _id		:String;
		private var _label	:String;
		private var _baseURL:String;
				
		public function URLFileSystemProvider( id:String, label:String, baseURL:String )
		{
			_id = id;
			_label = label;
			_baseURL = baseURL;
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
			var operation:ReadFileOperation = new ReadFileOperation( uri, this, _baseURL );
			initOperation( operation );
			return operation;
		}
		
		public function writeFile( uri:URI, bytes:ByteArray ):IWriteFileOperation
		{
			throw( new Error( "", FileSystemErrorCodes.OPERATION_NOT_SUPPORTED ) );
			return null;
		}
		
		public function createDirectory( uri:URI ):ICreateDirectoryOperation
		{
			throw( new Error( "", FileSystemErrorCodes.OPERATION_NOT_SUPPORTED ) );
			return null;
		}
		
		public function getDirectoryContents( uri:URI ):IGetDirectoryContentsOperation
		{
			var operation:GetDirectoryContentsOperation = new GetDirectoryContentsOperation( uri, this, _baseURL );
			initOperation( operation );
			return operation;
		}
		public function deleteFile( uri:URI ):IDeleteFileOperation
		{
			throw( new Error( "", FileSystemErrorCodes.OPERATION_NOT_SUPPORTED ) );
			return null;
		}
		
		public function doesFileExist( uri:URI ):IDoesFileExistOperation
		{
			var operation:DoesFileExistOperation = new DoesFileExistOperation( uri, this, _baseURL );
			initOperation( operation );
			return operation;
		}
		
		public function traverseToDirectory(uri:URI):ITraverseToDirectoryOperation
		{
			var operation:TraverseToDirectoryOperation = new TraverseToDirectoryOperation( uri, this, _baseURL );
			initOperation( operation );
			return operation;
		}
		public function traverseAllDirectories(uri:URI):ITraverseAllDirectoriesOperation
		{
			var operation:TraverseAllDirectoriesOperation = new TraverseAllDirectoriesOperation( uri, this, _baseURL );
			initOperation( operation );
			return operation;
		}
		
		public function get id():String { return _id; }
		public function get label():String { return _label; }
	}
}