package potato.modules.navigation.presets
{
  import potato.modules.parameters.Parameters;
  import potato.modules.navigation.View;
  import potato.modules.dependencies.Dependencies;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import potato.modules.i18n.I18n;
  import flash.events.Event;

	/**
	 * The complex view includes the parameters, dependencies and localization (I18n) modules.
	 * This abstract base class is extended for each configuration file type (defaultExtension).
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Lucas Dupin, Fernando França
	 * @since  16.06.2010
	 */
  public class ALoaderView extends View
  {

    public function ALoaderView()
    {
      //Making sure these modules are included
      Parameters;
      Dependencies;
      I18n;
    
      addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    protected function onAddedToStage(e:Event):void
    {
      removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

      //Stage setup
      if(stage){
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
      }

      //Setting default parameters
      setDefaultParameters();

      //Getting data from loaderInfo (flashvars)
      for (var p:String in loaderInfo.parameters)
      {
        var val:* = loaderInfo.parameters[p];
        if(val == "true" || val == "false")
          parameters[p] = (val == "true");
        else if(!isNaN(val))
          parameters[p] = Number(loaderInfo.parameters[p]);
        else
          parameters[p] = loaderInfo.parameters[p];
      }
    }
    
    protected function setDefaultParameters():void
    {
      parameters.defaults.basePath   = "."
      parameters.defaults.configFile = "%(basePath)s/data/main.%(defaultExtension)s";
      parameters.defaults.tagsFile   = "%(basePath)s/data/tags.%(defaultExtension)s";
      parameters.defaults.locale     = "pt_BR";
      parameters.defaults.localePath = "%(basePath)s/data/locales/%(locale)s";
    }

  }

}
