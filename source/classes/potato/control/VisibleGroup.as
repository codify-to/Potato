package potato.control
{
	import potato.core.IVisible;
	import potato.core.IDisposable;

	/**
	 * Groups IVisible objects.
	 * Subgrouping is also possible with this approach.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Fernando França
	 * @since  29.07.2010
	 */
	public class VisibleGroup implements IVisible, IDisposable
	{
	  /** @private */
		protected var _elements:Vector.<IVisible>;
	
		public function VisibleGroup()
		{
			_elements = new Vector.<IVisible>();
		}
		
		public function dispose():void
		{
			_elements.length = 0;
			_elements = null;
		}
		
		public function addElement(obj:IVisible):void
		{
			if(_elements.indexOf(obj) == -1)
				_elements.push(obj);
		}
	
		public function removeElement(obj:IVisible):void
		{
			_elements.splice(_elements.indexOf(obj), 1);
		}
		
		public function show():void
		{
			var obj:IVisible;
			for each(obj in _elements){
				obj.show();
			}
		}
	
		public function hide():void
		{
			var obj:IVisible;
			for each(obj in _elements){
				obj.hide();
			}
		}
	}
}