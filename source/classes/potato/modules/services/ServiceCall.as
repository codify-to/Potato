package potato.modules.services
{
	import flash.net.URLLoader;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import br.com.stimuli.string.printf;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import potato.modules.log.log;
	
	/**
	 * Service call implementation. Any given service can have an unlimited number of calls.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Fernando França
	 * @since  28.10.2010
	 */
	public class ServiceCall extends EventDispatcher
	{
		protected var _service:Service;
		protected var _parameters:Object;
		protected var _content:Object;
		protected var _rawContent:String;
		protected var _urlLoader:URLLoader;
		protected var _urlRequest:URLRequest;
		
		protected var _timer:Timer;
		protected var _tries:Number;
		
		public function ServiceCall(service:Service, parameters:Object = null, urlParameters:Object = null)
		{
			_service = service;
			_parameters = parameters;
		}
		
		public function get service():Service
		{
		  return _service;
		}
		
		public function get content():Object
		{
		  return _content;
		}
		
		public function get rawContent():String
		{
		  return _rawContent;
		}
		
		public function start():void
		{
      _urlLoader = new URLLoader();
      _urlLoader.addEventListener(Event.COMPLETE, onComplete);
      _urlLoader.addEventListener(Event.OPEN, onOpen);
      _urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
      _urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
      _urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
      _urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
      
			_urlRequest = new URLRequest(printf(_service.url, _parameters));
			
			if(_parameters)
			{
				var urlVariables:URLVariables = new URLVariables();
				for(var key:String in _parameters)
				{
					if(_service.encoder)
						urlVariables[key] = _service.encoder.encode(_parameters[key]);
					else
						urlVariables[key] = _parameters[key];
				}
				_urlRequest.data = urlVariables;
			}
			_urlRequest.method = _service.requestMethod;
			
			// Timer setup
			_tries = 0;
			_timer = new Timer(_service.timeout, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeout, false, 0, true);
			
			try {
        _timer.reset();
		    _timer.start();
				_urlLoader.load(_urlRequest);
			}
			catch (error:Error) {
			  _timer.reset();
        log("[ServiceCall] Unable to load requested document.");
				dispatchEvent(new ServiceEvent(ServiceEvent.CALL_ERROR, this));
			}
		}
		
		public function retry():void
		{
		  _tries++;
		  try {
		    _timer.reset();
		    _timer.start();
				_urlLoader.load(_urlRequest);
			}
			catch (error:Error) {
			  _timer.reset();
        log("[ServiceCall] Unable to load requested document.");
				dispatchEvent(new ServiceEvent(ServiceEvent.CALL_ERROR, this));
			}
		}
		
		public function onTimeout(e:TimerEvent):void
		{
		  try {
		    _urlLoader.close();
	    }
	    catch(error:Error) {
	      
	    }
		  
		  if(_tries < _service.retries)
		  {
		    log("[ServiceCall] Timeout", _tries)
		    retry();
		  }
		  else
		  {
		    log("[ServiceCall] Timeout ocurred too many times.");
		    dispatchEvent(new ServiceEvent(ServiceEvent.CALL_ERROR, this));
		  }
		  
		}
		
		protected function onComplete(e:Event):void
		{
		  _timer.stop();
			_rawContent = _urlLoader.data;
			_content = _service.parser ? _service.parser.parse(_rawContent) : rawContent;
			dispatchEvent(new ServiceEvent(ServiceEvent.CALL_COMPLETE, this));
		}

		protected function onOpen(e:Event):void {
       //log("[ServiceCall] Open");
		}

		protected function onProgress(e:ProgressEvent):void
		{
		  _timer.reset();
	    _timer.start();
		  dispatchEvent(e);
		}

		protected function onSecurityError(e:SecurityErrorEvent):void
		{
		  _timer.stop();
		  log("[ServiceCall] Security Error", e);
			dispatchEvent(new ServiceEvent(ServiceEvent.CALL_ERROR, this));
		}

		protected function onHttpStatus(e:HTTPStatusEvent):void
		{
      //log("[ServiceCall] HTTP Status:", e);
		}

		protected function onIOError(e:IOErrorEvent):void
		{
		  _timer.stop();
			log("[ServiceCall] IO Error", e);
			dispatchEvent(new ServiceEvent(ServiceEvent.CALL_ERROR, this));
		}
		
	}

}