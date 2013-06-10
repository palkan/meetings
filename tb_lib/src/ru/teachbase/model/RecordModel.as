package ru.teachbase.model
{
import ru.teachbase.model.constants.RecordingStates;

public class RecordModel
	{
		
		private var _duration:Number;
		
		[Bindable]
		private var _position:Number = 0;
		
		[Bindable]
		private var _finished:Boolean = false;
		
		
		private var _state:uint = RecordingStates.IDLE;
		
		
		public function RecordModel(duration:Number)
		{
			_duration = duration;
		}

				
		/**
		 * 
		 * @return duration of record in seconds 
		 * 
		 */
		
		public function get duration():Number
		{
			return _duration;
		}

		/**
		 * 
		 * @return Current play position in seconds
		 * 
		 */
		[Bindable]
		public function get position():Number
		{
			return _position;
		}

		public function set position(value:Number):void
		{
			_position = value;
		}

		[Bindable]
		public function get finished():Boolean
		{
			return _finished;
		}

		public function set finished(value:Boolean):void
		{
			_finished = value;
		}

		public function get state():uint
		{
			return _state;
		}

		public function set state(value:uint):void
		{
			_state = value;
		}


	}
}