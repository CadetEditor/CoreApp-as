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
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import flox.app.core.managers.fileSystemProviders.IFileSystemProvider;
	import flox.app.core.managers.fileSystemProviders.operations.IReadFileOperation;
	import flox.app.entities.URI;
	import flox.app.managers.ResourceManager;
	import flox.app.resources.ExternalBitmapDataResource;
	import flox.app.resources.ExternalXMLResource;
	import flox.app.resources.FactoryResource;
	import flox.app.resources.IExternalResource;
	import flox.app.resources.IResource;
	import flox.app.util.IntrospectionUtil;
	import flox.app.util.swfClassExplorer.SwfClassExplorer;
	
	public class DefaultExternalResourceParser implements IExternalResourceParser
	{
		private var uri				:URI;
		private var resourceManager	:ResourceManager;
		private var loader			:Loader;
		private var swfResources	:Array;
		private var bytes			:ByteArray;
		
		public function DefaultExternalResourceParser()
		{
			swfResources = [];
		}
		
		public function parse(uri:URI, assetsURI:URI, resourceManager:ResourceManager, fileSystemProvider:IFileSystemProvider):Array
		{
			this.uri = uri;
			this.resourceManager = resourceManager;
			
			var extension:String = uri.getExtension(true);
			//var resourceID:String = uri.getFilename(true);
			//var resourceID:String = uri.path;
			var resourceID:String = uri.path;
			if ( resourceID.indexOf(assetsURI.path) != -1 ) {
				resourceID = resourceID.replace(assetsURI.path, "");
			}
				
			var resource:IExternalResource;
			switch ( extension )
			{
				case "png" :
				case "jpg" :
					resource = new ExternalBitmapDataResource( resourceID, uri );
					resourceManager.addResource(resource);
					return [resource];
				case "swf" :
					var readFileOperation:IReadFileOperation = fileSystemProvider.readFile(uri);
					readFileOperation.addEventListener( ErrorEvent.ERROR, readSWFFileErrorHandler );
					readFileOperation.addEventListener( Event.COMPLETE, readSWFFileCompleteHandler );
					readFileOperation.execute();
					swfResources = [];
					return swfResources;
				case "xml" :
					resource = new ExternalXMLResource( resourceID, uri );
					resourceManager.addResource(resource);
			}
			
			return null;
		}
		
		private function readSWFFileErrorHandler( event:ErrorEvent ):void
		{
			var readFileOperation:IReadFileOperation = IReadFileOperation(event.target);
			throw( new Error( "Error while reading SWF file in asset directory : " + readFileOperation.uri.path ) );
		}
		
		private function readSWFFileCompleteHandler( event:Event ):void
		{
			var readFileOperation:IReadFileOperation = IReadFileOperation(event.target);
			
			var loader:Loader = new Loader();
			bytes = readFileOperation.bytes;
			
			var context:LoaderContext = new LoaderContext( false, ApplicationDomain.currentDomain );
			if ( context.hasOwnProperty("allowCodeImport") )
			{
				context["allowCodeImport"] = true;
			}
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadSWFCompleteHandler);
			loader.loadBytes(readFileOperation.bytes, context);
		}
		
		private function loadSWFCompleteHandler( event:Event ):void
		{
			var loaderInfo:LoaderInfo = LoaderInfo(event.target);
			var resourceIDPrefix:String = uri.getFilename(false) + "/";
			
			bytes.position = 0;
			var classPaths:Vector.<String> = SwfClassExplorer.getClassNames(bytes);
			for each ( var classPath:String in classPaths )
			{
				var type:Class = Class( loaderInfo.applicationDomain.getDefinition(classPath) );
				var resourceID:String = resourceIDPrefix + classPath;
				var resource:IResource;
				if ( IntrospectionUtil.doesTypeExtend(type, DisplayObject) )
				{
					resource = new FactoryResource( type, classPath );
				}
				else if ( IntrospectionUtil.doesTypeExtend(type, BitmapData) )
				{
					resource = new FactoryResource( type, classPath, null, [0,0] );
				}
				
				if ( resource )
				{
					swfResources.push(resource);
					
					resourceManager.addResource(resource);
				}
			}
		}
	}
}