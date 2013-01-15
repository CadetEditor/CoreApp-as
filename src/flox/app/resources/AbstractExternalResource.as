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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.IReadFileOperation;
	import flox.app.entities.URI;
	
	public class AbstractExternalResource extends EventDispatcher implements IExternalResource
	{
		protected var id					:String;
		protected var _uri					:URI;
		protected var fileSystemProvider	:IFileSystemProvider;
		protected var isLoaded				:Boolean = false;
		protected var isLoading				:Boolean = false;
		protected var type					:Class;
		
		public function AbstractExternalResource( id:String, uri:URI )
		{
			this.id = id;
			_uri = uri;
		}
		
		public function getLabel():String
		{
			return "External Resource";
		}
		
		public function load():void
		{
			if ( _uri == null )
			{
				throw( new Error( "No uri specified on ExternalResource" ) );
				return;
			}
			if ( fileSystemProvider == null )
			{
				throw( new Error( "No fileSystemProvider specified on ExternalResource" ) );
				return;
			}
			
			if ( isLoading ) return;
			if ( isLoaded )
			{
				dispatchEvent(new Event( Event.COMPLETE ));
				return;
			}
			isLoading = true;
			isLoaded = false;
			var operation:IReadFileOperation = fileSystemProvider.readFile(_uri);
			operation.addEventListener(Event.COMPLETE, readFileCompleteHandler);
			operation.execute();
		}
		
		public function unload():void
		{
			isLoaded = false;
			isLoading = false;
		}
		
		private function readFileCompleteHandler( event:Event ):void
		{
			// Ignore callback if we've been unloaded during load.
			if ( isLoading == false ) return;
			
			var operation:IReadFileOperation = IReadFileOperation(event.target);
			parseBytes( operation.bytes );
		}
		
		protected function parseBytes( bytes:ByteArray ):void
		{
			throw( new Error( "Subclass must override this method." ) );
		}
		
		// Implement IFactoryResource
		public function getInstance():Object
		{
			throw( new Error( "Subclass must override this method." ) );
		}
		
		
		public function getUri():URI
		{
			return _uri;
		}
		
		public function setFileSystemProvider(value:IFileSystemProvider):void
		{
			fileSystemProvider = value;
		}
		
		public function getIsLoaded():Boolean
		{
			return isLoaded;
		}
		
		public function getIsLoading():Boolean
		{
			return isLoading;
		}
		
		public function getID():String
		{
			return id;
		}
		
		public function getInstanceType():Class
		{
			return type;
		}
	}
}