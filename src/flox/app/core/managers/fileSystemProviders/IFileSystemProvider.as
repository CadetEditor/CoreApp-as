// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.core.managers.fileSystemProviders
{
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	import flox.app.core.managers.fileSystemProviders.operations.ICreateDirectoryOperation;
	import flox.app.core.managers.fileSystemProviders.operations.IDeleteFileOperation;
	import flox.app.core.managers.fileSystemProviders.operations.IDoesFileExistOperation;
	import flox.app.core.managers.fileSystemProviders.operations.IGetDirectoryContentsOperation;
	import flox.app.core.managers.fileSystemProviders.operations.IReadFileOperation;
	import flox.app.core.managers.fileSystemProviders.operations.ITraverseAllDirectoriesOperation;
	import flox.app.core.managers.fileSystemProviders.operations.ITraverseToDirectoryOperation;
	import flox.app.core.managers.fileSystemProviders.operations.IWriteFileOperation;
	import flox.app.entities.URI;
	
	[Event( type="flox.app.events.FileSystemProviderEvent", name="operationBegin" )]
	
	public interface IFileSystemProvider extends IEventDispatcher
	{
		function createDirectory(uri:URI):ICreateDirectoryOperation
		function deleteFile(uri:URI):IDeleteFileOperation
		function doesFileExist(uri:URI):IDoesFileExistOperation
		function getDirectoryContents(uri:URI):IGetDirectoryContentsOperation
		function readFile(uri:URI):IReadFileOperation
		function traverseToDirectory(uri:URI):ITraverseToDirectoryOperation
		function traverseAllDirectories(uri:URI):ITraverseAllDirectoriesOperation
		function writeFile(uri:URI, data:ByteArray):IWriteFileOperation
			
		function get id():String
		function get label():String
	}
}