package ru.teachbase.utils.system
{
import flash.display.Stage;
import flash.display.StageDisplayState;

/**
	 * @author Teachbase (created: Jun 9, 2012)
	 */
	public function isFullScreenMode(stage:Stage):Boolean
	{
		return stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE || stage.displayState == StageDisplayState.FULL_SCREEN;
	}
}