package potato.modules.media.interfaces
{
	public interface IStream
	{
		function load(url:String, bufferTime:Number = 1000, checkPolicyFile:Boolean = false):void;
		
		function close():void;
		
		function get bytesLoaded():uint;

		function get bytesTotal():uint;			
		
		function get loadRatio():Number;		
	}
}