// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.core.managers.fileSystemProviders.operations
{
	import flox.app.entities.URI;

	[Event(type="flox.apps.events.FileSystemErrorEvent", name="error")]
	[Event(type="flash.events.Event", name="complete")]
	[Event(type="flox.app.events.OperationProgressEvent", name="progress")]
	
	public interface IGetDirectoryContentsOperation extends IFileSystemProviderOperation
	{
		function get contents():Vector.<URI>;
	}
}