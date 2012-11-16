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
	import flox.app.core.managers.fileSystemProviders.operations.IDeleteFileOperation;
	import flox.app.entities.URI;
	import flox.app.events.FileSystemErrorCodes;
	import flox.app.util.AsynchronousUtil;

	internal class DeleteFileOperation extends LocalFileSystemProviderOperation implements IDeleteFileOperation
	{
		public function DeleteFileOperation(rootDirectory:File, uri:URI, fileSystemProvider:IFileSystemProvider )
		{
			super(rootDirectory, uri, fileSystemProvider);
		}
		
		override public function execute():void
		{
			//var file:File = new File( uriToFilePath(uri) );
			var file:File = new File( FileSystemUtil.uriToFilePath( _uri, _rootDirectory ) );
			
			if ( file.exists == false )
			{
				AsynchronousUtil.dispatchLater( this, new ErrorEvent( ErrorEvent.ERROR, false, false, "", FileSystemErrorCodes.DELETE_FILE_ERROR ) );
				return;
			}
			
			if ( file.isDirectory )
			{
				file.deleteDirectory( true );
			}
			else
			{
				file.deleteFile();
			}
			
			AsynchronousUtil.dispatchLater( this, new Event( Event.COMPLETE ) );
		}
		
		override public function get label():String
		{
			return "Delete File : " + _uri.path;
		}
	}
}