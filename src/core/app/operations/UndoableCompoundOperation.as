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
	
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.core.operations.IUndoableOperation;
	import core.app.events.OperationProgressEvent;
	
	/**
	 * This Operation allows multiple IUndoableOperations to be treated as one. This operation will 'execute()' its
	 * children Operations in order - and calculates the overall progress based upon how many operations
	 * have completed.
	 * 
	 * It is also capable of providing the same behaviour in reverse, when undo() is called.
	 * 
	 * As a UndoableCompoundOperation is itself an Operation, you could have UndoableCompoundOperation within UndoableCompoundOperation.
	 * @author Jonathan
	 * 
	 */	
	public class UndoableCompoundOperation extends EventDispatcher implements IAsynchronousOperation, IUndoableOperation
	{
		public var operations				:Array;
		protected var currentOperation		:IUndoableOperation;
		protected var _description			:String = "Compound Operation";
		protected var direction				:int = 1;
		
		public function UndoableCompoundOperation()
		{
			operations = [];
		}
		
		protected function get currentIndex():int { return operations.indexOf( currentOperation ); }
		
		public function addOperation( operation:IUndoableOperation ):void
		{
			if ( operations.indexOf( operation ) != -1 ) return;
			operations.push( operation )
		}

		public function execute():void
		{
			direction = 1;
			update()
		}
		
		public function undo():void
		{
			direction = -1;
			update();
		}
		
		protected function update():void
		{
			if ( direction == 1 )
			{
				if ( currentIndex == operations.length-1 || operations.length == 0 )
				{
					dispatchEvent( new Event( Event.COMPLETE ) );
					return;
				}
				
				currentOperation = operations[currentIndex+1];
				if ( currentOperation is IAsynchronousOperation )
				{
					IAsynchronousOperation( currentOperation ).addEventListener( Event.COMPLETE, operationCompleteHandler );
					IAsynchronousOperation( currentOperation ).addEventListener( ErrorEvent.ERROR, operationErrorHandler );
					IAsynchronousOperation( currentOperation ).addEventListener( OperationProgressEvent.PROGRESS, operationProgressHandler );
					//trace("Undoable Compound Operation. Executing child operation : " + currentOperation.label);
					currentOperation.execute();
				}
				else
				{
					//trace("Undoable Compound Operation. Executing child operation : " + currentOperation.label);
					currentOperation.execute();
					update()
				}
			}
			else
			{
				if ( currentIndex == -1 )
				{
					dispatchEvent( new Event( Event.COMPLETE ) );
					return;
				}
				
				if ( currentOperation is IAsynchronousOperation )
				{
					var asynchronousOperation:IAsynchronousOperation = IAsynchronousOperation( currentOperation );
					asynchronousOperation.addEventListener( Event.COMPLETE, operationCompleteHandler );
					currentOperation = currentIndex == 0 ? null : operations[currentIndex-1];
					//trace("Undoable Compound Operation. Undoing child operation : " + asynchronousOperation.label);
					IUndoableOperation( asynchronousOperation ).undo();
				}
				else
				{
					//trace("Undoable Compound Operation. Undoing child operation : " + currentOperation.label);
					currentOperation.undo();
					currentOperation = currentIndex == 0 ? null : operations[currentIndex-1];
					update()
				}
			}
		}
		
		private function operationErrorHandler( event:ErrorEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function operationProgressHandler( event:OperationProgressEvent ):void
		{
			var progressPerOperation:Number = 1 / operations.length;
			var index:int = operations.indexOf(event.target);
			var progress:Number = (index * progressPerOperation) + (event.progress*progressPerOperation);
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, progress ) );
		}
		
		protected function operationCompleteHandler( event:Event ):void
		{
			var operation:IAsynchronousOperation = IAsynchronousOperation( event.target );
			operation.removeEventListener( Event.COMPLETE, operationCompleteHandler );
			operation.removeEventListener( ErrorEvent.ERROR, operationErrorHandler );
			operation.removeEventListener( OperationProgressEvent.PROGRESS, operationProgressHandler );
			//trace("Undoable Compound Operation. Child operation complete : " + operation.label);
			update();
		}
		
		public function set label(value:String):void { _description = value }
		public function get label():String { return _description }
	}
}