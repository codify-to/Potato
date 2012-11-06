package potato.modules.services
{
  import flash.events.EventDispatcher;
  import flash.events.Event;
  import flash.net.URLRequest;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.events.HTTPStatusEvent;
  import flash.events.IOErrorEvent;
  import br.com.stimuli.string.printf;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
  import potato.modules.log.log;
  import ru.inspirit.net.MultipartURLLoader;
  import potato.modules.services.Service;
  import potato.modules.services.ServiceEvent;
  import flash.utils.ByteArray;
  import potato.modules.services.ServiceCall;

  public class MultipartServiceCall extends ServiceCall
  {
    protected var _multipartLoader:MultipartURLLoader;
    protected var _url:String;

    public function MultipartServiceCall(service:Service, parameters:Object = null)
    {
      super(service, parameters);
    }

    override public function start():void
    {
      _multipartLoader = new MultipartURLLoader();
      _multipartLoader.addEventListener(Event.COMPLETE, onComplete);
      _multipartLoader.addEventListener(Event.OPEN, onOpen);
      _multipartLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
      _multipartLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
      _multipartLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
      _multipartLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);

      _url = printf(_service.url, _parameters);

      if(_parameters)
      {
        for(var key:String in _parameters)
        {
          var keyValue:* = _parameters[key];
          if(keyValue is ByteArray)
            _multipartLoader.addFile(keyValue, "imgUpload"+int(Math.random()*10000000)+".jpg", key, "image/jpg");
          else {
              if(_service.encoder)
                _multipartLoader.addVariable(key, _service.encoder.encode(_parameters[key]));
              else
                _multipartLoader.addVariable(key, keyValue);
          }
        }

      }

      // Timer setup
      _tries = 0;
      _timer = new Timer(_service.timeout, 1);
      _timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeout, false, 0, true);

      try {
        _timer.reset();
        _timer.start();
        _multipartLoader.load(_url);
      }
      catch (error:Error) {
        _timer.reset();
        log("[MultipartServiceCall] Unable to load requested document.");
        dispatchEvent(new ServiceEvent(ServiceEvent.CALL_ERROR, this));
      }
    }

    override public function retry():void
    {
      _tries++;
      try {
        _timer.reset();
        _timer.start();
        _multipartLoader.load(_url);
      }
      catch (error:Error) {
        _timer.reset();
        log("[MultipartServiceCall] Unable to load requested document.");
        dispatchEvent(new ServiceEvent(ServiceEvent.CALL_ERROR, this));
      }
    }

    override public function onTimeout(e:TimerEvent):void
    {
      try {
        _multipartLoader.close();
      }
      catch(error:Error) {

      }

      if(_tries < _service.retries)
      {
        log("[MultipartServiceCall] Timeout", _tries)
        retry();
      }
      else
      {
        log("[MultipartServiceCall] Timeout ocurred too many times.");
        dispatchEvent(new ServiceEvent(ServiceEvent.CALL_ERROR, this));
      }

    }

    override protected function onComplete(e:Event):void
    {
      _timer.stop();
      _rawContent = _multipartLoader.loader.data;
      _content = _service.parser ? _service.parser.parse(_rawContent) : rawContent;
      dispatchEvent(new ServiceEvent(ServiceEvent.CALL_COMPLETE, this));
    }

  }

}
