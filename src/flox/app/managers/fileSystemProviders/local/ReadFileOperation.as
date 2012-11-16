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
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.IReadFileOperation;
	import flox.app.entities.URI;
	import flox.app.events.FileSystemErrorCodes;
	import flox.app.events.OperationProgressEvent;
	import flox.app.util.AsynchronousUtil;

	internal class ReadFileOperation extends LocalFileSystemProviderOperation implements IReadFileOperation
	{
		private var fileStream	:FileStream;
		private var _bytes		:ByteArray;
		
		public function ReadFileOperation( rootDirectory:File, uri:URI, fileSystemProvider:IFileSystemProvider )
		{
			super(rootDirectory, uri, fileSystemProvider);
		}
		
		private function dispose():void
		{
			if ( fileStream )
			{
				fileStream.removeEventListener( ProgressEvent.PROGRESS, readProgressHandler );
				fileStream.removeEventListener( Event.COMPLETE, readCompleteHandler );
				fileStream.removeEventListener( IOErrorEvent.IO_ERROR, readErrorHandler );
				fileStream.close();
				fileStream = null;
			}
		}

		override public function execute():void
		{
			//var file:File = new File( uriToFilePath(uri) );
			var file:File = new File( FileSystemUtil.uriToFilePath( _uri, _rootDirectory ) );
			if ( file.exists )
			{
				fileStream = new FileStream();
				fileStream.addEventListener( ProgressEvent.PROGRESS, readProgressHandler );
				fileStream.addEventListener( Event.COMPLETE, readCompleteHandler );
				fileStream.addEventListener( IOErrorEvent.IO_ERROR, readErrorHandler );
				
				fileStream.openAsync( file, FileMode.READ );
			}
			// Error - file does not exist
			else
			{
				AsynchronousUtil.dispatchLater( this, new ErrorEvent( ErrorEvent.ERROR, false, false, "", FileSystemErrorCodes.FILE_DOES_NOT_EXIST ) );
			}
		}
		
		private function readErrorHandler( event:IOErrorEvent ):void
		{
			AsynchronousUtil.dispatchLater( this, new ErrorEvent( ErrorEvent.ERROR, false, false, "", FileSystemErrorCodes.FILE_DOES_NOT_EXIST ) );
			dispose();
		}
		
		private function readProgressHandler( event:ProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, event.bytesLoaded / event.bytesTotal ) );
		}
		
		private function readCompleteHandler(event:Event):void
		{
			_bytes = new ByteArray();
			fileStream.readBytes( bytes, 0, fileStream.bytesAvailable );
			dispatchEvent( new Event( Event.COMPLETE ) );
			dispose();
		}
		
		override public function get label():String
		{
			return "Read File : " + _uri.path;
		}
		
		public function get bytes():ByteArray
		{
			return _bytes;
		}
	}
}