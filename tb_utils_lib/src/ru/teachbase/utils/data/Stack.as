package ru.teachbase.utils.data
{
	/**
	 * Simple stack based on Array.
	 * 
	 */
	
	public dynamic class Stack extends Array
	{
		public function Stack()
		{
		}
		
		/**
		 *  Pushes an object with params <i>width</i> and <i>height</i> to Stack
		 * 
		 * 	@param w width
		 * 	@param h height
		 * 
		 */
		
		public function pushObj(w:int,h:int):void{
			var params:Object = new Object();
			params.width = w;
			params.height = h;
			super.push(params);
		}
		
		/**
		 * 
		 *	Returns the top element of Stack.
		 *  
		 * @param index if index is defined then retrun value is the indexth element from the top
		 */
		
		public function top(index:int = 0):*{
			if(this[this.length-1-index])
				return this[this.length-1-index];
			else
				return null;
		}
		
		
		/**
		 * Returns <b>true</b> if there exist elements in Stack, otherwise returns <b>false</b>
		 *  
		 */
	
		public function isEmpty():Boolean{
			
			if(this.length === 0)
				return true;
			else
				return false;
			
		}
	}
}