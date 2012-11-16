// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.resources
{
	import flash.events.IEventDispatcher;
	
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.entities.URI;

	public interface IExternalResource extends IFactoryResource, IEventDispatcher
	{
		function getIsLoaded():Boolean;
		function getIsLoading():Boolean;
		function setFileSystemProvider( value:IFileSystemProvider ):void;
		function getUri():URI;
		function load():void;
		function unload():void;
	}
}