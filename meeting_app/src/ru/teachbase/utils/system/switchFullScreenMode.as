package ru.teachbase.utils.system
{
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.system.Security;

/**
	 * @author Teachbase (created: Jun 9, 2012)
	 */

	public function switchFullScreenMode(stage:Stage):Boolean
	{
		
		if(stage.displayState === StageDisplayState.NORMAL)
			stage.displayState = (Security.sandboxType == Security.APPLICATION) ? StageDisplayState.FULL_SCREEN_INTERACTIVE : StageDisplayState.FULL_SCREEN;
		else
			stage.displayState = StageDisplayState.NORMAL;
		
		return isFullScreenMode(stage);
	}
}