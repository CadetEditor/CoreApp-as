// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.core.managers.fileSystemProviders
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import core.app.core.managers.fileSystemProviders.operations.ICreateDirectoryOperation;
	import core.app.core.managers.fileSystemProviders.operations.IDeleteFileOperation;
	import core.app.core.managers.fileSystemProviders.operations.IDoesFileExistOperation;
	import core.app.core.managers.fileSystemProviders.operations.IFileSystemProviderOperation;
	import core.app.core.managers.fileSystemProviders.operations.IGetDirectoryContentsOperation;
	import core.app.core.managers.fileSystemProviders.operations.IReadFileOperation;
	import core.app.core.managers.fileSystemProviders.operations.ITraverseAllDirectoriesOperation;
	import core.app.core.managers.fileSystemProviders.operations.ITraverseToDirectoryOperation;
	import core.app.core.managers.fileSystemProviders.operations.IWriteFileOperation;
	import core.app.entities.FileSystemNode;
	import core.app.entities.URI;
	import core.app.events.FileSystemProviderEvent;
	
	public class MultiFileSystemProvider extends EventDispatcher implements IMultiFileSystemProvider
	{
		private var providers		:Object;
		private var idTable			:Dictionary;
		
		private var _fileSystem		:FileSystemNode;
		
		public function MultiFileSystemProvider()
		{
			providers = {};
			idTable = new Dictionary();
			
			_fileSystem = new FileSystemNode();
			_fileSystem.path = "/";
			_fileSystem.isPopulated = true;
		}
		
		public function registerFileSystemProvider(provider:IFileSystemProvider, addToFileSystem:Boolean = true):void
		{
			providers[provider.id] = provider;
			idTable[provider] = provider.id;
			
			provider.addEventListener(FileSystemProviderEvent.OPERATION_BEGIN, operationBeginHandler);
			
			if ( !addToFileSystem ) return;
			
			var node:FileSystemNode = new FileSystemNode();
			node.path = provider.id + "/";
			node.label = provider.label;
			_fileSystem.children.addItem( node );
		}
		
		public function get fileSystem():FileSystemNode { return _fileSystem; }
		
		
		
		public function getFileSystemProviderForURI( uri:URI ):IFileSystemProvider
		{
			return getProviderForURI(uri);
		}
		
		private function getProviderForURI(uri:URI):IFileSystemProvider
		{
			var split:Array = uri.path.split("/");
			var providerID:String = split[0];
			var provider:IFileSystemProvider = providers[providerID];
			if ( provider == null )
			{
				//throw( new Error( "Cannot map uri to provider. " + uri.path ) );
				return null;
			}
			
			return providers[providerID];
		}
		
		
		public function createDirectory(uri:URI):ICreateDirectoryOperation
		{
			var provider:IFileSystemProvider = getProviderForURI(uri);
			var operation:ICreateDirectoryOperation = provider.createDirectory(uri);
			operation.addEventListener( ErrorEvent.ERROR, errorHandler, false, 0, true );
			return operation;
		}
		
		public function deleteFile(uri:URI):IDeleteFileOperation
		{
			var provider:IFileSystemProvider = getProviderForURI(uri);
			var operation:IDeleteFileOperation = provider.deleteFile(uri);
			operation.addEventListener( ErrorEvent.ERROR, errorHandler, false, 0, true );
			return operation;
		}
		
		public function doesFileExist(uri:URI):IDoesFileExistOperation
		{
			var provider:IFileSystemProvider = getProviderForURI(uri);
			var operation:IDoesFileExistOperation = provider.doesFileExist(uri);
			operation.addEventListener( ErrorEvent.ERROR, errorHandler, false, 0, true );
			return operation;
		}		
		
		public function getDirectoryContents(uri:URI):IGetDirectoryContentsOperation
		{
			var provider:IFileSystemProvider = getProviderForURI(uri);
			var operation:IGetDirectoryContentsOperation = provider.getDirectoryContents(uri);
			operation.addEventListener( ErrorEvent.ERROR, errorHandler, false, 0, true );
			return operation;
		}
		
		public function readFile(uri:URI):IReadFileOperation
		{
			var provider:IFileSystemProvider = getProviderForURI(uri);
			var operation:IReadFileOperation = provider.readFile(uri);
			operation.addEventListener( ErrorEvent.ERROR, errorHandler, false, 0, true );
			return operation;
		}
		
		public function traverseToDirectory(uri:URI):ITraverseToDirectoryOperation
		{
			var provider:IFileSystemProvider = getProviderForURI(uri);
			var operation:ITraverseToDirectoryOperation = provider.traverseToDirectory(uri);
			operation.addEventListener( ErrorEvent.ERROR, errorHandler, false, 0, true );
			return operation;
		}
		
		public function traverseAllDirectories(uri:URI):ITraverseAllDirectoriesOperation
		{
			var provider:IFileSystemProvider = getProviderForURI(uri);
			var operation:ITraverseAllDirectoriesOperation = provider.traverseAllDirectories(uri);
			operation.addEventListener( ErrorEvent.ERROR, errorHandler, false, 0, true );
			return operation;
		}
		
		public function writeFile(uri:URI, data:ByteArray):IWriteFileOperation
		{
			var provider:IFileSystemProvider = getProviderForURI(uri);
			var operation:IWriteFileOperation = provider.writeFile(uri, data);
			operation.addEventListener( ErrorEvent.ERROR, errorHandler, false, 0, true );
			return operation;
		}
		
		//Why listen into the MultiFileSystemProvider rather than the Operation for errors?
		private function errorHandler( event:ErrorEvent ):void
		{
			//dispatchEvent( event );
		}
		
		public function get id():String { return ""; }
		public function get label():String { return ""; }
		
		
		
		
		
		
		// Methods for manipulating the model
		private function repopulateDirectory( uri:URI, contents:Vector.<URI> ):void
		{
			var fileSystemNode:FileSystemNode = _fileSystem.getChildWithData( uri.path, true ) as FileSystemNode;
			if ( !fileSystemNode ) return;
			
			var childrenToRemove:Array = [];
			var childrenToAdd:Array = [];
			
			var childNode:FileSystemNode;
			var i:int;
			var childURI:URI;
			for ( i = 0; i < fileSystemNode.children.length; i++ )
			{
				childNode = fileSystemNode.children[i];
				
				var remove:Boolean = true;
				for each ( childURI in contents )
				{
					if ( childNode.path == childURI.path )
					{
						remove = false;
					}
				}
				
				if ( remove )
				{
					childrenToRemove.push( childNode );
				}
			}
			
			
			for ( i = 0; i < contents.length; i++ )
			{
				childURI = contents[i];
				
				var add:Boolean = true;
				for each ( childNode in fileSystemNode.children )
				{
					if ( childNode.path == childURI.path )
					{
						add = false;
					}
				}
				
				if ( add )
				{
					childrenToAdd.push( childURI );
				}
			}
			
			for ( i = 0; i < childrenToRemove.length; i++ )
			{
				fileSystemNode.children.removeItem( childrenToRemove[i] );
			}
			for ( i = 0; i < childrenToAdd.length; i++ )
			{
				addFile( childrenToAdd[i] );
			}
			
			fileSystemNode.isPopulated = true;
		}
		
		private function addFile( uri:URI ):void
		{
			var node:FileSystemNode = _fileSystem.getChildWithData( uri.path, true ) as FileSystemNode;
			if ( node ) return;
			
			var parentURI:URI = new URI();
			parentURI.copyURI(uri);
			parentURI.isDirectory() ? parentURI.chdir("../") : parentURI.chdir("./");
			var parentNode:FileSystemNode = _fileSystem.getChildWithData( parentURI.path, true ) as FileSystemNode;
			if ( !parentNode ) return;
			
			node = new FileSystemNode();
			node.path = uri.path;
			parentNode.children.addItem(node);
		}
		
		private function removeFile( uri:URI ):void
		{
			var node:FileSystemNode = _fileSystem.getChildWithData( uri.path, true ) as FileSystemNode;
			if ( !node ) return;
			
			var parentURI:URI = new URI();
			parentURI.copyURI(uri);
			parentURI.isDirectory() ? parentURI.chdir("../") : parentURI.chdir("./");
			var parentNode:FileSystemNode = _fileSystem.getChildWithData( parentURI.path, true ) as FileSystemNode;
			if ( !parentNode ) return;
			
			parentNode.children.removeItem(node);
		}
		
		
		
		
		/*-- Handlers ------------------------------------------------*/
		private function operationBeginHandler( event:FileSystemProviderEvent ):void
		{
			dispatchEvent(event);
			event.operation.addEventListener(Event.COMPLETE, operationCompleteHandler);
		}
		private function operationCompleteHandler( event:Event ):void
		{
			var operation:IFileSystemProviderOperation = IFileSystemProviderOperation(event.target);
			
			if (event.target is ICreateDirectoryOperation )
			{
				createDirectoryComplete( operation );
			}
			else if ( event.target is IDeleteFileOperation )
			{
				deleteComplete( operation );
			}
			else if ( event.target is IDoesFileExistOperation )
			{
				//doesFileExistComplete( operation );
			}
			else if ( event.target is IGetDirectoryContentsOperation )
			{
				getDirectoryContentsComplete( operation );
			}
			else if ( event.target is ITraverseToDirectoryOperation )
			{
				traverseToDirectoryComplete( operation );
			}
			else if ( event.target is ITraverseAllDirectoriesOperation )
			{
				traverseAllDirectoriesComplete( operation );
			}
			else if ( event.target is IWriteFileOperation )
			{
				writeFileComplete( operation );
			}
		}
		
		private function createDirectoryComplete( operation:IFileSystemProviderOperation ):void
		{
			addFile( operation.uri );
		}
		private function deleteComplete( operation:IFileSystemProviderOperation ):void
		{
			removeFile( operation.uri );
		}
		private function doesFileExistComplete( operation:IFileSystemProviderOperation ):void
		{
			addFile( operation.uri );
		}
		
		private function writeFileComplete( operation:IFileSystemProviderOperation ):void
		{
			addFile( operation.uri );
		}
		
		private function getDirectoryContentsComplete( operation:IFileSystemProviderOperation ):void
		{
			var getDirectoryContentsOperation:IGetDirectoryContentsOperation = IGetDirectoryContentsOperation(operation);
			repopulateDirectory( operation.uri, getDirectoryContentsOperation.contents );
		}
		
		private function traverseToDirectoryComplete( operation:IFileSystemProviderOperation ):void
		{
			var traverseToDirectoryOperation:ITraverseToDirectoryOperation = ITraverseToDirectoryOperation(operation);
			var allContents:Array = traverseToDirectoryOperation.contents;
			
			for ( var i:uint = 0; i < allContents.length; i ++ )
			{
				var uri:URI = allContents[i].uri;
				var contents:Vector.<URI> = allContents[i].contents;
				repopulateDirectory( uri, contents );
			}
		}
		
		private function traverseAllDirectoriesComplete( operation:IFileSystemProviderOperation ):void
		{
			var traverseOperation:ITraverseAllDirectoriesOperation = ITraverseAllDirectoriesOperation(operation);
			var allContents:Array = traverseOperation.contents;
			
			for ( var i:uint = 0; i < allContents.length; i ++ )
			{
				var uri:URI = allContents[i].uri;
				var contents:Vector.<URI> = allContents[i].contents;
				repopulateDirectory( uri, contents );
			}
		}
	}
}








