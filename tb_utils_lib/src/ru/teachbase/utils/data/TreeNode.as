package ru.teachbase.utils.data
{

import ru.teachbase.utils.interfaces.IDisposable;

/**
	 * @author Webils (2012)
	 */
		
	public class TreeNode implements IDisposable
	{
			
		public var type:uint;
		public var hasChildren:Boolean;
				
		public var data:* = false;
				
		public var key:String='';
		
		private var _right:TreeNode = null;
		private var _left:TreeNode = null;
		private var _parent:TreeNode = null;
		
		private var _disposed:Boolean;
		
		
		//------------ constructor ------------//
		
		/**
		 * Create a binary tree node.
		 * 
		 * 	@param type If 0 - left branch, if 1 - right.
		 * 
		 */
		public function TreeNode(type:uint = 2)
			{

				this.type = type;		
			
			}
			
			
			//------------ initialize ------------//
			
			public function dispose():void
			{
				if(_disposed)
					return;
				_disposed = true;
				
				_right && _right.dispose(),
					_right = null;
				_left && _left.dispose(),
					_left = null;
				
				data = null;
				
				if(this.type!=2){
				
					if(!this.parent.left && this.type === 1)
						this.parent.hasChildren = false;
				
					if(!this.parent.right && this.type === 0)
						this.parent.hasChildren = false;
					
				}	

				_parent = null;
			}
			
			//--------------- ctrl ---------------//
			
											
			public function copyFrom(node:TreeNode):void
			{
				
				try{
					
					this.data = node.data.clone();
				
				}catch(e:Error){
					
					this.data = node.data;
				
				}
				
			}
			
			
			public function find(key:String):TreeNode{
				
				if(key.length<this.key.length)
					return null;
				
				if(key.length === this.key.length)
					return (key === this.key) ? this : null;
				
				
				
				key = key.substr(this.key.length);
				
				var _node:TreeNode = this;
				var i:int = 0;
				
				while(_node.hasChildren && i < key.length)
				{
						if(key.charAt(i) === "0")
							_node = _node.left;
						else
							_node = _node.right;
						i++;
				}
			
			
				return _node;
			
			}
				
			
			/**
			 *  
			 * Add a new node with <i>data</i>.
			 * 
			 * 
			 * 
			 * @param to key of the parent node
			 * @param where specifies the branch of node added (0 - left, 1 - right)
			 * @param data 
			 * 
			 * 
			 * @return <i>true</i> if succesful, <i>false</i> otherwise. 
			 */ 
			
			
			public function add(to:String,  where:uint = 0, data:* = false):Boolean{
				
				
				var _p:TreeNode = this.find(to);
				
				if(!_p)
					return false;
				
				if(_p.hasChildren)
					return false;
				
				var _old:TreeNode = new TreeNode((where === 0) ? 1 : 0);
				_old.copyFrom(_p);
				
				
				var _node:TreeNode = new TreeNode(where);
				_node.data = data;
				
				if(where === 0){
					_p.left = _node;
					_p.right = _old;
				}else{
					_p.right = _node;
					_p.left = _old;
				}
				
				return true;
			}
			
			
			/**
			 *  
			 * Remove a node with key <i>key</i>.
			 * 
			 * 
			 * 
			 * @param key key of the node removed
			 * 
			 * 
			 * @return <i>true</i> if succesful, <i>false</i> otherwise. 
			 */ 
			
			
			public function remove(key:String):Boolean{
				
				
				var _p:TreeNode = this.find(key);
				
				if(!_p)
					return false;
				
								
				if(_p.type === 2){					
					_p.dispose();
					return true;
				}
				
				var neighbour:TreeNode;
				
				if(_p.type === 0){
					neighbour = _p.parent.right;
				}else{
					neighbour = _p.parent.left;
				}
				
				
				if(_p.parent.type != 2){
				
					if(_p.parent.type === 0)
						_p.parent.parent.left = neighbour; 
					else
						_p.parent.parent.right = neighbour; 
				
				}else{
					
					
					_p.parent.copyFrom(neighbour);
					_p.parent.left = neighbour.left;
					_p.parent.right = neighbour.right;
				}
				
				_p.dispose();
				
				return  true;
			}
			
			
			public function update_keys():void
			{
				if(!this.hasChildren)
					return;
				
				this.left.key = this.key+"0";
				this.right.key = this.key+"1";
				
				this.right.update_keys();
				this.left.update_keys();
				
			}
			
			
			//------------ get / set -------------//
			
			public function get right():TreeNode
			{
				return _right;
			}
			
			public function set right(value:TreeNode):void
			{
				_right = value;
				if(value){
					value.type = 1;
					value.parent = this;
					value.key = this.key+"1";
					this.hasChildren = true;
					value.update_keys();
					
				}else if(!this.left)
					this.hasChildren = false;
					
				
			}
			
			public function get left():TreeNode
			{
				return _left;
			}
			
			public function set left(value:TreeNode):void
			{
				_left = value;
				if(value){
					value.type = 0;
					value.parent = this;
					value.key = this.key+"0";
					this.hasChildren = true;
					value.update_keys();
						
				}else if(!this.right)
					this.hasChildren = false;
				
			}
			
			public function get parent():TreeNode
			{
				return _parent;
			}
			
			public function set parent(value:TreeNode):void
			{
				_parent = value;
				
			}
			
			
			
			
			public function get disposed():Boolean
			{
				return _disposed;
			}
			
			//------- handlers / callbacks -------//
				
			
			//------- tracers / converters -------//
			
						
			public function toString():String
			{
				var result:String = '';
				
				var right:Boolean = false;
				
				var flag:Boolean = true;
				
				var _node:TreeNode = this; 
				
				
				
				
				if(!this.hasChildren)
					return ('| ' + _node.key + ' |\t(' + _node.data.toString() + ')');
				
				cycle:while(flag)
				{ 
					if(!right)
						_node = _node.left;
					else
						_node = _node.right;
					
					
					if(!_node.hasChildren)
					{
						result += '\n' + fill('--',_node.key.length) + '|' +  _node.key + ' |\t(' + _node.data.toString() + ')';
						
						if(right)
						{
							while(_node.type === 1){
								_node = _node.parent;
							}
							
							if(_node.type === 2)
								flag = false;	
							else{
								_node = _node.parent;
							}
						}
						else
						{
							_node = _node.parent;
							right = true;
						}
						
					}
					else
					{
						result += '\n' + fill('--',_node.key.length) + '|' + '[ ' + _node.key + ' ]';
						right = false;	
					}
				}
				
				function fill(symbol:String, num:uint):String
				{
					var result:String = '';
					while(result.length < num)
						result += symbol;
					return result;
				}
				
				return result;
			}
			
			public function toXML():XML
			{
				var deep:int = 0;
				var right:Boolean = false;
				var flag:Boolean = true;
				
				var _node:TreeNode = this; 
				
				const _x:XML = <layout></layout>;
				
				var current_key:String = '';
				
				if(!_node.hasChildren){
				
					item = <element />;
					
					item.@key = _node.key;
					item.@type = _node.type;
					item.@hasChildren = _node.hasChildren;
					
					_x.appendChild(item);
					
					return _x;
				}
					
				
				var item:XML;
				
				while(flag && deep > -1)
				{ 
					
					if(!right)
						_node = _node.left;
					else
						_node = _node.right;
					
					deep++;	
					
					if(!_node.hasChildren)
					{
						
						item = <element />;
						
						item.@key = _node.key;
						item.@type = _node.type;
						item.@hasChildren = _node.hasChildren;
						
						if(current_key == '')
							_x.appendChild(item);
						else
							_x..group.(@key == current_key).appendChild(item);
						
						
						if(right)
						{
							while(_node.type === 1)
							{
								_node = _node.parent;
								deep--;
							}
							
							if(_node.type === 2)
								flag = false;	
							else
							{
								_node = _node.parent;
								current_key = _node.key;
								deep--;
							}
						}
						else
						{
							_node = _node.parent;
							
							right = true;
							deep--;
						}
					}
					else
					{
						item = <group />;
						
						item.@key = _node.key;
						item.@type = _node.type;
						item.@hasChildren = _node.hasChildren;
						if(current_key == '')
							_x.appendChild(item);
						else
							_x..group.(@key == current_key).appendChild(item);
						
						current_key = _node.key;
						right = false;	
					}
				}
				return _x;
			}
			
			
			
			
			public function clone():TreeNode
			{
				var _rootNode:TreeNode = new TreeNode();
				_rootNode.copyFrom(this);
				
				if(!this.hasChildren)
					return _rootNode;
				
				var flag:Boolean = true;
				var deep:int = 0;
				
				var right:Boolean = false;
				var p:TreeNode = _rootNode;
				var _node:TreeNode = this;
				
				var _newNode:TreeNode;
				
				while(flag && deep > -1)
				{
					if(!right)
						_node = _node.left;
					else
						_node = _node.right;
					
					deep++;	
					
					_newNode = new TreeNode();
					_newNode.copyFrom(_node);
					if(_node.type === 0)
						p.left = _newNode;
					else
						p.right = _newNode;
					
					if(!_node.hasChildren)
					{
						
						if(right)
						{
							while(_node.type === 1)
							{
								_node = _node.parent;
								p = p.parent;
								deep--;
							}
							
							if(_node.type === 2)
								flag = false;	
							else
							{
								_node = _node.parent;
								deep--;
							}
						}
						else
						{
							_node = _node.parent;
							
							right = true;
							deep--;
						}
					}
					else
					{
						p = _newNode;								
						right = false;	
					}
				}
				
				return _rootNode;
			}
			
			
			
			
	}
	}