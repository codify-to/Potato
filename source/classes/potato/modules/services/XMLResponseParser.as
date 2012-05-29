package potato.modules.services
{
  import potato.modules.log.log;
	/**
	 * Parser for general xml content.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Janio Cassio Leite
	 * @since  04.11.2010
	 */
	public class XMLResponseParser implements IResponseParser
	{
	
		public function get id () : String
		{
			return "xml" ;
		}
	
		
		/**
		 * Turn raw content in XML native format.
		 * If any cast error happen, a error description is returned in XML format.
		 */
		public function parse (rawContent : String) : *
		{
			try
			{
				return XML(rawContent);
			}
			catch(e : TypeError)
			{
				log("XMLResponseParser::get error = ", e.message);
				return <xml>
					<error>
						<id>{e.errorID}</id>
						<name>{e.name}</name>
						<message>{e.message}</message>
						<stack>{e.getStackTrace()}</stack>
					</error>
				</xml>
			}
		}
	}

}