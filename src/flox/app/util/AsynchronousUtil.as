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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class AsynchronousUtil
	{
		private static var dispatchLaterList	:Array;
		private static var callLaterList		:Array;
		private static var dispatchLaterTimer	:Timer;
		
		/**
		 * Utility function for dispatching an event on the next (10ms later) code cycle. This is useful for delegate models where
		 * a function needs to dispatch an event on a delegate before it has returned it to the caller. In this situation
		 * the caller hansn't yet had chance to listen in to any events. Using this utility the callee can delay dispatching until
		 * the caller has added it's listeners.
		 * @param eventDispatcher
		 * @param event
		 * 
		 */		
		public static function dispatchLater( eventDispatcher:EventDispatcher, event:Event ):void
		{
			if ( !dispatchLaterList )
			{
				dispatchLaterList = [];
			}
			dispatchLaterList.push( { eventDispatcher:eventDispatcher, event:event } );
			
			if ( !dispatchLaterTimer )
			{
				dispatchLaterTimer = new Timer(10,1);
				dispatchLaterTimer.addEventListener(TimerEvent.TIMER_COMPLETE, dispatchLaterHandler);
				dispatchLaterTimer.start();
			}
		}
		
		private static function dispatchLaterHandler( event:TimerEvent ):void
		{
			dispatchLaterTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, dispatchLaterHandler);
			dispatchLaterTimer = null;
			
			if ( !dispatchLaterList ) dispatchLaterList = [];
			var localList:Array = dispatchLaterList.slice();
			dispatchLaterList = [];
			for ( var i:int = 0; i < localList.length; i++ )
			{
				var obj:Object = localList[i];
				obj.eventDispatcher.dispatchEvent( obj.event );
			}
			
			if ( !callLaterList ) callLaterList = [];
			localList = callLaterList.slice();
			callLaterList = [];
			for ( var j:int = 0; j < localList.length; j++ )
			{
				obj = localList[j];
				var method:Function=  obj.method;
				method.apply(null, obj.params);
			}
		}
		
		public static function callLater( method:Function, params:Array = null ):void
		{
			if ( !params ) params = [];
			if ( !callLaterList )
			{
				callLaterList = [];
			}
			callLaterList.push( { method:method, params:params } );
			
			if ( !dispatchLaterTimer )
			{
				dispatchLaterTimer = new Timer(10,1);
				dispatchLaterTimer.addEventListener(TimerEvent.TIMER_COMPLETE, dispatchLaterHandler);
				dispatchLaterTimer.start();
			}
		}
	}
}