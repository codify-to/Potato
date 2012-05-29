package potato.modules.media.soundlib
{
	import flash.utils.Dictionary;
	
	import potato.modules.media.interfaces.IAudio;
	import potato.modules.media.interfaces.IMedia;

	/**
	 * SoundClipGroup join togheter any number of SoundClip instances, to massive manipulation.
	 * 
	 * @see potato.modules.media.soundlib.SoundClip 
	 */
	public class SoundClipGroup implements IMedia, IAudio
	{  
		/**
		 * The name of the group.
		 */
		public var id:String;
		
		/**
		 * Holds all the soundClips added.
		 */
		protected var _list:Dictionary;
		
		/**
		 * Holds the current volume.
		 */
		protected var _volume:Number;
		
		/**
		 * Construtor.
		 * 
		 * @param id The name of the group.
		 */
		public function SoundClipGroup(id:String = "")
		{
			this.id = id;
			_list = new Dictionary(true);
			_volume = 1;
		}
		
		/**
		 * Play all the owned soundClips at same time.
		 */
		public function play():void
		{
			for each (var soundClip:SoundClip in _list) 
				if (soundClip) soundClip.play();
		}
		
		/**
		 * Pause all the owned soundClips.
		 */
		public function pause():void
		{
			for each (var soundClip:SoundClip in _list) 
				if (soundClip) soundClip.pause();
		}
		
		/**
		 * Stop all the owned soundClips.
		 */
		public function stop():void
		{
			for each (var soundClip:SoundClip in _list) 
				if (soundClip) soundClip.stop();
		}
		
		/**
		 * Dispose all the owned soundClips, and clear memory.
		 */
		public function dispose():void
		{
			for each (var soundClip:SoundClip in _list) {
				soundClip.dispose();
				soundClip = null;
			}
			_list = null;
		}
		
		public function set volume(value:Number):void
		{
			_volume = value;
			for each (var soundClip:SoundClip in _list) 
				if (soundClip) soundClip.volumeScale = _volume;
		}
		/**
		 * Sets the volume for all included soundClips.
		 * 
		 * <p>This porperty modify only the volumeScale of the SoundClip instances, keeping all volumes with the same proportional rate.</p>
		 * 
		 * @see potato.modules.media.soundlib.SoundClip
		 */
		public function get volume():Number
		{
			return _volume;
		}
		
		/**
		 * Add a SoundClip instance.
		 * 
		 * @param soundClip the instance of SoundClip that will be added.
		 */
		public function add(soundClip:SoundClip):void
		{
			_list[soundClip.id] = soundClip;
			volume = _volume;
		}
		
		/**
		 * Remove a SoundClip instance by id, without disposing.
		 * 
		 * @param The instance of SoundClip desired to remove.
		 */
		public function remove(id:String):void
		{
			_list[id] = null;
			delete _list[id];
		}
		
		/**
		 * Gets an instance of SoundClip by id.
		 * 
		 * @param id The id of the soundClip.
		 */
		public function pick(id:String):SoundClip
		{
			return _list[id];
		}
		
		/**
		 * The list of all SoundClip instances added.
		 */
		public function get list():Dictionary
		{
			return _list;
		}
		
	}
}