package ru.teachbase.utils.extensions
{
import flash.text.TextField;

import mx.managers.IFocusManagerComponent;

public class FocusTextField extends TextField implements IFocusManagerComponent
	{
		public function FocusTextField()
		{
			super();
		}
		
		public function get focusEnabled():Boolean
		{
			return true;
		}
		
		public function set focusEnabled(value:Boolean):void
		{
		}
		
		public function get hasFocusableChildren():Boolean
		{
			return false;
		}
		
		public function set hasFocusableChildren(value:Boolean):void
		{
		}
		
		public function get mouseFocusEnabled():Boolean
		{
			return false;
		}
		
		public function get tabFocusEnabled():Boolean
		{
			return true;
		}
		
		public function setFocus():void
		{
			stage.focus = this;
		}
		
		public function drawFocus(isFocused:Boolean):void
		{
		}
	}
}