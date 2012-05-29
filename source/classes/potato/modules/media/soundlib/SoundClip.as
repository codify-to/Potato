package potato.modules.media.soundlib
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import potato.modules.media.MediaState;
	import potato.modules.media.interfaces.IAudio;
	import potato.modules.media.interfaces.IMedia;
	
	/**
	 * SoundClip is a composition of Sound with some important features for a simple playback.
	 * 
	 * <p>This class was made for massive use, so it provides only the primordial controls of sound, 
	 * and don't care about progress events. Can be used alone for any sound ready to play, or with custom SoundGroups.
	 * </p>
	 */
	public class SoundClip extends EventDispatcher implements IMedia, IAudio
	{
		/**
		 * The Sound instance manipulated.
		 */
		public var sound:Sound;
		
		/**
		 * The name of the instance.
		 */
		public var id:String;
		
		/**
		 * The current SoundChannel instance.
		 */
		public var channel:SoundChannel;
		
		/**
		 * Number of playback repetitions. Values less than 0 makes the sound repeat infinitly.
		 */
		public var loops:int;
		
		/**
		 * Specify if the new channel kills the old channel for each play action..
		 */
		public var singleChannel:Boolean;
		
		/**
		 * The position (in miliseconds) where the sound must start.
		 */
		public var startTime:Number;
		
		/**
		 * Holds the current volume.
		 */
		protected var _volume:Number;
		
		/**
		 * Holds the current volume scale.
		 */
		protected var _volumeScale:Number;
		
		/**
		 * Holds the current SoundTransform.
		 */
		protected var _transform:SoundTransform;
		
		/**
		 * Holds the current state.
		 * 
		 * @see potato.modules.media.MediaState
		 */
		protected var _state:String;
		
		private var listeningComplete:Boolean;
		private var listeningSoundComplete:Boolean;
		
		/**
		 * Construtor.
		 * 
		 * @param id The is of the instance.
		 * @param sound The sound instance that SoundClip will control.
		 */
		public function SoundClip(id:String = "", sound:Sound = null)                                                        
		{
			this.sound = sound;
			this.id = id;
			loops = 0;
			singleChannel = true;
			startTime = 0;
			
			_volume = 1;
			_volumeScale = 1;
			_state = MediaState.STOPPED;
			
			listeningComplete = listeningSoundComplete = false;
		}
		
		/**
		 * Simply starts the sound playback, without any parameters.
		 * 
		 * <p>If the sound must start with some pre-settings, use <code>play2</code>.</p>
		 * 
		 * @see play2
		 */
		public function play():void
		{
			if (_state == MediaState.PLAYING && singleChannel) stop();
			channel = sound.play(startTime);
			channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
			volume = _volume;
			_state = MediaState.PLAYING;
		}
		
		/**
		 * Pauses the sound playback.
		 */
		public function pause():void
		{
			if (_state != MediaState.PLAYING) return;
			_state = MediaState.PAUSED;
			startTime = channel.position;
			channel.stop();
		}
		
		/**
		 * Stops the sound playback.
		 */
		public function stop():void
		{
			if (_state == MediaState.STOPPED) return;
			_state = MediaState.STOPPED;
			startTime = 0;
			channel.stop();
		}
		
		/**
		 * Destroy the instance and clear memory.
		 */
		public function dispose():void
		{
			channel = null;
			sound = null;
			_transform = null;
		}
		
		/**
		 * Starts the sound playback with some settings like volume, loops, etc.
		 * 
		 * <p>Useful for fast sound calls with volume an loop settings.</p>
		 * 
		 * @param volume The volume of playback. If the value is less than 0, the current volume setted don't change.
		 * @default -1
		 * @param loops The number of repetitions of the sound. If the value is less than 0, the sound will loop infinitly.
		 * @default 0
		 * @param startTime The point where the playback will start.
		 * @default 0
		 * @param pan The panning of the playback.
		 * @default 0
		 */
		public function play2(volume:Number= -1, loops:int = 0, startTime:Number = 0, pan:Number = 0):void
		{
			this.volume = volume >= 0 ? volume : _volume;
			this.startTime = startTime;
			this.loops = loops;
			play();
			this.pan = pan;
		}
		
		public function set volume(value:Number):void
		{
			_volume = value;
			if (channel == null) return;
			_transform = channel.soundTransform;
			_transform.volume = _volume*_volumeScale;
			channel.soundTransform = _transform;		
		}
		/**
		 * The volume of sound, from 0 to 1, relative to volumeScale.
		 * 
		 * @default 1
		 * @see volumeScale
		 */
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set pan(value:Number):void
		{
			if (channel == null) return;
			_transform = channel.soundTransform;
			_transform.pan = value;
			channel.soundTransform = _transform;
		}
		/**
		 * The panning of channel, from -1 (left only) to 1 (right only).
		 * 
		 * @default 0
		 */
		public function get pan():Number
		{
			return channel.soundTransform.pan;
		}
		
		public function set volumeScale(value:Number):void
		{
			_volumeScale = value;
			volume = _volume;	
		}
		/**
		 * The scale of volume relativizes the volume, controlling this power.
		 * 
		 * <p>The volume of a SoundClid instance is a result of the volume*volumeScale. It means if the volume is 1 and
		 * the volumeScale is .7, the "real volume" will be .7. It is useful to control volume of many instances without their looses
		 * the relativity among them, like a SoundGroup do.</p>
		 * 
		 * @default 1
		 * @see volume
		 */
		public function get volumeScale():Number
		{
			return _volumeScale;
		}
		
		/**
		 * Tell if the instance is playing or not, by the current state.
		 * 
		 * @see state
		 */
		public function get playing():Boolean
		{
			return _state == MediaState.PLAYING;
		}
		
		/**
		 * The current state of the SoundClip instance.
		 * 
		 * @see potato.modules.media.MediaState
		 */
		public function get state():String
		{
			return _state;
		}
		
		/**
		 * @private
		 */
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			if (type == Event.COMPLETE) listeningComplete = true;
			if (type == Event.SOUND_COMPLETE) listeningSoundComplete = true;
		}
		
		/**
		 * @private
		 */
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			super.removeEventListener(type, listener, useCapture);
			if (!hasEventListener(Event.COMPLETE)) listeningComplete = false;
			if (!hasEventListener(Event.SOUND_COMPLETE)) listeningSoundComplete = false;
		}
		
		/**
		 * @private
		 */
		private function soundCompleteHandler(e:Event):void
		{
			if (loops == 0) {
				_state = MediaState.STOPPED;
				startTime = 0;
				if (listeningSoundComplete) dispatchEvent(new Event(Event.SOUND_COMPLETE));
				return;
			}
			if (loops > 0) {
				loops--;
				if (listeningComplete) dispatchEvent(new Event(Event.COMPLETE));
			}
			play();
		}
	}
}
