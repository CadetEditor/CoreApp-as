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
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.managers.fileSystemProviders.operations.IGetDirectoryContentsOperation;
	import core.app.entities.URI;
	import core.app.events.FileSystemErrorCodes;
	import core.app.util.AsynchronousUtil;

	internal class GetDirectoryContentsOperation extends LocalFileSystemProviderOperation implements IGetDirectoryContentsOperation
	{
		private var _contents	:Vector.<URI>;
		
		public function GetDirectoryContentsOperation(rootDirectory:File, uri:URI, fileSystemProvider:IFileSystemProvider)
		{
			super(rootDirectory, uri, fileSystemProvider);
		}
		
		override public function execute():void
		{
			//var filePath:String = uriToFilePath(uri);
			//var file:File = new File( filePath );
			var file:File = new File( FileSystemUtil.uriToFilePath( _uri, _rootDirectory ) );
			
			
			if ( file.exists == false ) 
			{
				AsynchronousUtil.dispatchLater( this, new ErrorEvent( ErrorEvent.ERROR, false, false, "", FileSystemErrorCodes.GET_DIRECTORY_CONTENTS_ERROR ) );
				return;
			}
			
			file.addEventListener(IOErrorEvent.IO_ERROR, getDirectoryContentsResponseHandler )
			file.addEventListener(FileListEvent.DIRECTORY_LISTING, getDirectoryContentsResponseHandler);
			file.getDirectoryListingAsync();
		}
		
		private function getDirectoryContentsErrorHandler( event:IOErrorEvent ):void
		{
			dispatchEvent(  new ErrorEvent( ErrorEvent.ERROR, false, false, "", FileSystemErrorCodes.GET_DIRECTORY_CONTENTS_ERROR ) );
		}
		
		private function getDirectoryContentsResponseHandler( event:FileListEvent ):void
		{
			var file:File = File( event.target );			
			
			_contents = new Vector.<URI>();
			for ( var i:int = 0; i < event.files.length; i++ )
			{
				//_contents[i] = fileToURI( event.files[i] );
				_contents[i] = FileSystemUtil.fileToURI( event.files[i], _rootDirectory, _fileSystemProvider.id );
			}
			
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		public function get contents():Vector.<URI>
		{
			return _contents;
		}
		
		override public function get label():String
		{
			return "Get Directory Contents : " + _uri.path;
		}
	}
}