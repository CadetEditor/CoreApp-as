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
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.IReadFileOperation;
	import flox.app.entities.URI;
	import flox.app.events.FileSystemErrorCodes;
	import flox.app.events.OperationProgressEvent;
	import flox.app.util.StringUtil;

	internal class ReadFileOperation extends EventDispatcher implements IReadFileOperation
	{
		private var _uri					:URI;
		private var _fileSystemProvider	:URLFileSystemProvider;
		private var _bytes				:ByteArray;
		private var _baseURL			:String;
		
		public function ReadFileOperation( uri:URI, fileSystemProvider:URLFileSystemProvider, baseURL:String )
		{
			_uri = uri;
			_fileSystemProvider = fileSystemProvider;
			_baseURL = baseURL;
		}

		public function execute():void
		{
			var loader:URLLoader = new URLLoader();
			
			// Remove the FileSystemProvider's id from the start of the path;
			var localURI:URI = _uri.subpath(1);
			
			var request:URLRequest = new URLRequest( _baseURL + localURI.path );
			request.contentType = URLLoaderDataFormat.BINARY;
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(request);
		}
		
		private function errorHandler( event:ErrorEvent ):void
		{
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, event.text, FileSystemErrorCodes.READ_FILE_ERROR ) );
		}
		
		private function progressHandler( event:ProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, event.bytesLoaded/event.bytesTotal ) );
		}
		
		private function loadCompleteHandler( event:Event ):void
		{
			var loader:URLLoader = URLLoader(event.target);
			_bytes = ByteArray(loader.data);
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		public function get label():String
		{
			return "Read File : " + _uri.path;
		}
		
		public function get bytes():ByteArray
		{
			return _bytes;
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