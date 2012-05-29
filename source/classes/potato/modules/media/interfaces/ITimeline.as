package potato.modules.media.interfaces
{
	public interface ITimeline
	{
		function set timeRatio(value:Number):void;
		
		function get timeRatio():Number;
		
		function set time(value:Number):void;
		
		function get time():Number;
		
		function set timeTotal(value:Number):void;	
		
		function get timeTotal():Number;	
	}
}