package potato.modules.navigation.presets
{
	import potato.core.config.JSONConfig;
  import potato.modules.tracking.Tracker;
	import potato.modules.i18n.I18n;
	
	// Potato Navigation module namespace
	import potato.modules.navigation.potato_navigation;
	import flash.events.Event;

  /**
   * Complex view preset (I18n, tracking) configured with JSON syntax.
   * 
   * @langversion ActionScript 3
   * @playerversion Flash 10.0.0
   * 
   * @author Lucas Dupin, Fernando França
   * @since  16.06.2010
   */
	public class JSONLoaderView extends ALoaderView
	{
	
		public function JSONLoaderView()
		{
			super();
		}
		
		override protected function onAddedToStage(e:Event):void
		{	
			super.onAddedToStage(e);
			
      //Setting default parameters
      parameters.defaults.defaultExtension = "json";

      //Initialize tracking
      Tracker.instance.config = new JSONConfig(parameters.tagsFile);

      //I18n type
      I18n.parser = JSONConfig;
			
			//Boot
			potato_navigation::startup(new JSONConfig(parameters.configFile));
		}
	
	}

}
