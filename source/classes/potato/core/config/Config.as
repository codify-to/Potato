package potato.core.config
{

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import br.com.stimuli.string.printf;

  /**
   *  Dispatched after the Object initialization has been completed (automatically after calling <code>init()</code>).
   *
   *  @eventType flash.events.Event.INIT
   */
  [Event(name="init", type="flash.events.Event")]

	/**
	 * Base configuration Object implementation.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Lucas Dupin
	 * @since  26.07.2010
	 */
	public class Config extends EventDispatcher
	{
		/** @private Source object */
		internal var _config:Object;
		
		/** @private */
		protected var _interpolationValues:Object;
		
		public function Config(source:Object=null):void
		{
			_config = source || {};
		}
		
		/**
		 * Initializes the configuration object. After the object has finished initializing, an <code>Event.INIT</code> is dispatched.
		 */
		public function init():void
		{
			//Notify we're done
			dispatchEvent(new Event(Event.INIT));
		}
	
		/**
		 * @inheritDoc
		 */
		public function getProperty(...props):*
		{
			//Start from the config
			var lastVal:Object = _config;

			//Going deeper
			for each (var prop:Object in props)
			{
				lastVal = getPropertyValue(lastVal[prop]);
			}

			return lastVal;
		}
    
		/**
		 * @inheritDoc
		 */
		public function hasProperty(...props):Boolean
		{
			//Start from the config
			var lastVal:Object = _config;

			//Going deeper
			for each (var prop:Object in props)
			{
				lastVal = getPropertyValue(lastVal[prop]);
				if(!lastVal) return false;
			}

			return true;
		}
		
		/**
		* Do interpolation if needed
		 * @param target Object 
		 * @return Object 
		 */
		public function getPropertyValue(target:Object):Object
		{
			var r:Object = target;

			if(r is String && _interpolationValues != null){
				r = printf(r+"", _interpolationValues);
			}

			return r;
		}
		
		/**
		 * Inserts or modifies a property.
		 */
		public function setProperty(name:Object, value:Object):void
		{
			_config[name] = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get keys():Array
		{
			var k:Array=[];
			if (_config is Array)
			{
				for (var i:int = 0; i < _config.length; i++)
					k.push(i);
			} else {
				for (var s:String in _config)
					k.push(s);
			}
			
			return k;
		}
		
		/**
		 * @param key Object 
		 * Generates a new Config based in one item
		 */
		public function configForKey(key:Object):Config
		{
			var o:Config = new Config(_config[key]);
			o.interpolationValues = _interpolationValues;
			o.init();
			return o;
		}
		
		/**
		 * Object containing the interpolation values for properties' configuration.
		 */
		public function set interpolationValues(value:Object):void
		{
			_interpolationValues = value;
		}
	}

}
