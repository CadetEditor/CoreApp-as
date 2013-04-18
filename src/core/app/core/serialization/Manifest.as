// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.core.serialization
{
	import flash.utils.getDefinitionByName;
	
	import core.app.resources.IResource;

	public class Manifest implements IResource
	{
		private var namespaceVar				:Namespace;
		private var classMaps					:Object;
		private var namespaceTable				:Object;
		
		public function Manifest()
		{
			namespaceTable = {};
			classMaps = {};
		}
		
		public function getLabel():String
		{
			return "Manifest";
		}
		
		public function getNamespaceForClassPath( classPath:String ):Namespace
		{
			return namespaceTable[classPath];
		}
		
		public function getTypeForPrefixAndName( prefix:String, name:String ):Class
		{
			var classMap:ManifestClassMap = classMaps[ prefix + ":" + name ];
			if (!classMap)
			{
				return null;
			}
			return classMap.type;
		}
				
		public function parse( xml:XML ):void
		{
			
			var prefix:String = xml.@prefix;
			if ( prefix == null )
			{
				throw( new Error( "Missing 'prefix' attribute for manifest xml : " + xml.toXMLString() ) );
				return;
			}
			
			var url:String = xml.@url;
			if ( url == null )
			{
				throw( new Error( "Missing 'url' attribute for manifest xml : " + xml.toXMLString() ) );
				return;
			}
			
			namespaceVar = new Namespace( prefix, url );
			
			for ( var i:int = 0; i < xml.classMap.length(); i++ )
			{
				var classMapNode:XML = xml.classMap[i];
				
				var classMap:ManifestClassMap = new ManifestClassMap();
				
				classMap.name = classMapNode.@name;
				if ( classMap.name == null )
				{
					throw( new Error( "Missing 'name' attribute for classMap node : " + classMapNode.toXMLString() ) );
					continue;
				}
				
				try
				{
					classMap.classPath = classMapNode.attribute("class");
					classMap.type = Class(getDefinitionByName( classMap.classPath ));
				}
				catch (e:Error)
				{
					trace("Warning : Could not find class for classMap node : " + classMapNode.toXMLString() );
					trace("Attempting to deserialize XML containing this class will fail")
					continue;
				}
				
				
				namespaceTable[classMap.classPath] = namespaceVar;
				classMaps[prefix + ":" + classMap.name] = classMap;
			}
		}
		
		// Implement IResouce
		
		public function getID():String
		{
			return"Manifest";
		}
	}
}

internal class ManifestClassMap
{
	public var name			:String;
	public var classPath	:String;
	public var type			:Class;
	
	public function ManifestClassMap()
	{
		
	}
}