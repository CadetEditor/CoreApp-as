// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app
{
	import flash.utils.Dictionary;
	
	import core.app.core.managers.fileSystemProviders.IMultiFileSystemProvider;
	import core.app.core.managers.fileSystemProviders.MultiFileSystemProvider;
	import core.app.managers.ResourceManager;

	public class CoreApp
	{
		static private var _initialised					:Boolean;
		static private var _fileSystemProvider			:IMultiFileSystemProvider;
		static private var _resourceManager				:ResourceManager;
		
		static private var _externalResourceFolderName	:String = "assets/";
		static private var _externalResourceControllers	:Dictionary;
		
		// Getters for the managers and providers
		static public function get fileSystemProvider()	:IMultiFileSystemProvider	{ return _fileSystemProvider;	}
		static public function get resourceManager()	:ResourceManager 			{ return _resourceManager;		}
		
		static public function get externalResourceFolderName():String { return _externalResourceFolderName; }
		static public function set externalResourceFolderName(value:String):void { _externalResourceFolderName = value; }
		
		static public function get externalResourceControllers():Dictionary { return _externalResourceControllers; }
		
		static public function get initialised():Boolean { return _initialised; }
		
		static public function init():void
		{
			_fileSystemProvider 	= new MultiFileSystemProvider();
			_resourceManager 		= new ResourceManager(_fileSystemProvider);
			
			_externalResourceControllers = new Dictionary();
			
			_initialised			= true;
		}
		
		
	}
}