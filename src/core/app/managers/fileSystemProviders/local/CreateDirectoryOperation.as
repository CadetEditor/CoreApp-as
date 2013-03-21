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
	import flash.filesystem.FileStream;
	
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.managers.fileSystemProviders.operations.ICreateDirectoryOperation;
	import core.app.entities.URI;
	import core.app.events.FileSystemErrorCodes;
	import core.app.util.AsynchronousUtil;

	internal class CreateDirectoryOperation extends LocalFileSystemProviderOperation implements ICreateDirectoryOperation
	{
		private var fileStream	:FileStream;
		
		public function CreateDirectoryOperation(rootDirectory:File, uri:URI, fileSystemProvider:IFileSystemProvider)
		{
			super(rootDirectory, uri, fileSystemProvider);
		}
		
		override public function execute():void
		{
			if ( _uri.isDirectory() == false )
			{
				AsynchronousUtil.dispatchLater( this, new ErrorEvent( ErrorEvent.ERROR, false, false, "", FileSystemErrorCodes.CREATE_DIRECTORY_ERROR ) );
				return;
			}
			
			//var file:File = new File( uriToFilePath(_uri) );
			var file:File = new File( FileSystemUtil.uriToFilePath( _uri, _rootDirectory ) );
			file.createDirectory();
			
			AsynchronousUtil.dispatchLater( this, new Event( Event.COMPLETE ) );
		}
		
		override public function get label():String
		{
			return "Create Directory : " + _uri.path;
		}
	}
}