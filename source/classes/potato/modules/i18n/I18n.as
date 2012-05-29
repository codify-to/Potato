package potato.modules.i18n
{
	import flash.events.EventDispatcher;
	import potato.core.config.Config;
	import flash.events.Event;
	import flash.text.TextField;
	
	/**
	 * Default i18n implementation.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Lucas Dupin, Fernando França
	 * @since  26.07.2010
	 */
	public class I18n extends EventDispatcher {
		
		/** @private */
		private var _configs:Vector.<Config> = new Vector.<Config>();
		
		/** @private */
		private static var _instance:I18n;

    /**
     * Class used to parse configurations.
     **/
    public static var parser:Class;

		/**
		 * The I18n instance (Singleton).
		 */
		public static function get instance():I18n
		{
			if(!_instance)
				_instance = new I18n(new SingletonEnforcer());
			
			return _instance;
		}
		
		/**
		 * Injects (merges) new definitions into the current configuration.
		 * @param config Config config with localization text.
		 */
		public static function inject(config:Config):void
		{
			instance.inject(config);
		}
		
		/**
		 * Clears all config references.
		 */
		public static function flush():void
		{
		  instance.flush();
		}
		
		/**
		 * Constructor (Singleton, access is only allowed through the I18n.instance).
		 * @constructor
		 * @private
		 */
		public function I18n(singleton:SingletonEnforcer):void {}
		
		/**
		 * @private
		 */
		public function inject(config:Config):void
		{
			config.addEventListener(Event.INIT, onConfigInit);
			config.init();
		}
		
    /**
     * @private
     */
		protected function onConfigInit(e:Event):void
		{
			var config:Config = e.target as Config;
			config.removeEventListener(Event.INIT, onConfigInit);
			_configs.push(config);
			dispatchEvent(new Event(Event.COMPLETE));
		}
				
		/**
		 * @private
		 */
		public function flush():void
		{
			_configs.length = 0;
		}
		
		/**
		 * Retrieves the desired localized String.
		 * 
		 * @param id The ID of the String to be localized.
		 * @return String The localized String.
		 */
		public function textFor(id:String):String
		{
			//Revese to enable override
			for each (var config:Config in _configs.reverse())
			{
				if (config.hasProperty(id))
				{
					return config.getProperty(id);
				}
				
			}
			return "NOT FOUND: '" + id + "'";
		}
		
		/**
		 * A proxy for acessing config properties.
		 * This makes our life much easier.
		 */
		public function get proxy():ConfigProxy
		{
			return new ConfigProxy(_configs);
		}
	
	}

}


import flash.utils.Proxy;
import flash.utils.flash_proxy;
import potato.core.config.Config;
use namespace flash_proxy;

internal class ConfigProxy extends Proxy
{
	private var _configs:Vector.<Config>;
	
	public function ConfigProxy(configs:Vector.<Config>)
	{
		_configs = configs;
	}
	
	override flash_proxy function getProperty(name:*):*
	{
		for each (var config:Config in _configs.reverse())
			if (config.hasProperty(name))
				return config.getProperty(name);
				
		return undefined
	}
	
	override flash_proxy function hasProperty(name:*):Boolean
	{
		for each (var config:Config in _configs)
			if (config.hasProperty(name))
				return true

		return false;
	}
}

/**
 * Enforces the Singleton design pattern.
 */
internal class SingletonEnforcer{}
