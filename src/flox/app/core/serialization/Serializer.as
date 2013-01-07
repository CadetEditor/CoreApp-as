// =================================================================================================
//
//	FloxApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package flox.app.core.serialization
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.clearInterval;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	import flox.core.data.ArrayCollection;
	
	import flox.app.events.SerializeProgressEvent;
	import flox.app.util.IntrospectionUtil;

	[Event( type="flox.app.events.SerializeProgressEvent", name="progress" )]
	[Event( type="flash.events.ErrorEvent", name="error" )]
	[Event( type="flash.events.Event", name="complete" )]
	
	public class Serializer extends EventDispatcher
	{
		public static var defaultManifest	:Manifest;
		public static const x:Namespace 	= new Namespace("x", "flox.app.core.serialization.Serializer")
		
		private static const descriptionTable				:Dictionary = new Dictionary();
		private static const cachedSerializableProperties	:Dictionary = new Dictionary();
		
		public static function setDefaultManifest( value:Manifest ):void
		{
			defaultManifest = value;
		}
		
		private var executionTime			:int;
		private var working					:Boolean = false;
		private var index					:int;
		private var timeout					:int;
		private var manifest				:Manifest;
		private var markTable				:Dictionary;
		private var pluginTable				:Object;
		private var rootXML					:XML;
		private var referenceID				:int;
		private var namespaces				:Object;
		private var namespaceIndex			:int;
		private var xmlTable				:Dictionary;
		private var tasks					:Vector.<SerializerTask>;
		private var result					:XML;
		private var progressEvent			:SerializeProgressEvent;
		
		public function Serializer()
		{
			progressEvent = new SerializeProgressEvent( SerializeProgressEvent.PROGRESS );
			pluginTable = {};
		}
		
		public function addPlugin( value:ISerializationPlugin ):void
		{
			if ( pluginTable[value.id] != null )
			{
				throw( new Error( "Plugin with this id already added : " + value.id ) );
				return;
			}
			pluginTable[value.id] = value;
		}
		
		public function setManifest( manifest:Manifest ):void
		{
			this.manifest = manifest;
		}
		
		public function clone( object:* ):*
		{
			return new Deserializer().deserialize(serialize(object));
		}
		
		public function getResult():XML { return result; }
		
		public function serializeAsync( item:*, executionTime:int = 33 ):void
		{
			if ( working )
			{
				throw( new Error( "Cannot perform multiple serializations. Wait for previous serialization to finish before starting another" ) );
				return;
			}
			if ( item == null )
			{
				throw( new Error( "Invalid parameter. item must be non-null" ) );
				return;
			}
			
			this.executionTime = executionTime;
			_serialize( item );
		}
		
		public function serialize( item:* ):XML
		{
			if ( working )
			{
				throw( new Error( "Cannot perform multiple serializations. Wait for previous serialization to finish before starting another" ) );
				return null;
			}
			if ( item == null )
			{
				throw( new Error( "Invalid parameter. item must be non-null" ) );
				return null;
			}
			
			executionTime = -1;
			_serialize( item );
			return result;
		}
		
		private function _serialize( item:* ):void
		{
			working = true;
			markTable = new Dictionary(true);
			referenceID = 0;
			namespaces = {};
			namespaceIndex = 0;
			xmlTable = new Dictionary(true);
			rootXML = <xml/>;
			index = 0;
			result = null;
			
			tasks = new Vector.<SerializerTask>;
			buildSerializerTaskList( item, null, null );
			
			if ( executionTime == -1 )
			{
				update();
			}
			else
			{
				clearInterval(timeout);
				timeout = setInterval( update, 0 );
			}
		}
		
		/**
		 * Recursively builds a flat array of SerializerTask instances. These task classes indicate a single serialization
		 * task of a value. The order in which they are placed in the list comes about naturally from the order in which
		 * each object in the dom is visited. This order is also naturally re-created when deserializing.
		 * @param value
		 * @param obj
		 * @param name
		 * @param tasks
		 */		
		private function buildSerializerTaskList( value:*, obj:Object, propertyName:String = null, propertyAlias:String = null, serializeType:String = null ):void
		{
			var task:SerializerTask = new SerializerTask();
			task.propertyName = propertyName;
			task.propertyAlias = propertyAlias;
			task.value = value;
			task.obj = obj;
			task.manifest = manifest || defaultManifest;
						
			// If this property has had a custom [Serializer( type="value") ] tag added, then
			// we try to assign the serializer function to a custom registered function.
			if ( serializeType != null && serializeType != "rawObject" )
			{
				var plugin:ISerializationPlugin = pluginTable[serializeType];
				if ( plugin == null )
				{
					throw( new Error("Cannot find plugin for id : " + serializeType));
				}
				if ( value == null && plugin.allowNullValue == false ) return;
				tasks.push( task );
				task.serializeFunc = plugin.serialize;
				return;
			}
			
			if ( value == null ) return;
			
			// Simple types can't be recusively serialized (ie, they don't themselves have properties)
			if ( value is String || value is Number || value is Boolean || value is Class )
			{
				task.serializeFunc = serializeSimpleType;
				tasks.push( task );
				return;
			}
			
			if ( markTable[ value ] != null )
			{
				task.serializeFunc = serializeReference;
				task.id = markTable[ value ];
				tasks.push( task );
				return;
			}
			
			task.serializeFunc = serializeComplexType;
			tasks.push( task );
			task.id = referenceID++;
			markTable[ value ] = task.id;
			
			var properties:Vector.<String> 
			if ( serializeType == "rawObject" )
			{
				properties = new Vector.<String>();
				for ( var prop:String in value )
				{
					properties.push(prop, prop, null);
				}
			}
			else
			{
				properties = getSerializableProperties( value );
			}
			var len:int = properties.length;
			for ( var i:int = 0; i < len; i+=3 )
			{
				var propertyName:String = properties[i];
				var propertyAlias:String = properties[i+1];
				var serializeType:String = properties[i+2];
				var childValue:* = value[propertyName];
				buildSerializerTaskList( childValue, value, propertyName, propertyAlias, serializeType );
			}
		}
		
		private function update():void
		{
			var time:int = getTimer();
			var len:int = tasks.length;
			while ( index < len )
			{
				var task:SerializerTask = tasks[index];
				processTask( task );
				index++;
				
				if ( executionTime == -1 ) continue;
				if ( ( getTimer() - time ) > executionTime )
				{
					progressEvent.numItems = index;
					progressEvent.totalItems = tasks.length;
					dispatchEvent( progressEvent );
					return;
				}
			}
			
			clearInterval(timeout);
			result = rootXML.children()[0];
			working = false;
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		/**
		 * Not recursive. This function serializes a single value described by the passed SerializerTask instance. The resulting
		 * xml is then appended to the appropriate parent node ( stored in xmlTable ).
		 * @param task
		 * 
		 */		
		private function processTask( task:SerializerTask ):void
		{
			var value:* = task.value;
			var xml:XML;
			var description:XML;
			var classPath:String;
			
			task.parentXML = xmlTable[task.obj];
			if ( !task.parentXML ) task.parentXML = rootXML;
			
			var result:XML = task.serializeFunc( task );
			if ( result )
			{
				task.parentXML.appendChild(result);
				xmlTable[ task.value ] = result;
				result.addNamespace( x );
			}
		}
		
		private function serializeReference( task:SerializerTask ):XML
		{
			var xml:XML = <Ref/>;
			xml.@x::name = task.propertyAlias;
			xml.setNamespace( x );
			xml.@x::id = task.id;
			return xml;
		}
		
		private function serializeSimpleType( task:SerializerTask ):XML
		{
			var xml:XML
			var value:* = task.value;
			// Simple data types
			if ( value is Number && isNaN( Number( value ) ) == false )
			{
				task.parentXML.@[task.propertyAlias] = String( value );
			}
			else if ( value is Boolean )
			{
				task.parentXML.@[task.propertyAlias] = value ? "1" : "0";
			}
			else if ( value is String )
			{
				task.parentXML.@[task.propertyAlias] = String( value );
			}
			else if ( value is XML ) 
			{
				xml = <XML>{escape( String( value ) )}</XML>;
				if ( task.propertyAlias ) xml.@x::name = task.propertyAlias;
				return xml;
			}
			else if ( value is Class )
			{
				var description:XML = describeType( value );
				xml = <Class/>;
				xml.@classPath = String( description.@name ).replace("::", ".");
				if ( task.propertyAlias ) xml.@x::name = task.propertyAlias;
				return xml;
			}
			
			return null;
		}
		
		private function serializeComplexType( task:SerializerTask ):XML
		{
			var xml:XML
			var value:* = task.value;
			var description:XML;
			// Complex data types
			if ( value is Array )
			{
				xml = <Array/>;
				if ( task.propertyAlias ) xml.@x::name = task.propertyAlias;
				xml.@x::id = task.id;
				return xml;
			}
			else if ( value is Vector.<*> )
			{
				xml = <Vector/>;
				description = describeType( value );
				var type:String = String( description.@name );
				type = type.substring( type.lastIndexOf( "<" )+1, type.length-1 ).replace( "::","." );
				xml.@x::T = type
				if ( task.propertyAlias ) xml.@x::name = task.propertyAlias;
				xml.@x::id = task.id;
				
				return xml;
			}
			else
			{
				description = describeType( value );
				var split:Array = String( description.@name ).split("::")
				var classPath:String = split.length == 1 ? "" : split[0];
				var className:String = split.length == 1 ? split[0] : split[1];
				
				xml = XML("<" + className + "/>");
				if ( task.propertyAlias ) xml.@x::name = task.propertyAlias;
				xml.@x::id = task.id;
				
				// If the class type is not in the default package, we need to add a namespace to the xml so no clashes occur.
				if ( classPath != "" )
				{
					var fullyQualifiedClassPath:String = classPath + "." + className;
					var ns:Namespace;
					var localManifest:Manifest = manifest || defaultManifest;
					if ( localManifest )
					{
						ns =  localManifest.getNamespaceForClassPath(fullyQualifiedClassPath);
					}
					
					if ( ns == null )
					{
						// Check if we've already created a namespace for this classPath.
						ns = namespaces[classPath];
						if ( !ns ) 
						{
							ns = new Namespace( "ns"+namespaceIndex++, classPath );
							namespaces[classPath] = ns;
						}
					}
					
					rootXML.addNamespace( ns );
					xml.setNamespace( ns );
				}
				
				return xml;
			}
			
			return null;
		}
		
		private static function describeType( type:* ):XML
		{
			return descriptionTable[type] ? descriptionTable[type] : descriptionTable[type] = flash.utils.describeType( type );
		}
		
		/**
		 * Given an object, this function returns an array of properties names on that object that are
		 * elegible for serialization. This is determined by the [Serializable] metadata tag. 
		 * @param item
		 * @return 
		 * 
		 */		
		private function getSerializableProperties( item:* ):Vector.<String>
		{
			var properties:Vector.<String> = new Vector.<String>();
			if ( item is Object == false ) return properties;
			
			var type:Class = IntrospectionUtil.getType(item);
			if ( cachedSerializableProperties[type] )
			{
				return cachedSerializableProperties[type];
			}
			
			var j:int;
			var len:int;
			
			if ( item is Array || item is ArrayCollection || item is Vector.<*> )
			{
				len = item.length;
				for ( j = 0; j < len; j++ )
				{
					properties.push(  String( j ),  String( j ), null );
				}
				return properties;
			}
			if ( item is Object )
			{
				var description:XML = describeType( item );
				
				cachedSerializableProperties[type] = properties;
				
				
				var nodes:XMLList = description.children().( name() == "variable" || name() == "accessor" ).elements("metadata").( @name == "Serializable" );
				
				len = nodes.length();
				for ( var i:int = 0; i < len; i++ )
				{
					var metadata:XML = nodes[i];
					
					// The Serializer allows the [Serializable] metadata tag to specify a 'inherit' key. If this is false,
					// the serializer deems the property to *not* be serializable.
					// This allows subclasses to override properties on their base class and force them not to be serializable.
					if ( metadata.arg.( @key=="inherit" ).@value == "false" ) continue;
					var propertyName:String = String( metadata.parent().@name );
					var alias:String = String( metadata.arg.( @key=="alias" ).@value );
					if ( alias == "" ) alias = propertyName;
					var pluginID:String = String( metadata.arg.( @key=="type" ).@value );
					if ( pluginID == ""  )
					{
						pluginID = null;
					}
					else if ( pluginTable[pluginID] == null && pluginID != "rawObject" )
					{
						throw( new Error( "Cannot find plugin to handle custom serialization of type : " + pluginID ) );
					}
					properties.push ( propertyName, alias, pluginID );
				}
				
				return properties;
			}
			
			return new Vector.<String>();
		}
	}
}



