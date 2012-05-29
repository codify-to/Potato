package potato.modules.services
{
	import com.adobe.serialization.json.JSONEncoder;
	import potato.modules.services.ICallEncoder;
	import potato.modules.log.log;

	public class JSONCallEncoder implements ICallEncoder
	{
		public function get id():String
		{
			return "json";
		}
		
		public function encode(value:*):String
		{
			try
			{
				var jsonEncoder:JSONEncoder = new JSONEncoder(value);
				var content:String = jsonEncoder.getString();
				return content;
			}
			catch (e:Error)
			{
				log("JSONCallEncoder::encode() error", e.message);
				return null;
			}
			return null;
		}
	}
}