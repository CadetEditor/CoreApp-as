// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.operations
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
	
	import core.app.core.operations.IOperation;
	import core.app.core.serialization.Manifest;
	import core.app.events.OperationProgressEvent;
	
	public class LoadManifestOperation extends EventDispatcher implements IOperation
	{
		private var url		:String;
		private var manifest	:Manifest;
		
		public function LoadManifestOperation( url:String, manifest:Manifest )
		{
			this.url = url;
			this.manifest = manifest;
		}
		
		public function execute():void
		{
			var request:URLRequest = new URLRequest( url );
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onLoadComplete );
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress );
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.load( request );
		}
		
		private function onProgress( event:ProgressEvent ):void
		{
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, event.bytesLoaded / event.bytesTotal ) );
		}
		
		private function onError( event:ErrorEvent ):void
		{
			dispatchEvent( new ErrorEvent( "Failed to load manifest file at : " + url ) );
		}
		
		private function onLoadComplete( event:Event ):void
		{
			var loader:URLLoader = URLLoader(event.target);
			
			
			try
			{
				var xml:XML = XML(loader.data);
				manifest.parse(xml);
			}
			catch(e:Error)
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "An error occured while parsing manifest XML : " + e.message ) );
			}
			
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		public function get label():String
		{
			return "Load Manifest : " + url;
		}
	}
}