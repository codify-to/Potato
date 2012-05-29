package potato.modules.services
{
	import potato.modules.services.ServiceManager;
	
	/**
	 * Shortcut for creating new service calls.
	 * 
	 * @param serviceID The service id.
	 * @param callParameters Service parameters.
	 * @param callConfiguration Configuration object. Accepts the following shortcuts: <code>onComplete, onProgress, onError</code>.
	 */
	public function call(serviceID:String, callParameters:Object = null, callConfiguration:Object = null):void
	{
		ServiceManager.instance.call(serviceID, callParameters, callConfiguration);
	}
	
}
