// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.controllers
{
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.entities.URI;
	import flox.app.managers.ResourceManager;

	public interface IExternalResourceParser
	{
		// Should create a resource for the input uri, and take care of adding it to the resource manager.
		// It should return an array that contains (or will contain) all resources assocaited with this uri.
		function parse( uri:URI, assetsURI:URI, resourceManager:ResourceManager, fileSystemProvider:IFileSystemProvider ):Array
	}
}