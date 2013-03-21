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
	import flash.events.Event;
	import flash.filesystem.File;
	
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.managers.fileSystemProviders.operations.IDoesFileExistOperation;
	import core.app.entities.URI;
	import core.app.util.AsynchronousUtil;

	internal class DoesFileExistOperation extends LocalFileSystemProviderOperation implements IDoesFileExistOperation
	{
		private var _fileExists	:Boolean;
		
		public function DoesFileExistOperation(rootDirectory:File, uri:URI, fileSystemProvider:IFileSystemProvider)
		{
			super(rootDirectory, uri, fileSystemProvider);
		}
		
		override public function execute():void
		{
			//var file:File = new File( uriToFilePath(uri) );
			var file:File = new File( FileSystemUtil.uriToFilePath( _uri, _rootDirectory ) );
			_fileExists = file.exists;
			AsynchronousUtil.dispatchLater( this, new Event( Event.COMPLETE ) );
		}
		
		override public function get label():String
		{
			return "Does File Exist : " + _uri.path;
		}
		
		public function get fileExists():Boolean
		{
			return _fileExists;
		}
	}
}