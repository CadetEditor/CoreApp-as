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
	
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.managers.fileSystemProviders.operations.IDoesFileExistOperation;
	import core.app.entities.URI;
	import core.app.events.FileSystemErrorCodes;
	import core.app.events.OperationProgressEvent;

	internal class DoesFileExistOperation extends EventDispatcher implements IDoesFileExistOperation
	{
		private var _uri				:URI;
		private var _fileSystemProvider	:URLFileSystemProvider;
		private var _baseURL			:String;
		private var _fileExists			:Boolean = false;
		
		public function DoesFileExistOperation( uri:URI, fileSystemProvider:URLFileSystemProvider, baseURL:String )
		{
			_uri = uri;
			_fileSystemProvider = fileSystemProvider;
			_baseURL = baseURL;
		}

		public function execute():void
		{
			// Remove the FileSystemProvider's id from the start of the path;
			var localURI:URI = _uri.subpath(1);
			
			var parent:URI = new URI();
			parent.copyURI(localURI );
			//parent.chdir("../");
			parent  = parent.getParentURI();
			
			var getDirectoryContents:GetDirectoryContentsOperation = new GetDirectoryContentsOperation( parent, _fileSystemProvider, _baseURL );
			getDirectoryContents.addEventListener(OperationProgressEvent.PROGRESS, progressHandler);
			getDirectoryContents.addEventListener(ErrorEvent.ERROR, errorHandler);
			getDirectoryContents.addEventListener(Event.COMPLETE, getDirectoryContentsCompleteHandler);
			getDirectoryContents.execute();
		}
		
		private function errorHandler( event:ErrorEvent ):void
		{
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, event.text, FileSystemErrorCodes.DOES_FILE_EXIST_ERROR ) );
		}
		
		private function progressHandler( event:OperationProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, event.progress ) );
		}
		
		private function getDirectoryContentsCompleteHandler( event:Event ):void
		{
			var getDirectoryContents:GetDirectoryContentsOperation = GetDirectoryContentsOperation(event.target);
			
			// Remove the FileSystemProvider's id from the start of the path;
			var uriToFind:URI = _uri.subpath(1);
			
			_fileExists = false;
			for each ( var uriInFolder:URI in getDirectoryContents.contents )
			{
				if ( uriInFolder.path == uriToFind.path )
				{
					_fileExists = true;
					break;
				}
			}
			
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		public function get label():String
		{
			return "Does file exist : " + _uri.path;
		}
		
		public function get fileExists():Boolean
		{
			return _fileExists;
		}
		
		public function get uri():URI
		{
			return _uri;
		}
		
		public function get fileSystemProvider():IFileSystemProvider
		{
			return fileSystemProvider;
		}
	}
}