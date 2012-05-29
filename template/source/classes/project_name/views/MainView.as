package {project_name}.views
{	
	import potato.modules.navigation.View;
	
	public class MainView extends View
	{

		override public function init():void
		{
			with(graphics) beginFill(0x0), drawRect(0, 0, 100, 100), endFill();
		}
		
		override public function show():void
		{
			super.show();
		}
		
		override public function hide():void
		{
			super.hide();
		}
		
		override public function resize():void
		{
			
		}
		
		override public function dispose():void
		{
			
		}

	}
}