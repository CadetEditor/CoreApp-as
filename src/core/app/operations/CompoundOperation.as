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
	import core.events.PropertyChangeEvent;
	
	import core.app.core.operations.IAsynchronousOperation;
	import core.app.core.operations.IOperation;
	import core.app.events.OperationProgressEvent;
	import core.app.util.AsynchronousUtil;
	
	[Event(type="core.app.events.OperationProgressEvent", name="progress")]
	[Event(type="flash.events.Event", name="complete")]
	[Event(type="flash.events.ErrorEvent", name="error")]
	
	/**
	 * This Operation allows multiple Operations to be treated as one. This operation will 'execute()' its
	 * children Operations in order - and calculates the overall progress based upon how many operations
	 * have completed.
	 * 
	 * As a CompoundOperation is itself an Operation, you could have CompoundOperations within CompoundOperations.
	 * @author Jonathan
	 * 
	 */	
	public class CompoundOperation extends EventDispatcher implements IAsynchronousOperation
	{
		public var operations				:Array;
		protected var _label				:String = "Compound Operation";
		protected var _customLabelSet		:Boolean = false;
		protected var currentOperation		:IOperation;
		
		public function CompoundOperation()
		{
			operations = [];
		}
		
		protected function get currentIndex():int { return operations.indexOf( currentOperation ); }
		
		public function addOperation( operation:IOperation ):void
		{
			operations.push( operation )
		}
		
		public function execute():void
		{
			if ( operations.length == 0 )
			{
				AsynchronousUtil.dispatchLater( this, new Event( Event.COMPLETE ) );
				return;
			}
			update()
		}
		
		protected function update():void
		{
			if ( currentIndex == (operations.length-1) || operations.length == 0 )
			{
				dispatchEvent( new Event( Event.COMPLETE ) );
				return;
			}
			
			currentOperation = operations[currentIndex+1];
			if ( currentOperation is IAsynchronousOperation )
			{
				IAsynchronousOperation( currentOperation ).addEventListener( Event.COMPLETE, operationCompleteHandler );
				IAsynchronousOperation( currentOperation ).addEventListener( OperationProgressEvent.PROGRESS, operationProgressHandler );
				IAsynchronousOperation( currentOperation ).addEventListener( ErrorEvent.ERROR, operationErrorHandler );
				updateLabel();
				//trace("Compound Operation. Executing child operation : " + currentOperation.label);
				currentOperation.execute();
			}
			else
			{
				//trace("Compound Operation. Executing child operation : " + currentOperation.label);
				currentOperation.execute();
				update();
			}
		}
		
		protected function operationErrorHandler( event:ErrorEvent ):void
		{
			dispatchEvent( event );
		}
		
		protected function operationProgressHandler( event:OperationProgressEvent ):void
		{
			updateLabel();
			
			var progressPerOperation:Number = 1 / operations.length;
			var index:int = operations.indexOf(event.target);
			var progress:Number = (index * progressPerOperation) + (event.progress*progressPerOperation);
			dispatchEvent( new OperationProgressEvent( OperationProgressEvent.PROGRESS, progress ) );
		}
		
		protected function operationCompleteHandler( event:Event ):void
		{
			var operation:IAsynchronousOperation = IAsynchronousOperation( event.target );
			operation.removeEventListener( Event.COMPLETE, operationCompleteHandler );
			operation.removeEventListener( OperationProgressEvent.PROGRESS, operationProgressHandler );
			operation.removeEventListener( ErrorEvent.ERROR, operationErrorHandler );
			//trace("Undoable Compound Operation. Child operation complete : " + operation.label);
			update();
		}
		
		protected function updateLabel():void
		{
			if ( _customLabelSet ) return;
			var oldValue:String = _label;
			if ( oldValue != currentOperation.label )
			{
				_label = currentOperation.label;
				dispatchEvent( new PropertyChangeEvent( "propertyChange_label", null, _label ) );
			}
		}
		
		public function set label(value:String):void 
		{ 
			_label = value;
			_customLabelSet = true;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_label", null, _label ) );
		}
		public function get label():String { return _label }
	}
}