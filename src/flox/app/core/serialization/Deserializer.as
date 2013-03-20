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
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.clearInterval;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	import flox.app.events.SerializeProgressEvent;
	
	[Event( type="flox.app.events.SerializeProgressEvent", name="progress" )]
	[Event( type="flash.events.Event", name="complete" )]
	[Event( type="flash.events.ErrorEvent", name="error" )]
	public class Deserializer extends EventDispatcher
	{
		private static const descriptionTable				:Dictionary = new Dictionary();
		private static var defaultManifest					:Manifest;
		
		private const x						:Namespace 	= new Namespace("x", "flox.app.core.serialization.Serializer")
		private const ELEMENT				:String = "element";
		private const ATTRIBUTE				:String = "attribute";
		
		private var result					:*;
		private var working					:Boolean;
		private var timeout					:uint;
		private var manifest				:Manifest;
		private var executionTime			:int;
		private var numTasksPerformed		:int;
		private var totalTasks				:int;
		private var instanceTable			:Object;
		private var pluginTable				:Object;
		private var tasksHead				:DeserializeTask;
		private var tasksTail				:DeserializeTask;
		private var currentTask				:DeserializeTask;
		private var progressEvent			:SerializeProgressEvent;
		
		public function Deserializer() 
		{
			progressEvent = new SerializeProgressEvent(SerializeProgressEvent.PROGRESS);
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
		
		public static function setDefaultManifest( value:Manifest ):void
		{
			defaultManifest = value;
		}
		
		public function setManifest( value:Manifest ):void
		{
			manifest = value;
		}
		
		// Deserialization //////////////////////////////////////////////////////////////////////////////////////////////
		
		public function getResult():* { return result; }
		
		public function deserializeAsync( xml:XML, executionTime:int = 33 ):void
		{
			if ( working )
			{
				throw( new Error( "Cannot perform multiple serializations. Wait for previous serialization to finish before starting another" ) );
				return;
			}
			
			this.executionTime = executionTime;
			_deserialize( xml );
		}
		
		public function deserialize( xml:XML ):*
		{
			if ( working )
			{
				throw( new Error( "Cannot perform multiple serializations. Wait for previous serialization to finish before starting another" ) );
				return;
			}
			
			executionTime = -1;
			_deserialize( xml );
			return result;
		}
		
		
		private function _deserialize( xml:XML ):void
		{
			instanceTable = {};
			result = null;
			numTasksPerformed = 0;
			
			tasksHead = null;
			buildTaskList( xml, null );
			
			
			
			currentTask = tasksHead;
			
			if ( executionTime == -1 )
			{
				update();
			}
			else
			{
				clearInterval(timeout);
				timeout = setInterval(update, 0);
			}
		}
		
		
		private function update():void
		{
			// Comment out this try/catch to throw specific errors.
			try
			{
				var start:int = getTimer();
				while ( currentTask )
				{
					processTask( currentTask );
					numTasksPerformed++;
					var prevTask:DeserializeTask = currentTask;
					currentTask = currentTask.next;
					prevTask.next = null;
					
					if ( executionTime == -1 ) continue;
					if ( (getTimer()-start) > executionTime )
					{
						progressEvent.numItems = numTasksPerformed;
						progressEvent.totalItems = totalTasks;
						dispatchEvent( progressEvent );
						return;
					}
				}
			}
			catch ( e:Error )
			{
				clearInterval(timeout);
				working = false;
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, e.message ) );
				return;
			}
			
			clearInterval(timeout);
			
			result = tasksHead.instance;
			working = false;
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function processTask( task:DeserializeTask ):void
		{
			var xml:XML = task.xml;
			var classPath:String;
			var type:Class;
				
			if ( task.parentTask != null )
			{
				task.name = getRealName( task.parentTask.instance, task.name );
			}
			
			task.deserializeFunc( task );
		}
		
		private function deserializeRef( task:DeserializeTask ):void
		{
			task.instance = instanceTable[ task.id ];
			if ( task.instance == null )
			{
				// If the reference has not yet been deserialized, then move this task to the end of the task list.
				// The instance it is referencing will have a task somewhere between here and the end of the list,
				// so we can guarantee it's reference will be ready the next time it is visited.
				tasksTail.next = task;
				tasksTail = task;
				return;
			}
			if ( task.parentTask )
			{
				task.parentTask.instance[ task.name ] = task.instance;
			}
		}
		
		private function deserializeInBuiltType( task:DeserializeTask ):void
		{
			switch ( task.type )
			{
				case Array :
					var array:Array = [];
					task.instance = array;
					
					if ( task.parentTask )
					{
						task.parentTask.instance[ task.name ] = array;
					}
					
					instanceTable[  task.id ] = task.instance;
					break;
				case Class :
					task.instance = task.type;
					
					if ( task.parentTask )
					{
						task.parentTask.instance[ task.name ] = task.instance;
					}
					
					break;
				case Vector.<*> :
					var vectorTypeName:String = "Vector.<" + task.xml.@x::T + ">"
					var vectorType:Class = Class( getDefinitionByName( vectorTypeName ) );
					var vector:Vector.<*> = new vectorType();
					task.instance = vector;
					
					if ( task.parentTask )
					{
						task.parentTask.instance[ task.name ] = vector;
					}
					
					instanceTable[ int( task.xml.@x::id ) ] = task.instance;
					break;
			}

		}
		
		private function deserializeObject( task:DeserializeTask ):void
		{
			var instance:Object = new task.type();
			task.instance = instance;
			
			if ( task.parentTask )
			{
				task.parentTask.instance[ task.name ] = instance;
			}
				
			instanceTable[ task.id ] = task.instance;
		}
		
		private function deserializeSimpleType( task:DeserializeTask ):void
		{
			// Try setting this property on the instance.
			// This is in a try/catch because most deserialization errors arise from
			// a property no longer existing on an object. So if you've removed a serializable 
			// property from a class since you serialized this data, this will fail silently.
			var value:String = task.xml.toString();
			try
			{
				switch( task.type )
				{
					case String :
						task.parentTask.instance[ task.name ] = value;
						break;
					case Number :
						task.parentTask.instance[ task.name ] = Number( value );
						break;
					case Boolean :
						task.parentTask.instance[ task.name ] = value == "1";
						break;
					default :
						task.parentTask.instance[ task.name ] = value;
						break;
				}
			}
			catch ( e:Error )
			{
				trace("Deserialize Error : " + e.message);
			}
		}
		
		private function buildTaskList( xml:XML, parentTask:DeserializeTask  ):void
		{
			var task:DeserializeTask = new DeserializeTask();
			task.parentTask = parentTask;
			task.xml = xml;
			totalTasks++;
			if ( tasksHead == null )
			{
				tasksHead = currentTask = task;
			}
			else
			{
				currentTask.next = currentTask = task;
			}
			tasksTail = task;
			
			if ( xml.nodeKind() == ELEMENT )
			{
				task.name = xml.@x::name;
				task.id = xml.@x::id;
				
				// Determine type of node
				if ( xml.namespace() == x )
				{
					if ( xml.localName() == "Ref" )
					{
						task.deserializeFunc = deserializeRef;
					}
					else
					{
						task.deserializeFunc = deserializeInBuiltType;
						switch ( String( xml.name() ) )
						{
							case "Array" :
								task.type = Array;
								break;
							case "Vector" : 
								task.type = Class( getDefinitionByName( "Vector.<" + xml.@x::T + ">" ) ); 
								break;
							case "Class" :
								task.type = Class( getDefinitionByName( xml.@classPath ) ); 
								break;
							default :
								throw( new Error( "Unknown type" ) );
								break;
						}
					}
				}
				else
				{
					var localManifest:Manifest = manifest || defaultManifest;
					if ( localManifest )
					{
						var ns:Namespace = xml.namespace();
						task.type = localManifest.getTypeForPrefixAndName( ns.prefix, xml.localName() );
					}
					if ( task.type == null )
					{
						var classPath:String = String( xml.name() ).replace( "::", "." );
						task.type = Class( getDefinitionByName( classPath ) );
					}

					task.deserializeFunc = deserializeObject;
				}
				
				var i:int;
				var len:int = xml.attributes().length();
				var attributes:XMLList = xml.attributes();
				for ( i = 0; i < len; i++ )
				{
					var attribute:XML = attributes[i];
					if ( attribute.namespace() == x ) continue; // Ignore serializer namespace properties
					buildTaskList( attribute, task );
				}
				
				len = xml.children().length();
				var children:XMLList = xml.children();
				for ( i = 0; i < len; i++ )
				{
					var child:XML = children[i];
					buildTaskList( child, task );
				}
			}
			else //if ( xml.nodeKind() == ATTRIBUTE ) - Commented out, as this is implicit.
			{
				task.name = xml.name();
				task.deserializeFunc = deserializeSimpleType;
				
				var description:XML = describeType(parentTask.type);
				try
				{
					var propertyTypeClassPath:String = description.descendants().( name() == "variable" || name() == "accessor" ).( @name == task.name )[0].@type;
					task.type = Class(getDefinitionByName(propertyTypeClassPath.replace("::", ".")));
				}
				catch ( e:Error )
				{
					task.type = String;
				}
			}
			
			if ( task.type == null && task.deserializeFunc == null )
			{
				throw( new Error( "Unkown type" ) );
			}
			
			// Determine if this item has a custom serializer
			// We do this by getting the metadata for the property on the item this item is a child of.
			if ( parentTask )
			{
				description = describeType(parentTask.type);
				var metadata:XML = description.descendants().( name() == "variable" || name() == "accessor" ).( @name == task.name ).elements( "metadata" ).( @name == "Serializable" )[0];
				if ( metadata != null )
				{
					var pluginID:String = String( metadata.arg.( @key=="type" ).@value );
					if ( pluginID != "" && pluginID != null && pluginID != "rawObject" )
					{
						if ( pluginTable[pluginID] == null )
						{
							throw( new Error( "Cannot find plugin to handle custom deserialization of type : " + pluginID ) );
						}
						
						task.deserializeFunc = pluginTable[pluginID].deserialize;
					}
				}
			}
			
			// Use in-built deserializer func if no custom one found
			if ( task.deserializeFunc == null )
			{
				throw( new Error( "Could not assign appropriate deserializer function for xml : " + xml.toXMLString() ) );
			}
		}
		
		// Static utils
		private static function getRealName( obj:*, propertyName:String ):String
		{
			var description:XML = describeType( obj );
			
			var metadata:XMLList = description.elements("accessor").elements("metadata").( @name == "Serializable" ).elements("arg").(@key == "alias" && @value == propertyName);
			if ( metadata.length() > 0 )
			{
				return( metadata[0].parent().parent().@name );
			}
			
			metadata = description.elements("variable").elements("metadata").( @name == "Serializable" ).elements("arg").(@key == "alias" && @value == propertyName);
			if ( metadata.length() > 0 )
			{
				return( metadata[0].parent().parent().@name );
			}
			return propertyName;
		}
		
		/**
		 * Utility function to speed up the retreival of a type description.
		 * @param type
		 * @return 
		 */		
		private static function describeType( type:* ):XML
		{
			return descriptionTable[type] ? descriptionTable[type] : descriptionTable[type] = flash.utils.describeType( type );
		}
		
		private static function getPropertyType( object:*, propertyName:String ):Class
		{
			var description:XML = describeType( object );
			
			var typeClassPath:String = description..children().( name() == "variable" || name() == "accessor" ).(@name == propertyName).@type;
			if ( typeClassPath )
			{
				return flash.utils.getDefinitionByName( typeClassPath ) as Class;
			}
			
			typeClassPath = description.elements("variable").(@name == propertyName).@type;
			if ( typeClassPath )
			{
				return flash.utils.getDefinitionByName( typeClassPath ) as Class;
			}
			return null;
		}
	}
}