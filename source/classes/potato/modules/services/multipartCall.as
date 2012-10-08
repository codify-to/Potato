package potato.modules.services
{
  import potato.modules.services.ServiceManager;
  import potato.modules.services.ServiceEvent;
  import flash.events.ProgressEvent;
  import potato.modules.services.Service;
  import potato.modules.log.log;
  /**
   * Multipart service call
   * @param serviceID String 
   * @param callParameters Object 
   * @param callConfiguration Object 
   */
  public function multipartCall(serviceID:String, callParameters:Object = null, callConfiguration:Object = null):void
  {
    var service:Service = ServiceManager.instance.getServiceByID(serviceID);
    if(!service){
      log("[multipartCall] No service called '" + serviceID + "' found");
      return;
    }
    var serviceCall:MultipartServiceCall = new MultipartServiceCall(service, callParameters);

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

}
