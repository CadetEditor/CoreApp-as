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
	import flox.app.entities.FileSystemNode;
	import flox.app.entities.URI;
	
	public interface IMultiFileSystemProvider extends IFileSystemProvider
	{
		function registerFileSystemProvider( provider:IFileSystemProvider, visible:Boolean = true ):void
		function get fileSystem():FileSystemNode;
		
		function getFileSystemProviderForURI( uri:URI ):IFileSystemProvider
	}
}