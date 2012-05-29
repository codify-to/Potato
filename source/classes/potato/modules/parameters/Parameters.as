package potato.modules.parameters
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import potato.core.config.Config;
	import potato.core.config.Config;
	import flash.utils.Dictionary;
	import br.com.stimuli.string.printf;
	import potato.core.IDisposable;
	
	use namespace flash_proxy;
	
	/**
	 * Basic parameters implementation.
	 * 
	 * <p>Each parameter can have a default value defined as a fallback.</p>
	 * 
	 * <p><b>EXAMPLE:</b></p>
	 * <listing>
	 * 
	 * parameters.defaults.username = "Visitor";
	 * 
	 * trace(parameters.username); // Prints the default value, "Visitor".
	 * 
	 * parameters.username = "Bozo";
	 * 
	 * trace(parameters.username); // Prints "Bozo" instead of the default.
	 * </listing>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Lucas Dupin
	 * @since  16.06.2010
	 */
	dynamic public class Parameters extends Proxy implements IDisposable
	{
	  //Inheritance
		public var inherit:Parameters;
	  
		/** @private */
		protected var _parameters:Config;
		/** @private */
		protected var _defaults:Dictionary;
		
		/** @private */
		protected var _allKeys:Array=[];
		
		/** @private */
		protected var _updateKeys:Boolean = true;
		
		/**
		 * @constructor
		 */
		public function Parameters(config:Config=null)
		{
			_parameters = config ? config : new Config();
			_parameters.init();
			
			_defaults = new Dictionary();
		}
	
		/**
		 * Gets the value in the config, if there is none, uses <code>defaults</code> as a fallback.
		 */
		override flash_proxy function getProperty(name:*):*
		{
			var val:* = _parameters.hasProperty(name) ? _parameters.getProperty(name) : _defaults[name];
			
			//None found, trying to get inherited
			if(val == undefined && inherit)
			{
				val = inherit[name];
			}
				
				
			if (val is String)
				val = printf(val, this);
			
			return val;
		}
		
		/**
		 * Adds a value to the view parameters config.
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			_updateKeys = true;
			
			////Verify if it was inherited
			//if(inherit && inherit[name])
			//	inherit[name] = value;
			////No.. only set
			//else
			_parameters.setProperty(name, value);
			
			return;
		}
		
		/**
		 * @private
		 */
		flash_proxy override function nextNameIndex(index:int):int
		{
			return (index+1) % keys.length;
		} 
		
		/**
		 * @private
		 */
		flash_proxy override function nextName(index:int):String
		{
			return keys[index-1];
		}
		
		/**
		 * The keys defined by defaults and parameters.
		 */
		public function get keys():Array
		{
			if (_updateKeys)
			{
				_allKeys = _parameters.keys;
				for (var s:String in _defaults)
					_allKeys.push(s)
				_updateKeys = false;
			}
			
			return _allKeys;
		}
		
		/**
		 * Defaults are values which will be overwritten when parameters are set.
		 */
		public function get defaults():Dictionary
		{
			_updateKeys = true;
			return _defaults;
		}
		
		/**
		* Adds another config to parameters. Using this method, you can load or create configs and later add them to the parameters.
		* 
    * @param otherConfig Config 
    * 
    */
		public function inject(otherConfig:Config):void
		{
			for each (var key:Object in otherConfig.keys)
			{
				//Do not override parameters already set
				if(!_parameters.hasProperty(key))
					_parameters.setProperty(key, otherConfig.getProperty(key));
			}
			_updateKeys = true;
			
		}
		
		/**
		 * @private
		 */
		public function configForKey(key:Object):Config
		{
			return _parameters.configForKey(key);
		}	
		
		/**
		 * @private
		 */
		public function toString():String
		{
			return "[Parameters] " + keys.toString();
		}
		
		/**
		 * @private
		 */
		public function dispose():void
		{
			_parameters = null;
			_allKeys = null;
			_defaults = null;
		}
	}

}
