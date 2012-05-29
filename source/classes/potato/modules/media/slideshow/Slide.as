package potato.modules.media.slideshow
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import potato.modules.media.MediaEvent;
	import potato.modules.media.MediaState;
	import potato.modules.media.interfaces.IMedia;
	import potato.modules.media.interfaces.ITimeline;

	/**
	 * @private
	 */
	public class Slide extends EventDispatcher implements IMedia, ITimeline
	{
		public var index:int;
		public var id:String;
		public var showMethod:Function;
		public var hideMethod:Function;
		
		protected var _time:Number;
		protected var _timeTotal:Number;
		protected var _display:DisplayObject;
		protected var _state:String;
		protected var listenerTarget:Sprite;
		protected var startTime:Number;
		
		public function Slide()
		{
			_time = 0;
			_timeTotal = 3000;
			listenerTarget = new Sprite();	
		}
		
		public function show():void
		{
			if (showMethod != null)
				showMethod(this);
			else
				display.visible = true;
		}
		
		public function hide():void
		{
			if (hideMethod != null)
				hideMethod(this);
			else
				display.visible = false;
		}
		
		public function set display(value:DisplayObject):void
		{
			_display = value;
		}
		
		public function get display():DisplayObject
		{
			return _display;
		}

		public function play():void
		{
			if (_state == MediaState.PLAYING) return;
			_state = MediaState.PLAYING;
			start();
		}
		
		public function pause():void
		{
			if (_state != MediaState.PLAYING) return;
			_state = MediaState.PAUSED;
		}
		
		public function stop():void
		{
			if (_state != MediaState.PLAYING) return;
			_state = MediaState.STOPPED;
			finish();
			_time = 0;
		}
		
		public function dispose():void
		{
			finish();
			listenerTarget = null;
			_display = null;
		}
		
		public function set timeRatio(value:Number):void
		{
			time = _timeTotal * value;
		}
		
		public function get timeRatio():Number
		{
			return _time/_timeTotal;
		}
		
		public function set time(value:Number):void
		{
			finish();
			_time = value;
			start();
		}
		
		public function get time():Number
		{
			return _time;
		}
		
		public function set timeTotal(value:Number):void
		{
			_timeTotal = value;
		}
		
		public function get timeTotal():Number
		{
			return _timeTotal;
		}
		
		protected function start():void
		{
			startTime = getTimer() + _time;
			if (listenerTarget.hasEventListener(Event.ENTER_FRAME)) return;
			if (_time == 0) dispatchEvent(new Event(MediaEvent.PLAYBACK_START));
			listenerTarget.addEventListener(Event.ENTER_FRAME, runProgress);
		}
		
		protected function finish():void
		{
			listenerTarget.removeEventListener(Event.ENTER_FRAME, runProgress);
		}
		
		protected function runProgress(...e):void
		{
			if (_state != MediaState.PAUSED) {
				_time = getTimer() - startTime;
				dispatchEvent(new Event(MediaEvent.PLAYBACK_PROGRESS));
			}
			
			if (_time >= _timeTotal) {
				finish();
				dispatchEvent(new Event(MediaEvent.PLAYBACK_COMPLETE));
			}  
		} 
	}
}