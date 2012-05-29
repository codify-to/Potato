package potato.modules.media.slideshow
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import potato.modules.media.MediaEvent;
	import potato.modules.media.interfaces.IMedia;
	import potato.modules.media.interfaces.ITimeline;

	/**
	 * @private
	 */
	public class SlideShow extends EventDispatcher implements IMedia, ITimeline
	{
		public var loop:Boolean;
		public var auto:Boolean;
		
		protected var _slides:Array;
		protected var _currentIndex:int;
		
		public function SlideShow()
		{
			super();
			_slides = [];
			loop = false;
			auto = true;
			_currentIndex = 0;
		}
		
		public function addSlide(display:DisplayObject, exbithionTime:int = 3000, showMethod:Function = null, hideMethod:Function = null):void
		{
			var slide:Slide = new Slide();
			slide.display = display;
			slide.timeTotal = exbithionTime;
			slide.index = _slides.length;
			_slides.push(slide);
			
			slide.addEventListener(MediaEvent.PLAYBACK_START, slideStartHandler);
			slide.addEventListener(MediaEvent.PLAYBACK_PROGRESS, slideProgressHandler);
			slide.addEventListener(MediaEvent.PLAYBACK_COMPLETE, slideCompleteHandler);
		}
		
		public function play():void
		{
			currentIndex = _currentIndex;
		}
		
		public function pause():void
		{
			currentSlide.pause();
		}
		
		public function stop():void
		{
			currentSlide.stop();
			currentSlide.hide();
			_currentIndex = 0;
			currentSlide.show();
		}
		
		public function dispose():void
		{
		}
		
		public function set time(value:Number):void
		{
			currentSlide.time = value;
		}
		
		public function get time():Number
		{
			return currentSlide.time;
		}
		
		public function set timeTotal(value:Number):void
		{
			currentSlide.timeTotal = value;
		}
		
		public function get timeTotal():Number
		{
			return currentSlide.timeTotal;
		}
		
		public function set timeRatio(value:Number):void
		{
			currentSlide.timeRatio = value;
		}
		
		public function get timeRatio():Number
		{
			return currentSlide.timeRatio;
		}
		
		public function next():void
		{
			currentIndex++;
		}
		
		public function prev():void
		{
			currentIndex--;
		}
		
		public function set currentIndex(value:int):void
		{
			if (value < 0) value = _slides.length - 1;
			if (value > _slides.length - 1) value = 0;
			if (currentSlide) currentSlide.hide();
			_currentIndex = value;
			currentSlide.show();
			currentSlide.play();
		}
		
		public function get currentIndex():int
		{
			return _currentIndex;
		}
		
		public function get currentSlide():Slide
		{
			return _slides[_currentIndex];
		}
		
		protected function slideStartHandler(e:Event):void
		{
			var slide:Slide = e.currentTarget as Slide;
		}
		
		protected function slideProgressHandler(e:Event):void
		{
			dispatchEvent(new Event(MediaEvent.PLAYBACK_PROGRESS));
		}
		
		protected function slideCompleteHandler(e:Event):void
		{
			var slide:Slide = e.currentTarget as Slide;
			slide.stop();
			if (auto) next();
		}
		
	}
}