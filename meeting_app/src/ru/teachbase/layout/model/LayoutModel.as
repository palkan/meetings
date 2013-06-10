package ru.teachbase.layout.model
{
import ru.teachbase.utils.data.TreeNode;

/**
	 * @author Webils (2012)
	 */
	public class LayoutModel
	{
				
		
		private var _tree:TreeNode;
		
		private var _initialized:Boolean = false;
		
		public var num:int = 0;
		
		private var _disposed:Boolean = false;
		
		private var _elements:Object = {};
		
		//------------ constructor ------------//
		
		/**
		 * Create a layout model containing a binary tree.
		 * 
		 * 
		 */
		
		
		public function LayoutModel()
		{
			
			
			
		}
		
		
		public function dispose():void{
			if(_disposed)
				return;
			
			this.tree.dispose();
			
			_elements = null;
			
			_disposed = true;
		}
		
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		
		
		public function init(data:LayoutElementData):void{
			
			_tree = new TreeNode();
			_tree.data = data;
			
			_initialized = true;
			
			if(data)
				num=1;
			
		}
		
		
		
		
		/**
		 *  Add new element to layout model.
		 * 
		 * @param to dropspace element index
		 * @param data data
		 * @param where position of new element (0 or 1) 
		 * @param layout layout of new created group
		 * 
		 */ 
		
		
		
		public function add(to:String, data:LayoutElementData, where:uint = 0,layout:uint = 0):void{
			
			var _to:TreeNode = _tree.find(to);
			
			_tree.add(to,where,data);
			
			(_to.data as LayoutElementData).layout = layout;
			
			_to = (where === 0) ? _to.right : _to.left;
			
			(_to.data as LayoutElementData).height = (layout === 0) ? 100 : 100 - data.height;
			(_to.data as LayoutElementData).width = (layout === 1) ? 100 : 100 - data.width;
			
			num++;
			
		}
		
		
		/**
		 * Add element above all others in layout tree.
		 *  
		 * @param data
		 * @param where
		 * @param layout
		 * 
		 */		
		
		public function addAbove(data:LayoutElementData, where:uint = 0,layout:uint = 0):void{
			
			var _newRoot:TreeNode = new TreeNode();
			
			_newRoot.add("",where,data);
			_newRoot.data = new LayoutElementData();
			(_newRoot.data as LayoutElementData).layout = layout;
			
			var _to:TreeNode;
			
			if(where === 0){
				_newRoot.right = _tree;
				_to = _newRoot.right;
			}else{
				_newRoot.left = _tree;
				_to = _newRoot.left;
			}
			
			if(layout === 0)
				data.width = 25;
			else
				data.height = 35;
			
		
			(_to.data as LayoutElementData).height = (layout === 0) ? 100 : 100 - data.height;
			(_to.data as LayoutElementData).width = (layout === 1) ? 100 : 100 - data.width;
			
			
			_tree = _newRoot;
			
			num++;
			
		}		
		
		/**
		 * remove element from model
		 * 
		 * @param key key of the element
		 */
		
		
		public function remove(key:String):void{
			
			
			var _node:TreeNode = _tree.find(key);
			
			
			if(_node.parent){
				var w:int = (_node.parent.data as LayoutElementData).width;
				var h:int = (_node.parent.data as LayoutElementData).height;
			}
			
			 _tree.remove(key);
			
			 
			 num--;
			 
			 if(num === 0)
				 return;
			 
			 _node = _tree.find(key.substr(0,-1));
			if(_node){
				(_node.data as LayoutElementData).width = w;
				(_node.data as LayoutElementData).height = h;
			}
			
			
		}
		
		
		/**
		 * resize a group of two nodes in model
		 * 
		 * @param key key of the group
		 * @delta delta beetween resizer's initial and final positions in percent (0 - 100). 
		*/
		
		
		public function resize_group(key:String,delta:int):void{
			
			var _node:TreeNode = _tree.find(key);
			
			if(!_node) return;
			
			if(!_node.hasChildren) return;
			
			if((_node.data as LayoutElementData).layout === 0){
				
				(_node.left.data as LayoutElementData).width+=delta;
				(_node.right.data as LayoutElementData).width-=delta;
				
			}else{
				
				(_node.left.data as LayoutElementData).height+=delta;
				(_node.right.data as LayoutElementData).height-=delta;
				
			}
			
			
		}
		
		
		//------- handlers / callbacks -------//
		
		//------- tracers / converters -------//
		
		
		
		public function  from_arr(arr:Array):void{
			
			_tree = new TreeNode();
			_tree.data = arr[0] as LayoutElementData;
			
			if(arr.length === 1)
				num=1;
			
			var p:TreeNode = _tree;
			var _node:TreeNode;
			var deep:int = 1;
			
			arr.splice(0,1);
			
			for each(var element:LayoutElementData in arr){
				
				while(deep>element.key.length){
					deep--;
					p = p.parent;
				}
			
				
				var _new:TreeNode = new TreeNode();
				_new.data = element;
				
				if(element.key.charAt(element.key.length-1) === "0")
					p.left = _new;
				else
					p.right = _new;
				
				if(element.id === 0){
					p = _new;
					deep++;
				}else{
					num++;
				}
												
			}
			
			_initialized = true;

			
		}
		
		
		
		
		
		
		public function toXML():XML
		{
			var deep:int = 0;
			var right:Boolean = false;
			var flag:Boolean = true;
			
			var _node:TreeNode = _tree; 
			
			const _x:XML = <layout></layout>;
			
			var current_key:String = '';
			
			if(!_node.hasChildren){
				
				item = <element />;
				
				item.@width = (_node.data as LayoutElementData).width;
				item.@height =  (_node.data as LayoutElementData).height;
				item.@key = _node.key;
				item.@type = _node.type;
				item.@hasChildren = _node.hasChildren;
				item.@instance = (_node.data as LayoutElementData).id;

				_x.appendChild(item);
				
				return _x;
			}
			
			_x.@width = (_node.data as LayoutElementData).width;
			_x.@height = (_node.data as LayoutElementData).height;
			_x.@layout = (_node.data as LayoutElementData).layout;
			_x.@type = _node.type;
			_x.@hasChildren = _node.hasChildren; 
			
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
					
					item.@width = (_node.data as LayoutElementData).width;
					item.@height = (_node.data as LayoutElementData).height;
					item.@instance = (_node.data as LayoutElementData).id;
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
					
					item.@width = (_node.data as LayoutElementData).width;
					item.@height = (_node.data as LayoutElementData).height;
					item.@key = _node.key;
					item.@type = _node.type;
					item.@layout = (_node.data as LayoutElementData).layout;
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
		
		
		
		public function clone():LayoutModel{
			
			var _model:LayoutModel = new LayoutModel();
			_model.tree = this.tree.clone();
			_model.num = this.num;
			_model.elements = {};
			for (var key:String in this.elements)
				_model.elements[key] = this.elements[key];
			
			return _model;
			
		}
		
		
		//------------ get / set -------------//

		public function get tree():TreeNode
		{
			return _tree;
		}

		public function set tree(value:TreeNode):void
		{
			_tree = value;
		}

		public function get elements():Object
		{
			return _elements;
		}

		public function set elements(value:Object):void
		{
			_elements = value;
		}

		
	}
}