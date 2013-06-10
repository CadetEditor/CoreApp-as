// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.managers.fileSystemProviders.url
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import core.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import core.app.core.managers.fileSystemProviders.operations.IGetDirectoryContentsOperation;
	import core.app.entities.URI;
	import core.app.events.OperationProgressEvent;

	internal class GetDirectoryContentsOperation extends EventDispatcher implements IGetDirectoryContentsOperation
	{
		private var _uri					:URI;
		private var _fileSystemProvider		:URLFileSystemProvider;
		private var _baseURL				:String;
		
		private var _contents				:Vector.<URI>;
		private var _defaultContentsXMLURL	:String = "_contents.xml";
		
		public function GetDirectoryContentsOperation( uri:URI, fileSystemProvider:URLFileSystemProvider, baseURL:String )
		{
			_uri = uri;
			_fileSystemProvider = fileSystemProvider;
			_baseURL = baseURL;
		}

		public function execute():void
		{
			var loader:URLLoader = new URLLoader();
			
			// Remove the FileSystemProvider's id from the start of the path;
			var localURI:URI = _uri.subpath(1);
			
			var url:String = _baseURL + localURI.path;
			if (url.charAt(url.length-1) != "/") {
				url = url + "/";
			}
			
			var request:URLRequest = new URLRequest( url + _defaultContentsXMLURL );
			request.contentType = URLLoaderDataFormat.TEXT;
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			loader.load(request);
		}
		
		private function errorHandler( event:ErrorEvent ):void
		{
			// Failed to find contents.xml, assume directory is empty.
			_contents = new Vector.<URI>();
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function progressHandler( event:ProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, event.bytesLoaded/event.bytesTotal ) );
		}
		
		private function loadCompleteHandler( event:Event ):void
		{
			var loader:URLLoader = URLLoader(event.target);
			
			var contentsXML:XML
			try
			{
				contentsXML = XML(loader.data);
			}
			catch (e:Error)
			{
				_contents = new Vector.<URI>();
				dispatchEvent( new Event( Event.COMPLETE ) );
				return;
			}
			
			_contents = new Vector.<URI>();
			for ( var i:int = 0; i < contentsXML.children().length(); i++ )
			{
				var child:XML = contentsXML.children()[i];
				
				if ( child.name() == "file" )
				{
					_contents.push( new URI( _uri.path + String( child.text() ) ) );
				}
				else if ( child.name() == "folder" )
				{
					_contents.push( new URI( _uri.path + String( child.text() + "/" ) ) );
				}
			}
			
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		public function get label():String
		{
			return "Get Directory Contents : " + _uri.path;
		}
		
		public function get uri():URI
		{
			return _uri;
		}
		
		public function get fileSystemProvider():IFileSystemProvider
		{
			return fileSystemProvider;
		}
		
		public function get contents():Vector.<URI>
		{
			return _contents;
		}
	}
}