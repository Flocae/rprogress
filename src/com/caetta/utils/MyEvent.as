package com.caetta.utils
{
	import flash.events.Event;

	public class MyEvent extends Event
	{
		public static const GOT_RESULT:String = "gotResult";
		
		// this is the object you want to pass through your event.
		public var result:Object;
		
		public function MyEvent(type:String, result:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.result = result;
		}
		// create a clone() to redispatch them.
		public override function clone():Event
		{
			return new MyEvent(type, result, bubbles, cancelable);
		}
	}
}