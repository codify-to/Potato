package potato.display
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import potato.core.IDisposable;
	import potato.control.DisposableGroup;
	import potato.display.safeRemoveChild;

	/**
	 * Provides easier management of disposable child objects.
	 * This class mimetizes the addChild methods of the Sprite class.
	 *
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 *
	 * @author Fernando França
	 * @since	30.07.2010
	 */
	public class DisposableSprite extends Sprite implements IDisposable
	{
		/** @private */
		protected var _disposableChildren:DisposableGroup;

		/** @private */
		protected var _removableChildren:Vector.<DisplayObject>;

		public function DisposableSprite()
		{
			_disposableChildren = new DisposableGroup();
			_removableChildren = new Vector.<DisplayObject>();
		}

		public function disposeChildren():void
		{
			_disposableChildren.disposeElements();

			for each(var displayObject:DisplayObject in _removableChildren)
			{
				safeRemoveChild(displayObject);
			}
			_removableChildren.length = 0;
		}

		/**
		 * Disposes children by calling their <code>dispose()</code> method and removing the ones registered as <code>DisplayObjects</code>.
		 */
		public function dispose():void
		{
			if(_disposableChildren == null) return;

			_disposableChildren.dispose();
			_disposableChildren = null;

			for each(var displayObject:DisplayObject in _removableChildren)
			{
				safeRemoveChild(displayObject);
			}
			_removableChildren.length = 0;
			_removableChildren = null;
		}

		/**
		 * Registers a disposable object.
		 * @param obj IDisposable
		 */
		public function addDisposable(obj:IDisposable):IDisposable
		{
			_disposableChildren.addElement(obj);
			return obj;
		}

		/**
		 * Adds and registers a disposable child DisplayObject.
		 * @param obj IDisposable
		 * @param params Object [optional] Initialization parameters
		 */
		public function addDisposableChild(obj:IDisposable, params:Object = null):DisplayObject
		{
			_disposableChildren.addElement(obj);

			var displayObject:DisplayObject = obj as DisplayObject;
			_removableChildren.push(displayObject);

			if(params != null)
			{
				for (var key:String in params) obj[key] = params[key];
			}

			return addChild(displayObject);
		}

		/**
		 * Adds and registers a child DisplayObject which doesn't implement IDisposable
		 * @param displayObject DisplayObject
		 * @param params Object [optional] Initialization parameters
		 */
		public function addRemovableChild(displayObject:DisplayObject, params:Object = null):DisplayObject
		{
			_removableChildren.push(displayObject);
			if(params != null)
			{
				for (var key:String in params)
					displayObject[key] = params[key];
			}
			return addChild(displayObject);
		}

		public function addRemovableChildAt(displayObject:DisplayObject, index:int, params:Object = null):DisplayObject
		{
			_removableChildren.push(displayObject);
			if(params != null)
			{
				for (var key:String in params)
					displayObject[key] = params[key];
			}
			return addChildAt(displayObject, index);
		}

		/**
		 * Adds and registers a disposable child DisplayObject at the given index.
		 * @param obj IDisposable
		 */
		public function addDisposableChildAt(obj:IDisposable, index:int):DisplayObject
		{
			_disposableChildren.addElement(obj);

			var displayObject:DisplayObject = obj as DisplayObject;
			_removableChildren.push(displayObject);

			return addChildAt(displayObject, index);
		}
	}

}
