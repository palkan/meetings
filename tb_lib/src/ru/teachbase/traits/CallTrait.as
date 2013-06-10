package ru.teachbase.traits
{
import ru.teachbase.model.constants.PacketType;

/**
	 * Use this trait if you only call operations and not to receive messages from server.
	 *  
	 * @author VOVA
	 * 
	 */
	public class CallTrait extends Trait
	{
		public function CallTrait()
		{
			super(PacketType.CALL_ONLY, true);
		}
	}
}