package ru.teachbase.utils.system
{
import flash.display.Stage;
import flash.display.StageDisplayState;

import ru.teachbase.core.App;

/**
	 * @author Teachbase (created: Jun 9, 2012)
	 */

	public function switchFullScreenMode(stage:Stage):Boolean
	{
		
		if(stage.displayState === StageDisplayState.NORMAL)
			stage.displayState = (App.mode === 'air') ? StageDisplayState.FULL_SCREEN_INTERACTIVE : StageDisplayState.FULL_SCREEN;
		else
			stage.displayState = StageDisplayState.NORMAL;
		
		return isFullScreenMode(stage);
	}
}