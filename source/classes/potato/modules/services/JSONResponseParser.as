package potato.modules.services
{
	import com.adobe.serialization.json.JSONDecoder;
	import potato.modules.services.IResponseParser;

	public class JSONResponseParser implements IResponseParser
	{
		public function get id():String
		{
			return "json";
		}
		
		public function parse(rawContent:String):*
		{
			try
			{
				var jsonDecoder:JSONDecoder = new JSONDecoder(rawContent, false);
				var content:* = jsonDecoder.getValue();
				return content;
			}
			catch (e:Error)
			{
				trace("JSONResponse::parse() error", e.message);
				return null;
			}
		}
	}

}
