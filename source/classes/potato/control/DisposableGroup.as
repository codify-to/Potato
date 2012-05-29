package potato.control
{
	import potato.core.IDisposable;

	/**
	 * Groups IDisposable objects.
	 * Subgrouping is also possible with this approach.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Fernando França
	 * @since  29.07.2010
	 */
	public class DisposableGroup implements IDisposable
	{
	  /** @private */
		protected var _elements:Vector.<IDisposable>;
	
		public function DisposableGroup()
		{
			_elements = new Vector.<IDisposable>();
		}
		
		public function dispose():void
		{
			var obj:IDisposable;
			for each(obj in _elements){
				obj.dispose();
			}
			
			_elements.length = 0;
			_elements = null;
		}
		
		public function addElement(obj:IDisposable):void
		{
			if(_elements.indexOf(obj) == -1)
				_elements.push(obj);
		}
		
		public function removeElement(obj:IDisposable):void
		{
			_elements.splice(_elements.indexOf(obj), 1);
		}
	}
}