package potato.core.config
{
import flash.events.EventDispatcher;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.Event;
import flash.events.IOErrorEvent;
import dupin.parsers.yaml.YAML;
import potato.modules.log.log;

/**
 *  Dispatched after the YAML file has been loaded and parsed.
 *
 *  @eventType flash.events.Event.INIT
 */
[Event(name="init", type="flash.events.Event")]

/**
 * Configuration based on YAML files.
 * 
 * @langversion ActionScript 3
 * @playerversion Flash 10.0.0
 * 
 * @author Lucas Dupin, Fernando França
 * @since  15.06.2010
 */
public class YAMLConfig extends Config
{
	/**
	 * URL for the YAML file
	 * @private
	 */
	protected var _url:String;
	
	/**
	 * @param	url	 The URL of the YAML configuration file.
	 * @constructor
	 */
	public function YAMLConfig(url:String)
	{
		_url = url;
	}
	
	/**
	 * Starts loading the YAML file.
	 */
	override public function init():void
	{
		var urlLoader:URLLoader = new URLLoader();
		
		try
		{
			urlLoader.load(new URLRequest(_url));
		} 
		catch (e:SecurityError)
		{
			log("[YAMLConfig] Security error : " + e.errorID + " " + e.message);
		}
		
		urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		urlLoader.addEventListener(Event.COMPLETE, onConfigLoaded);
	}
	
	
	/**
	 * @private
	 */
	protected function onLoadError(e:IOErrorEvent):void
	{
		e.target.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		e.target.removeEventListener(Event.COMPLETE, onConfigLoaded);
		
		log("[YAMLConfig] IO error:  " + e.text);
	}
	
	/**
	 * Parses the YAML file after it has been loaded and dispatches the INIT event.
	 * @private
	 */
	protected function onConfigLoaded(e:Event):void
	{
		// Removing listener, so that we won't have memory leaks
		e.target.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		e.target.removeEventListener(Event.COMPLETE, onConfigLoaded);
		
		// Parse YAML
		_config = YAML.decode(e.target.data);
		
		// Notify
		dispatchEvent(new Event(Event.INIT));
	}
	
}

}