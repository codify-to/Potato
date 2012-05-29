package potato.modules.media.sound
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import potato.modules.media.MediaEvent;
	import potato.modules.media.MediaState;
	import potato.modules.media.interfaces.IAudio;
	import potato.modules.media.interfaces.IMedia;
	import potato.modules.media.interfaces.ITimeline;

	/**
	 * Dispatched when the playback starts, only if the playback was in time 0
	 * 
	 * @eventType potato.modules.media.MediaEvent.PLAYBACK_START
	*/
	[Event(name="playback_start" , type="flash.events.Event")]
	
	/**
	 * Dispatched when the playback progress, in an enterFrame.
	 *
	 * @eventType potato.modules.media.MediaEvent.PLAYBACK_PROGRESS
	*/
	[Event(name="playback_progress" , type="flash.events.Event")]
	
	/**
	 * Dispatched when the playback finishes.
	 * 
	 * @eventType potato.modules.media.MediaEvent.PLAYBACK_COMPLETE
	*/
	[Event(name="playback_complete" , type="flash.events.Event")]
	
	/**
	 * Dispatched when the sound plays.
	 * 
	 * @eventType potato.modules.media.MediaEvent.PLAY
	*/
	[Event(name="play" , type="flash.events.Event")]
	
	/**
	 * Dispatched when the sound pauses.
	 * 
	 * @eventType potato.modules.media.MediaEvent.PAUSE
	*/
	[Event(name="pause" , type="flash.events.Event")]
	
	/**
	 * Dispatched when the sound stops.
	 * 
	 * @eventType potato.modules.media.MediaEvent.STOP
	*/
	[Event(name="stop" , type="flash.events.Event")]

	/**
	 * SoundPlayer helps the Sound manipulation, providing all the most needed methods and events of a sound don't have. 
	 */
	public class SoundPlayer extends EventDispatcher implements IAudio, IMedia, ITimeline
	{	
		/**
		 * The Sound instance curretly used. 
		 */
		protected var _sound:Sound;
		
		/**
		 * Holds the current volume. 
		 */
		protected var _volume:Number;
		
		/**
		 * Holds the current pan. 
		 */
		protected var _pan:Number;
		
		/**
		 * The SoundTransform instance that will be used by volume and pan. 
		 */
		protected var _transform:SoundTransform;
		
		/**
		 * The current state. 
		 */
		protected var _state:String;
		
		/**
		 * Holds the total duration of the sound. 
		 */
		protected var _timeTotal:Number;
		
		/**
		 * The channel where the sound is running. 
		 */
		protected var channel:SoundChannel;
		
		/**
		 * The last sound position, for play/pause and time operations. 
		 */
		protected var position:Number;
		
		private var listenerReceiver:Sprite;
		private var watchingProgress:Boolean;
		
		/**
		 * Construtor. 
		 */
		public function SoundPlayer()
		{
			_state = MediaState.STOPPED;
			position = 0;
			_volume = 1;
			_pan = 0;
			listenerReceiver = new Sprite();
			watchingProgress = false;
		}

		public function set volume(value:Number):void
		{
			_volume = value;
			if (channel == null) return;
			_transform = channel.soundTransform;
			_transform.volume = _volume;
			channel.soundTransform = _transform;
		}
		/**
		 * The volume of sound (0 to 1). 
		 * 
		 * @default 1
		 */
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set pan(value:Number):void
		{
			_pan = value;
			if (channel == null) return;
			_transform = channel.soundTransform;
			_transform.pan = _pan;
			channel.soundTransform = _transform;
		}
		/**
		 * The panning of sound, from -1 (left only) to 1 (right only). 
		 * 
		 * @default 0
		 */
		public function get pan():Number
		{
			return _pan;
		}
		
		/**
		 * Starts the sound playback at the last position registered.
		 */
		public function play():void
		{
			if (_state == MediaState.PLAYING) return;
			_state = MediaState.PLAYING;
			startPlayback();
			dispatchEvent(new Event(MediaEvent.PLAY));
			if (position == 0) dispatchEvent(new Event(MediaEvent.PLAYBACK_START)); 
			startPlaybackCheck();
		}
		
		/**
		 * Pauses the sound playback, and store the last position for later play at the same pont.
		 */
		public function pause():void
		{
			if (_state != MediaState.PLAYING) return;
			_state = MediaState.PAUSED;
			position = channel.position;
			channel.stop();
			dispatchEvent(new Event(MediaEvent.PAUSE));
			stopPlaybackCheck();
		}
		
		/**
		 * Stops the sound playback, and reset the position to 0.
		 */
		public function stop():void
		{
			if (_state == MediaState.STOPPED) return;
			_state = MediaState.STOPPED;
			position = 0;
			channel.stop();
			dispatchEvent(new Event(MediaEvent.STOP));
			stopPlaybackCheck();
		}
		
		/**
		 * Destroy the instance and clear memory.
		 */
		public function dispose():void
		{
			clearChannel();
			_sound.close();
			_sound = null;
		}
		
		public function set sound(value:Sound):void
		{
			_sound = value;
			if (_sound.id3) if (_sound.id3.TLEN) timeTotal = _sound.id3.TLEN;
		}
		/**
		 * The Sound instance that SoundPlayer controls.
		 */
		public function get sound():Sound
		{
			return _sound;
		}
		
		public function set timeRatio(value:Number):void
		{
			time = timeTotal*value;
		}
		/**
		 * The relative time position of playback (0 to 1).
		 * 
		 * <p>Works rightly only if the timeTotal is well defined.</p>
		 * 
		 * @see timeTotal
		 * @see time
		 */
		public function get timeRatio():Number
		{
			return channel.position/timeTotal;
		}
		
		public function set time(value:Number):void
		{
			startPlayback(value);
			position = channel.position;
			if (_state != MediaState.PLAYING) channel.stop();
		}
		/**
		 * The time of playback.
		 */
		public function get time():Number
		{
			return channel.position
		}
		
		public function set timeTotal(value:Number):void
		{
			_timeTotal = value;
		}	
		/**
		 * The time duration of the sound.
		 * 
		 * <p>The <code>length</code> property of the Sound dont't return the real value until the sound stream finishes.
		 * So, for better results, this value can be setted manually.
		 * </p>
		 */
		public function get timeTotal():Number
		{
			return _timeTotal ? _timeTotal : _sound.length;
		}	
		
		/**
		 * Implicit start the playback with stored volume and pan values, used by <code>play()</code> and <code>time</code> properties.
		 */
		protected function startPlayback(pos:Number = -1):void
		{
			if (_sound == null) return;
			if (pos < 0) pos = position;
			clearChannel();
			channel = _sound.play(pos);
			channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
			volume = _volume;
			pan = _pan;
		}
		
		/**
		 * Clears the current sound channel.
		 */
		protected function clearChannel():void
		{
			if (channel == null) return;
			channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			channel.stop();
			channel = null;
		}
		
		/**
		 * Handles the playback finish.
		 */
		protected function soundCompleteHandler(e:Event):void
		{
			stop();
			dispatchEvent(new Event(MediaEvent.PLAYBACK_COMPLETE));
		}
		
		/**
		 * Starts the playback check, that will dispatch the MediaEvent.PLAYBACK_PROGRESS.
		 */
		protected function startPlaybackCheck():void
		{
			if (watchingProgress) return;
			watchingProgress = true;
			listenerReceiver.addEventListener(Event.ENTER_FRAME, playbackCheck);
		}
		
		/**
		 * Stops the playback check.
		 */
		protected function stopPlaybackCheck():void
		{
			if (!watchingProgress) return;
			watchingProgress = false;
			listenerReceiver.removeEventListener(Event.ENTER_FRAME, playbackCheck);
		}
		
		/**
		 * The playback check, where MediaEvent.PLAYBACK_PROGRESS dispatches occurs.
		 */
		protected function playbackCheck(e:Event):void
		{
			dispatchEvent(new Event(MediaEvent.PLAYBACK_PROGRESS));
		}
	}
}