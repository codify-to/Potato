package potato.modules.services
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import potato.modules.services.ServiceEvent;
	import flash.events.ProgressEvent;
	import br.com.stimuli.string.printf;
	import potato.modules.services.ICallEncoder;
	import potato.modules.log.log;
	
	/**
	 * Application services manager.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Fernando França
	 * @since  28.10.2010
	 */
	public class ServiceManager extends EventDispatcher
	{
		protected var _registeredServices:Dictionary;
		protected var _registeredParsers:Dictionary;
		protected var _registeredEncoders:Dictionary;
		
		public function ServiceManager(singleton:SingletonEnforcer)
		{
			_registeredServices = new Dictionary();
			_registeredParsers = new Dictionary();
			_registeredEncoders = new Dictionary();
		}
		
		public function registerServicesByConfig(parameters:Object):void
		{
			for each(var serviceConfig:* in parameters.services)
			{
				var serviceID:String = serviceConfig.id;
				var serviceURL:String = printf(serviceConfig.url, parameters);
				var serviceParser:IResponseParser = getParserByID(serviceConfig.parser);
				var serviceEncoder:ICallEncoder = getEncoderByID(serviceConfig.encoder);
				var serviceMethod:String = serviceConfig.method || "post";
				
				registerService(new Service(serviceID, serviceURL, serviceParser, serviceEncoder, serviceMethod));
			}
		}
		
		public function registerParser(parser:IResponseParser):void
		{
			_registeredParsers[parser.id] = parser;
		}
		
		public function getParserByID(id:String):IResponseParser
		{
			if(_registeredParsers.hasOwnProperty(id))
				return _registeredParsers[id];
			else
				return null;
		}
		
		public function registerEncoder(encoder:ICallEncoder):void
		{
			_registeredEncoders[encoder.id] = encoder;
		}
		
		public function getEncoderByID(id:String):ICallEncoder
		{
			if(_registeredEncoders.hasOwnProperty(id))
				return _registeredEncoders[id];
			else
				return null;
		}
		
		public function registerService(service:Service):void
		{
			_registeredServices[service.id] = service;
		}
		
		public function getServiceByID(serviceID:String):Service
		{
			return _registeredServices[serviceID];
		}
		
		public function call(serviceID:String, callParameters:Object = null, callConfiguration:Object = null):void
		{
		  var service:Service = getServiceByID(serviceID);
		  if(!service){
		    log("[ServiceManager] No service called '" + serviceID + "' found");
		    return;
		  }
			var serviceCall:ServiceCall = new ServiceCall(service, callParameters);
			
			// Handy configuration of listeners
			if(callConfiguration != null)
			{
				if(callConfiguration.hasOwnProperty("onComplete")) 
					serviceCall.addEventListener(ServiceEvent.CALL_COMPLETE, callConfiguration.onComplete, false, 0, true);
					
				if(callConfiguration.hasOwnProperty("onError"))
					serviceCall.addEventListener(ServiceEvent.CALL_ERROR, callConfiguration.onError, false, 0, true);
				
				if(callConfiguration.hasOwnProperty("onProgress"))
					serviceCall.addEventListener(ProgressEvent.PROGRESS, callConfiguration.onProgress, false, 0, true);
			}
			serviceCall.start();
		}
		
		private static var __instance:ServiceManager;
		
		public static function get instance():ServiceManager
		{
			if(!__instance)
				__instance = new ServiceManager(new SingletonEnforcer());
			return __instance;
		}
	}

}

/**
 * Enforces the Singleton design pattern.
 */
internal class SingletonEnforcer{}
