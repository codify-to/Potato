package potato.modules.services
{
	import flash.events.Event;
	import potato.modules.services.ServiceCall;
	
	/**
	 * Service event implementation. Simplified service error handling is available through this class.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Fernando França
	 * @since  28.10.2010
	 */
	public class ServiceEvent extends Event
	{
		public static const CALL_START:String    = "call_start";
		public static const CALL_COMPLETE:String = "call_complete";
		public static const CALL_ERROR:String    = "call_error";
		public static const CALL_RETRY:String    = "call_retry";
		
		protected var _serviceCall:ServiceCall;
		
		public function ServiceEvent(type:String, serviceCall:ServiceCall = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
		  _serviceCall = serviceCall;
			super(type, bubbles, cancelable);
		}
		
		public function get serviceCall():ServiceCall
		{
		  return _serviceCall;
		}
		
		public function get service():Service
		{
		  return _serviceCall? _serviceCall.service : null;
		}
		
		public function get content():Object
		{
			return _serviceCall.content;
		}

		public function get rawContent():Object
		{
			return _serviceCall.rawContent;
		}
		
	}
}