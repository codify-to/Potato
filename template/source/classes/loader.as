package
{	
	import potato.modules.navigation.presets.YAMLLoaderView;
	import potato.modules.navigation.ViewLoader;
	import flash.events.Event;
	import flash.events.ProgressEvent;

	[SWF(backgroundColor='#FFFFFF', frameRate='60')]
	public class {project_name}_loader extends YAMLLoaderView
	{

		override public function init():void
		{
			var vl:ViewLoader = loaderFor("main");
			vl.addEventListener(ProgressEvent.PROGRESS, onMainLoadProgress);
			vl.addEventListener(Event.COMPLETE, onMainLoadComplete);
			vl.start();
		}

		protected function onMainLoadProgress(e:ProgressEvent):void
		{
			//e.bytesLoaded / e.bytesTotal
		}

		protected function onMainLoadComplete(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, onMainLoadComplete);
			e.target.removeEventListener(ProgressEvent.PROGRESS, onMainLoadProgress);
			changeView("main");
		}

	}
}
