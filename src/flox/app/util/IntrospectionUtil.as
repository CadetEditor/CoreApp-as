// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.util
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class IntrospectionUtil
	{
		static private const descriptionCache		:Dictionary = new Dictionary();;
		
		/**
		 * Returns the fully qualified class path for an object.
		 * Eg MovieClip would be returned as flash.display.MovieClip 
		 * @param object
		 * @return 
		 * 
		 */		
		static public function getClassPath( object:Object ):String
		{
			return flash.utils.getQualifiedClassName(object).replace("::",".");
		}
		
		static public function isRelatedTo( objectA:*, objectB:* ):Boolean
		{
			var typeA:Class = getType(objectA);
			var typeB:Class = getType(objectB);
			
			if ( typeA == typeB ) return true;
			if ( doesTypeExtend( typeA, typeB ) ) return true;
			if ( doesTypeImplement( typeA, typeB ) ) return true;
			return false;
		}
		
		static public function getClassName( object:Object ):String
		{
			var classPath:String = flash.utils.getQualifiedClassName(object).replace("::",".");
			if ( classPath.indexOf(".") == -1 ) return classPath;
			var split:Array = classPath.split( "." );
			return split[split.length-1];
		}
		
		static public function getType( object:Object ):Class
		{
			var classPath:String = getClassPath( object );
			return Class( getDefinitionByName( classPath ) );
		}
		
		static public function doesTypeExtend( type:Class, superType:Class ):Boolean
		{
			var description:XML = getDescription( type );
			var superDescription:XML = getDescription( superType );
			return description.factory.extendsClass.( @type == superDescription.@name ).length() > 0;
		}
		
		static public function doesTypeImplement( type:Class, interfaceType:Class ):Boolean
		{
			if ( type == interfaceType ) return true;
			var description:XML = getDescription( type );
			var superDescription:XML = getDescription( interfaceType );
			return description.factory.implementsInterface.( @type == superDescription.@name ).length() > 0;
		}
		
		static public function getSuperType( object:Object ):Class
		{
			var description:XML = getDescription( object );
			return Class( getDefinitionByName( String( description.extendsClass[0].@type ) ) );
		}
		
		static public function getDistanceToSuperType( object:Object, superType:Class ):int
		{
			var superClassPath:String = getDescription( superType ).@name;			
			var description:XML  = getDescription( object );
			if ( description.@name == superClassPath ) return 0;
			var i:int
			for ( i = 0; i < description.implementsInterface.length(); i++ )
			{
				if ( description.implementsInterface[i].@type == superClassPath )
				{
					return 0;
				}
			}
			for ( i = 0; i < description.extendsClass.length(); i++ )
			{
				if ( description.extendsClass[i].@type == superClassPath )
				{
					return i+1;
				}
			}
			return -1;
		}
		
		public static function getPropertyMetadata( obj:Object, propertyName:String ):XMLList
		{
			var description:XML = getPropertyDescription( obj, propertyName );
			return description.metadata;
		}
		
		public static function getPropertyMetadataByName( obj:Object, propertyName:String, name:String):XML
		{
			var metadata:XMLList = getPropertyMetadata(obj, propertyName);
			if ( !metadata ) return null;
			return metadata.(@name==name)[0];
		}
		
		public static function getPropertyMetadataByNameAndKey( obj:Object, propertyName:String, name:String, key:String ):String
		{
			var metadataNode:XML = getPropertyMetadataByName(obj, propertyName, name);
			if ( !metadataNode ) return null;
			return String(metadataNode.arg.(@key==key)[0].@value);
		}
		
		public static function getMetadata( obj:* ):XMLList
		{
			var description:XML = getDescription(obj);
			return description.factory[0].metadata;
		}
		
		public static function getMetadataByName( obj:*, name:String ):XML
		{
			var metadata:XMLList = getMetadata(obj);
			if ( !metadata ) return null;
			return metadata.(@name==name)[0];
		}
		
		public static function getMetadataByNameAndKey( obj:*, name:String, key:String ):String
		{
			var metadataNode:XML = getMetadataByName(obj, name);
			if ( !metadataNode ) return null;
			return metadataNode.arg.(@key==key)[0].@value;
		}
		
		public static function getPropertyDescription( obj:*, propertyName:String ):XML
		{
			var description:XML = getDescription(obj);
			var propertyNode:XML = description.factory.accessor.(@name==propertyName)[0];
			
			if ( !propertyNode )
			{
				propertyNode = description.factory.variable.(@name==propertyName)[0];
			}
			
			return propertyNode;
		}
		
		/**
		 * It is preferable to use this function instead of flash.utils.describeType as it will
		 * cache returned values so further calls will execute much faster. This is particularly
		 * important when many descriptions may be needed, such as serialization or filtering . 
		 * @param obj
		 * @return 
		 * 
		 */		
		public static function getDescription( obj:* ):XML
		{
			var type:Class;
			if ( obj is Class )
			{
				type = obj as Class
			}
			else
			{
				var description:XML = describeType( obj );
				var classPath:String = String(description.@name).replace( "::", "." );
				type = getDefinitionByName( classPath ) as Class;
			}
			
			if ( descriptionCache[type] == null )
			{
				descriptionCache[type] = describeType(type);
			}
			return descriptionCache[type];
		}
		
		/**
		 * Returns the type of the property on the host.
		 * Use this method when a property on an object is set to null, but you'd still like to know
		 * the type specified for that property.
		 * 
		 */
		static public function getPropertyType( host:Object, propertyName:String ):Class
		{
			var propertyDescription:XML = getPropertyDescription( host, propertyName );
			var classPath:String = String( propertyDescription.@type );
			classPath = classPath.replace( "::", "." );
			return Class( getDefinitionByName(classPath) );
		}
	}
}

