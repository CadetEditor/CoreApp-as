// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.controllers
{
	/**
	 * Monitors a folder in a filesystem via polling, creates an IExternalResource for each compatible
	 * file it finds and adds it to a ResourceManager.
	 * Files being deleted from this folder will have their corresponding IExternalResource removed.
	 * If the given directory does not exist, the controller will automatically create it.
	 */

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import core.app.CoreApp;
	import core.app.core.managers.fileSystemProviders.IMultiFileSystemProvider;
	import core.app.core.managers.fileSystemProviders.operations.ICreateDirectoryOperation;
	import core.app.core.managers.fileSystemProviders.operations.IDoesFileExistOperation;
	import core.app.core.managers.fileSystemProviders.operations.ITraverseAllDirectoriesOperation;
	import core.app.core.managers.fileSystemProviders.operations.ITraverseToDirectoryOperation;
	import core.app.entities.FileSystemNode;
	import core.app.entities.URI;
	import core.app.events.ResourceManagerEvent;
	import core.app.managers.ResourceManager;
	import core.app.resources.ExternalResourceParserFactory;
	import core.app.resources.IExternalResource;
	import core.app.resources.IFactoryResource;
	import core.app.resources.IResource;
	
	public class ExternalResourceController
	{
		private var _resourceManager	:ResourceManager;
		private var _assetsURI			:URI;
		private var _fileSystemProvider	:IMultiFileSystemProvider;
		private var parserFactories		:Vector.<IResource>;
		
		private var timer				:Timer;
		private var operationExecuting	:Boolean = false;
		
		private var resourcesByPath		:Object;
		private var uriByLoaderTable	:Dictionary;
		private var bytesByLoaderTable	:Dictionary;
		
		public function ExternalResourceController( resourceManager:ResourceManager, assetsURI:URI, fileSystemProvider:IMultiFileSystemProvider )
		{
			if ( assetsURI.isDirectory() == false )
			{
				throw( new Error( "URI needs to point to a directory" ) );
				return;
			}
			_resourceManager = resourceManager;
			_assetsURI = assetsURI;
			_fileSystemProvider = fileSystemProvider;
			
			resourcesByPath = {};
			uriByLoaderTable = new Dictionary();
			bytesByLoaderTable = new Dictionary();
			
			// We poll the directory contents once every 2 seconds.
			timer = new Timer( 2000, 0 );
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			
			// Check to see if the directory exists.
			// If not, we want to automatically create it.
			try
			{
				var doesDirectoryExistOperation:IDoesFileExistOperation = fileSystemProvider.doesFileExist(assetsURI);
				doesDirectoryExistOperation.addEventListener(Event.COMPLETE, doesDirectoryExistCompleteHandler);
				doesDirectoryExistOperation.addEventListener(ErrorEvent.ERROR, errorHandler);
				doesDirectoryExistOperation.execute();
			}
			catch( e:Error )
			{
				onAccessError();
				return;
			}
			
			// Build a list of IExternalResourceParser factories, and monitor the resource manager for more being added]
			parserFactories = new Vector.<IResource>();
			parserFactories.push( new ExternalResourceParserFactory( DefaultExternalResourceParser, "Default external resource parser", ["png", "jpg", "swf", "xml", "mp3"] ) );
			parserFactories = parserFactories.concat(resourceManager.getResourcesOfType(ExternalResourceParserFactory));
			resourceManager.addEventListener(ResourceManagerEvent.RESOURCE_ADDED, resourceAddedHandler);
		}
		
		public function dispose():void
		{
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, timerHandler);
			timer = null;
		}
		
		private function resourceAddedHandler( event:ResourceManagerEvent ):void
		{
			if ( event.resource is ExternalResourceParserFactory == false ) return;
			parserFactories.push( event.resource );
		}
		
		private function doesDirectoryExistCompleteHandler( event:Event ):void
		{
			var doesDirectoryExistOperation:IDoesFileExistOperation = IDoesFileExistOperation(event.target);
			// Directory already exists, great. Start polling its contents straight away.
			if ( doesDirectoryExistOperation.fileExists )
			{
				//timer.start();
				var node:FileSystemNode = CoreApp.fileSystemProvider.fileSystem.getChildWithPath( doesDirectoryExistOperation.uri.path, true );
				if ( node == null ) {
					var traverseOperation:ITraverseToDirectoryOperation = CoreApp.fileSystemProvider.traverseToDirectory(doesDirectoryExistOperation.uri);
					traverseOperation.addEventListener( Event.COMPLETE, traverseCompleteHandler );
					traverseOperation.execute();
				} else {
					update();
				}
			}
			// Nevermind, need to create it first.
			else
			{
				var createDirectoryOperation:ICreateDirectoryOperation = _fileSystemProvider.createDirectory(_assetsURI);
				createDirectoryOperation.addEventListener(Event.COMPLETE, createDirectoryCompleteHandler);
				createDirectoryOperation.addEventListener(ErrorEvent.ERROR, errorHandler);
				createDirectoryOperation.execute();
			}
		}
		
		private function createDirectoryCompleteHandler( event:Event ):void
		{
			// Ready, start polling.
			//timer.start();
			update();
		}
		
		private function timerHandler( event:TimerEvent ):void
		{
			if ( operationExecuting ) return;
			update();
		}
		
		private function update():void
		{
			operationExecuting = true;
			
			var traverseOperation:ITraverseAllDirectoriesOperation = CoreApp.fileSystemProvider.traverseAllDirectories(_assetsURI);
			traverseOperation.addEventListener( Event.COMPLETE, traverseAllCompleteHandler );
			traverseOperation.execute();
		}
		
		private function traverseCompleteHandler( event:Event ):void
		{
			update();
		}
		
		private function traverseAllCompleteHandler( event:Event ):void
		{
			operationExecuting = false;
			
			var fileSystem:FileSystemNode = _fileSystemProvider.fileSystem;
			var assetsNode:FileSystemNode = fileSystem.getChildWithPath(_assetsURI.path, true);
			
			var currentTable:Object = {};
			parseNode(assetsNode, currentTable);
			
			// Resource removed
			// If the resourcePath from resourcesByPath doesn't feature in currentTable, it must've
			// been removed since we last checked, so remove these resources from the ResourceManager
			for ( var resourcePath:String in resourcesByPath )
			{
				if ( currentTable[resourcePath] != null ) continue;
				
				var resources:Array = resourcesByPath[resourcePath];
				for each ( var resource:IFactoryResource in resources )
				{
					_resourceManager.removeResource(resource, false);
				}
				resourcesByPath[resourcePath] = null;
			}
		}
		
		private function parseNode( node:FileSystemNode, currentTable:Object ):void
		{
			for each ( var childNode:FileSystemNode in node.children )
			{
				var path:String = childNode.uri.path;
				currentTable[path] = true;
				
				if (childNode.uri.isDirectory()) {
					parseNode( childNode, currentTable );
				} else {
					// New resource found
					if ( resourcesByPath[path] == null ) {
						createResourceForURI( childNode.uri );
					}	
				}
				
			}	
		}
		
		private function onAccessError():void
		{
			throw( new Error( "ExternalResourceController cannot access file contents for it's given uri : " + _assetsURI.path + "\nIs there an appropriate filesystem provider registered to handle this path ?") );
			dispose();
		}
		
		private function errorHandler( event:ErrorEvent ):void
		{
			throw( new Error( "Failed to access external resource directory contents for uri : " + _assetsURI.path + 
			"\n Additional info : " + event.text ) );
		}

		private function createResourceForURI( uri:URI ):void
		{
			//var resourceID:String = uri.getFilename(false);
			var path:String = uri.path;
			if ( path.indexOf(_assetsURI.path) != -1 ) {
				path = path.replace(_assetsURI.path, "");
			}
			var resourceID:String = path;
			var extension:String = uri.getExtension(true).toLowerCase();
			//trace("createResourceForURI "+resourceID);
			
			// If the resource exists in the resourceManager, but a reference hasn't been stored to it
			// yet in the resourcesByPath table, add it there.
			// (Multiple resources can reside at the same url, e.g. swfs)
			var existingResource:IExternalResource = _resourceManager.getResourceByID(resourceID) as IExternalResource;
			if ( existingResource )
			{
				if ( resourcesByPath[uri.path] == null ) resourcesByPath[uri.path] = [];
				resourcesByPath[uri.path].push( existingResource );
				return;
			}
			
			// If the resource doesn't exist yet...
			// Loop through the parserFactories for one which handles the particular file extension
			for each ( var parserFactory:ExternalResourceParserFactory in parserFactories )
			{
				if ( parserFactory.supportedExtensions.indexOf(extension) == -1 ) continue;
				var parser:IExternalResourceParser = IExternalResourceParser(parserFactory.getInstance());
				
				resourcesByPath[uri.path] = parser.parse(uri, _assetsURI, _resourceManager, _fileSystemProvider);
			}
		}
	}
}