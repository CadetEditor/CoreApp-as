// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.operations
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import flox.app.FloxApp;
	import flox.app.core.operations.IOperation;
	import flox.app.core.serialization.Deserializer;
	import flox.app.core.serialization.Manifest;
	import flox.app.core.serialization.Serializer;
	import flox.app.events.OperationProgressEvent;
	
	import org.osmf.utils.URL;
	
	public class LoadManifestsOperation extends CompoundOperation
	{
		private var manifestsXML	:XMLList;
		private var manifest		:Manifest;
		
		public function LoadManifestsOperation( manifestsXML:XMLList )
		{
			this.manifestsXML = manifestsXML;
		}
		
		override public function execute():void
		{
			manifest = new Manifest();
			FloxApp.resourceManager.addResource( manifest );
			Serializer.setDefaultManifest(manifest);
			Deserializer.setDefaultManifest(manifest);
			
			for ( var i:int = 0; i < manifestsXML.length(); i++ )
			{
				var manifestNode:XML = manifestsXML[i];
				var url:String = String(manifestNode.url[0].text());
				
				var loadManifestOperation:LoadManifestOperation = new LoadManifestOperation( url, manifest );
				addOperation(loadManifestOperation);
			}
			
			super.execute();
		}
		
		override public function get label():String
		{
			return "Load manifests.";
		}
	}
}