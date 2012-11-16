// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.events
{
	import flash.events.Event;
	
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.IFileSystemProviderOperation;

	public class FileSystemProviderEvent extends Event
	{
		public static const OPERATION_BEGIN		:String = "operationBegin";
		
		private var _fileSystemProvider	:IFileSystemProvider;
		private var _operation			:IFileSystemProviderOperation;
		
		public function FileSystemProviderEvent(type:String, fileSystemProvider:IFileSystemProvider, operation:IFileSystemProviderOperation)
		{
			super(type);
			_fileSystemProvider = fileSystemProvider;
			_operation = operation;
		}
		
		override public function clone():Event
		{
			return new FileSystemProviderEvent( type, _fileSystemProvider, _operation );
		}
		
		public function get fileSystemProvider():IFileSystemProvider { return _fileSystemProvider; }
		public function get operation():IFileSystemProviderOperation { return _operation; }
	}
}