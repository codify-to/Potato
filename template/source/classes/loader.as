package
{	
  import potato.modules.navigation.presets.YAMLLoaderView;
  import potato.modules.navigation.ViewLoader;
  import flash.events.Event;

  public class {project_name}_loader extends YAMLLoaderView
  {

    override public function init():void
    {
      var vl:ViewLoader = loaderFor("main");
      vl.addEventListener(Event.COMPLETE, onMainLoadComplete);
      vl.start();
    }

    public function onMainLoadComplete(e:Event):void
    {
      e.target.removeEventListener(Event.COMPLETE, onMainLoadComplete);
      changeView("main");
    }

  }
}
