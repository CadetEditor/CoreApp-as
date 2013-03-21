// =================================================================================================
//
//	CoreApp Framework
//	Copyright 2012 Unwrong Ltd. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package core.app.managers
{
	import flash.utils.Dictionary;
	import core.data.ArrayCollection;
	import core.events.ArrayCollectionChangeKind;
	import core.events.ArrayCollectionEvent;
	
	public class DependencyManager
	{
		protected var dependencyNodesTable		:Dictionary;
		private var _dependencyNodes			:ArrayCollection;
		
		public function DependencyManager()
		{
			dependencyNodes = new ArrayCollection();
		}
		
		[Serializable]
		public function set dependencyNodes( value:ArrayCollection ):void
		{
			dependencyNodesTable = new Dictionary(true);
			
			if ( _dependencyNodes )
			{
				_dependencyNodes.removeEventListener(ArrayCollectionEvent.CHANGE, dependencyNodesChangeHandler);
			}
			_dependencyNodes = value;
			if ( _dependencyNodes )
			{
				_dependencyNodes.addEventListener(ArrayCollectionEvent.CHANGE, dependencyNodesChangeHandler);
				
				for ( var i:int = 0; i < _dependencyNodes.length; i++ )
				{
					var node:DependencyNode = DependencyNode( _dependencyNodes.getItemAt( i ) );
					dependencyNodesTable[node.object] = node;
				}
			}
		}
		public function get dependencyNodes():ArrayCollection { return _dependencyNodes; }
		
		private function dependencyNodesChangeHandler( event:ArrayCollectionEvent ):void
		{
			var node:DependencyNode;
			if ( event.kind == ArrayCollectionChangeKind.ADD )
			{
				dependencyNodesTable[event.item.object] = node;
			}
			else if ( event.kind == ArrayCollectionChangeKind.REMOVE )
			{
				delete dependencyNodesTable[event.item.object];
			}
		}
		
		
		public function addDependency( dependant:Object, dependency:Object ):void
		{
			if ( dependant == dependency )
			{
				throw( new Error( "Dependant and dependency are the same object" ) );
			}
			
			var newDependencyNode:DependencyNode;
			var dependantNode:DependencyNode = dependencyNodesTable[ dependant ];
			if ( !dependantNode )
			{
				newDependencyNode = new DependencyNode( dependant );
				dependantNode = dependencyNodesTable[ dependant ] = newDependencyNode;
				_dependencyNodes.addItem( newDependencyNode );
			}
			
			var dependencyNode:DependencyNode = dependencyNodesTable[ dependency ];
			if ( !dependencyNode )
			{
				newDependencyNode = new DependencyNode( dependency );
				dependencyNode = dependencyNodesTable[ dependency ] = newDependencyNode;
				_dependencyNodes.addItem( newDependencyNode );
			}
			
			
			if ( hasDependant( dependantNode, dependency ) )
			{
				throw( new Error( "Adding dependency would create a circular dependency" ) );
				return;
			}
			
			if ( dependantNode.dependencies.indexOf( dependencyNode ) == -1 )
			{
				dependantNode.dependencies.push( dependencyNode );
			}
			
			if ( dependencyNode.dependants.indexOf( dependantNode ) == -1 )
			{
				dependencyNode.dependants.push( dependantNode );
			}
		}
		
		public function removeDependency( dependant:Object, dependency:Object ):void
		{
			if ( dependant == dependency )
			{
				throw( new Error( "Dependant and dependency are the same object" ) );
			}
			var dependantNode:DependencyNode = dependencyNodesTable[ dependant ];
			if ( !dependantNode )
			{
				return;
			}
			
			var dependencyNode:DependencyNode = dependencyNodesTable[ dependency ];
			if ( !dependencyNode )
			{
				return;
			}
			
			var index:int = dependantNode.dependencies.indexOf( dependencyNode );
			if ( index != -1 )
			{
				dependantNode.dependencies.splice( index, 1 );
			}
			
			index = dependencyNode.dependants.indexOf( dependantNode );
			if ( index != -1 )
			{
				dependencyNode.dependants.splice( index, 1 );
			}
			
			var temp:DependencyNode;
			if ( dependantNode.dependants.length == 0 && dependantNode.dependencies.length == 0 )
			{
				temp = dependencyNodesTable[ dependantNode.object ];
				if ( _dependencyNodes.contains( temp ) )
				{	
					_dependencyNodes.removeItem( temp );
				}
				delete dependencyNodesTable[ dependantNode.object ];
			}
			
			if ( dependencyNode.dependants.length == 0 && dependencyNode.dependencies.length == 0 )
			{
				temp = dependencyNodesTable[ dependencyNode.object ];
				if ( _dependencyNodes.contains( temp ) )
				{	
					_dependencyNodes.removeItem( temp );
				}
				delete dependencyNodesTable[ dependencyNode.object ];
			}
		}
		
		public function getDependencyNode( object:Object ):DependencyNode
		{
			return dependencyNodesTable[ object ];
		}
		
		public function getDependants( dependency:Object ):Array
		{
			var node:DependencyNode = dependencyNodesTable[ dependency ];
			var returnArray:Array = [];
			if ( !node ) return returnArray;
			
			for each ( var dependantNode:DependencyNode in node.dependants )
			{
				returnArray.push( dependantNode.object );
			}
			return returnArray;
		}
		
		public function getImmediateDependencies( dependant:Object ):Array
		{
			var node:DependencyNode = dependencyNodesTable[ dependant ];
			var returnArray:Array = [];
			if ( !node ) return returnArray;
			
			for each ( var dependencyNode:DependencyNode in node.dependencies )
			{
				returnArray.push( dependencyNode.object );
			}
			return returnArray;
		}
		
		public function getAllDependencies( dependant:Object ):Array
		{
			var returnArray:Array = [];
			_getAllDependencies( dependant, returnArray );
			return returnArray;
		}
		
		protected function _getAllDependencies( dependant:Object, returnVector:Array ):void
		{
			var node:DependencyNode = dependencyNodesTable[ dependant ];
			if ( !node ) return;
			
			for each ( var dependencyNode:DependencyNode in node.dependencies )
			{
				if ( returnVector.indexOf( dependencyNode.object ) == -1 )
				{
					returnVector.push( dependencyNode.object );
					_getAllDependencies( dependencyNode.object, returnVector );
				}
			}
		}
		
		public function getAllDependents( dependency:Object ):Array
		{
			var returnArray:Array = [];
			_getAllDependents( dependency, returnArray );
			return returnArray;
		}
		
		protected function _getAllDependents( dependency:Object, returnVector:Array ):void
		{
			var node:DependencyNode = dependencyNodesTable[ dependency ];
			if ( !node ) return;
			
			for each ( var dependencyNode:DependencyNode in node.dependants )
			{
				if ( returnVector.indexOf( dependencyNode.object ) == -1 )
				{
					returnVector.push( dependencyNode.object );
					_getAllDependencies( dependencyNode.object, returnVector );
				}
			}
		}
		
		public function getAllDependentsAndDependencies( object:Object ):Array
		{
			var returnArray:Array = [];
			_getAllDependentsAndDependencies( object, returnArray );
			return returnArray;
		}
		
		protected function _getAllDependentsAndDependencies( object:Object, array:Array ):void
		{
			var node:DependencyNode = dependencyNodesTable[ object ];
			if ( !node ) return;
			
			var childNode:DependencyNode
			for each ( childNode in node.dependants )
			{
				if ( array.indexOf( childNode.object ) == -1 )
				{
					array.push( childNode.object );
					_getAllDependentsAndDependencies( childNode.object, array );
				}
			}
			for each ( childNode in node.dependencies )
			{
				if ( array.indexOf( childNode.object ) == -1 )
				{
					array.push( childNode.object );
					_getAllDependentsAndDependencies( childNode.object, array );
				}
			}
		}
		
		
		protected function hasDependant( node:DependencyNode, obj:Object ):Boolean
		{
			for each ( var dependantNode:DependencyNode in node.dependants )
			{
				if ( dependantNode.object == obj ) return true
				
				var value:Boolean = hasDependant( dependantNode, obj )
				if ( value ) return true;
			}
			return false;
		}
	}
}
