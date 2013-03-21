// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package core.app.operations
{
	import core.app.core.operations.IUndoableOperation;
	
	public class AddToVectorOperation implements IUndoableOperation
	{
		private var item			:Object;
		private var vector			:Object; //Vector
		private var index			:int;
		private var host			:Object;
		private var propertyName	:String;
		
		public function AddToVectorOperation( item:Object, vector:Object, index:int = -1, host:Object = null, propertyName:String = null )
		{
			this.item = item;
			this.vector = vector;
			this.index = index;
			this.host = host;
			this.propertyName = propertyName;
		}
		
		public function execute():void
		{
			if ( index == -1 )
			{
				vector.push(item);
			}
			else
			{
				vector.splice(index,0,item);
			}
			
			if ( host && propertyName )
			{
				host[propertyName] = vector;
			}
		}
		
		public function undo():void
		{
			var index:int = vector.indexOf(item);
			vector.splice(index,1);
			if ( host && propertyName )
			{
				host[propertyName] = vector;
			}
		}
		
		public function get label():String
		{
			return "Add item to vector";
		}
	}
}