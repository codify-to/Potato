package potato.modules.tracking
{
  import flash.events.Event;
  import potato.core.config.Config;
  import flash.external.ExternalInterface;
  import br.com.stimuli.string.printf;
  import potato.modules.log.log;

  /**
  * Configurable tracking implementation.
  * 
  * @langversion ActionScript 3
  * @playerversion Flash 10.0.0
  * 
  * @author Lucas Dupin, Fernando França
  * @since  26.07.2010
  */
  public class Tracker
  {
    /**
    * External Javascript tracking function name.
    */
    public var functionName:String = "track";
    
    /**
    * Tracking call queue.
    * @private
    */
    public var _trackQueue:Array = [];

    /**
    * Tracking configuration.
    * @private
    */
    private var _config:Config;

    /**
    * Simple flag.
    * @private
    */
    private var _configLoaded:Boolean;

    /**
    * Singleton instance.
    * @private
    */
    private static var _instance:Tracker;

    /**
    * Tracker's instance (Singleton).
    */
    public static function get instance():Tracker
    {
      if(!_instance)
        _instance = new Tracker(new SingletonEnforcer());

      return _instance;
    }

    /**
    * Constructor (Singleton, access is only allowed through the Tracker.instance).
    * 
    * @constructor
    * @private
    */
    public function Tracker(singleton:SingletonEnforcer){}

    /**
     * Tracking configuration.
     */
    public function set config(value:Config):void
    {
      _config = value;
    }

    /**
    * Creates a new tracking call and pushes it to the queue.
    * @param	id	 The id of the tracking call.
    * @param	replace	 Optional arguments of the tracking call.
    */
    public function track(id:String, ...replace):void
    {
      // Adding to the _trackQueue
      _trackQueue.push({id: id, replace: replace});

      // Check if it's loaded
      if(!_configLoaded) {
        loadConfig();
      }
      else {
        processQueue();
      }
    }

    /**
    * Process next queued tracking calls.
    */
    public function processQueue():void
    {
      // Tracking sequence
      while (_trackQueue.length)
      {
        var o:Object = _trackQueue.shift();

        //Getting the value of this key in the config
        var val:String = _config.getProperty(o.id);

        //String interpolation
        val = printf.apply(null, [val].concat(o.replace));

        //Calling
        ExternalInterface.call(functionName, val);
      }

    }

    /**
    * Load configuration file.
    * @private
    */
    protected function loadConfig():void
    {
      if(!_config)
      {
        log("[Tracker] no config");
        return;
      }
      
      _config.addEventListener(Event.INIT, onConfigInit);
      _config.init();
    }

    /**
    * Configures tracker after configuration has been loaded.
    * @param e Event 
    * @private
    */
    protected function onConfigInit(e:Event):void
    {
      e.target.removeEventListener(Event.INIT, onConfigInit);
      _configLoaded = true;
      processQueue();
    }
    
  }
}

/**
 * Enforces the Singleton design pattern.
 */
internal class SingletonEnforcer{}
