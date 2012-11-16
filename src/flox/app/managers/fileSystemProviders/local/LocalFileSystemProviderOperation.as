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
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.IFileSystemProviderOperation;
	import flox.app.entities.URI;
	import flox.app.util.StringUtil;

	internal class LocalFileSystemProviderOperation extends EventDispatcher implements IFileSystemProviderOperation
	{
		protected var _rootDirectory		:File;
		protected var _uri					:URI
		protected var _fileSystemProvider	:IFileSystemProvider;
		
		public function LocalFileSystemProviderOperation(rootDirectory:File, uri:URI, fileSystemProvider:IFileSystemProvider)
		{
			_rootDirectory = rootDirectory;
			_uri = uri;
			_fileSystemProvider = fileSystemProvider;
		}
		
		public function execute():void {}
		
		public function get label():String
		{
			return null;
		}
		
		public function get uri():URI
		{
			return _uri;
		}
		
		public function get fileSystemProvider():IFileSystemProvider { return _fileSystemProvider; }
	}
}