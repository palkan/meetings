package ru.teachbase.layout
{
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import flash.geom.Rectangle;

import ru.teachbase.behaviours.dragdrop.DragDirection;
import ru.teachbase.utils.LayoutUtils;
import ru.teachbase.utils.data.Stack;
import ru.teachbase.utils.data.TreeNode;


/**
	 * @author Webils (2012)
	 */
	
	public class LayoutController
	{
		
		protected const bordersDelta:int = 25;
		
		protected var _model:LayoutModel;
		protected var _container:DisplayObjectContainer;
		protected var _gap:int = 4;
		protected var _initialized:Boolean = false;
		
		protected var _width:int = 0;
		protected var _height:int = 0;
		
		
		protected const minHeight:int = 150;
		protected const minWidth:int = 170;
		
		
		protected const contMinWidth:int = 800;
		protected const contMinHeight:int = 557;
		
		
		protected var _minW:int = 100;
		protected var _minH:int = 120;
		
		
		/**
		 * When model is not active, updateDisplayList() is blocked.
		 */
		
		protected var _active:Boolean = false;
		
		protected var _expanded:Boolean = false;
		
		protected var _expandedTarget:ITreeLayoutElement;
		
		protected var currentModel:LayoutModel;
		protected var virtualModel:LayoutModel;
		
		protected var _useVirtual:Boolean = false;
		
		public var maxId:int = 0;

        private var _resizers:Object;
		
		
		public function LayoutController()
		{
		}
		
		
		
		/**
		 * 
		 *  Create model (tree) from data elements.
		 * 
		 * 
		 */

		public function preinit(elements:Array = null):void{
			
			_model = new LayoutModel();			
			
			currentModel = _model;
			
			if(elements && elements.length>0)
				_model.from_arr(elements);
			else
				_model.init(null);
		}
		
		
		/**
		 * 
		 * initializes preinited element and adds it to the container
		 * 
		 * 
		 */
		
		public function initElement(element:ITreeLayoutElement):Boolean{
			
			if(currentModel.elements[element.elementID] == undefined){
				currentModel.elements[element.elementID] = element;
				maxId = (maxId < element.elementID) ? element.elementID : maxId;
				return true;
			}
			
			return false;
						
		}
		
		
		
		/**
		 * 
		 * Assigns container to the controller
		 */

		public function init(container:DisplayObjectContainer):void{
			_initialized = true;
            _active = true;
            _container = container;
		}
		
		
		
		protected function initResizer(groupKey:String,l:uint,width:int,height:int,x:int,y:int, rw:int, rh:int):void{
            var _r:ResizerModel;
            if(_resizers[groupKey] == undefined){
                _r = new ResizerModel(groupKey);
                _r.dragBounds = new Rectangle();
                _resizers[groupKey] = _r;
            }

            _r = _resizers[groupKey] as ResizerModel;
            _r.direction = l;
            _r.gap = 2*_gap;
            _r.param = (l === 0) ? height : width;
            _r.groupParam = (l === 1) ? height : width;
            _r.position = new Point(x,y);

            var _y:int = y;
            var _x:int = x;
            var _w:int = width;
            var _h:int = height;

            if(l===1){
                _w = 0;
                _y = (height - rh>_minH) ? y-(height - rh)+_minH : y;
                _h = (rh >_minH) ? (rh -_minH) + (y - _y) : (y - _y);
            }else{
                _h = 0;
                _x = (width - rw > _minW) ? x - (width - rw)+_minW : x;
                _w = (rw > _minW) ? (rw - _minW) + (x - _x) : (x - _x);
            }

            _r.dragBounds.setTo(_x, _y, _w, _h);
		}

		
		public function resize(key:String,delta:int):void
		{
			useVirtual = true;
			currentModel.resize_group(key,delta);
			updateDisplayList();
		}
		
		public function autoAddElement(element:ITreeLayoutElement):void{

			var maxS:int = 1;
			var maxEl:ITreeLayoutElement;
			
			for each (var el:ITreeLayoutElement in currentModel.elements){
				
				if(maxS < el.width * el.height){
					maxS  = el.width * el.height;
					maxEl = el;
				}
				
			}

			// calculate drop direction
			var dir:uint;
		
			if(maxEl && maxEl.width > maxEl.height)
				dir = DragDirection.LEFT;
			else
				dir = DragDirection.UP;

			useVirtual = true;
			addElement(element,maxEl,dir);
		}
		
		
		
		
		
		/**
		 * 
		 * Adds element to the model
		 * 
		 * @param element instance to add
		 * @param elementTo dropholder instance
		 * @param direction direction of drop (DragDirection.RIGHT | DragDirection.LEFT | DragDirection.DOWN | DragDirection.UP)
		 *
		 * @see getElementUnderPoint
		 * 
		 */
		
		
		
		public function addElement(element:ITreeLayoutElement,elementTo:ITreeLayoutElement,direction:uint):void{
			
			var layout:uint = 0;
			var index:uint = 0;
			
			
			switch(DragDirection.getNameByValue(direction)){
				
				case "up":
					layout = 1;
					break;
				case "down":
					layout = 1;
					index = 1;
					break;
				case "right":
					index = 1;
					break;
				default:
					break;
				
			}
			
			var w:int = 100;
			var h:int = 100;
			
			if(layout === 0)
				w = 50;
			else
				h = 50;
			
			
			var	_data:LayoutElementData = new LayoutElementData(w,h,element.elementID,layout);
			if(currentModel.num === 0)
				currentModel.init(_data);
			else if(elementTo.elementID === 0){
				currentModel.addAbove(_data,index,layout);
				if(layout === 0)
					_data.width = 25;
				else
					_data.height = 35;
			}else
				currentModel.add(elementTo.layoutIndex,_data,index,layout);
			
			if(initElement(element)){
				if(useVirtual)
					_model.elements[element.elementID] = element;
            }

			element.visible = true;
			updateDisplayList();
		}
		

		/** Removes element from the model and (if not <i>weak</i>) from the container.'
		 * 
		 * @param element element to remove
		 * @param weak if <i>false</i> then element will be removed from the container;  otherwise not. Use <i>true</i> when dragging modules.
		 */
		
		public function removeElement(element:ITreeLayoutElement, weak:Boolean = true):void{
			if(_expandedTarget == element) _expanded = false;		

			currentModel.remove(element.layoutIndex);
			element.visible = false;
			if(!weak){
				element.active = false;
				delete currentModel.elements[element.elementID];
			}
			
			updateDisplayList();
						
		}
		
		
		public function removeFromLayout(element:ITreeLayoutElement):void{
			useVirtual = true;
			removeElement(element,false);
		}
		
		
		private function removeByID(id:uint):void{
			if(!exists(id))
				return;
			removeElement(currentModel.elements[id],false);
		}
		
		
		private function move(from:uint,to:uint,layout:uint,index:uint):void{
			
			if(!exists(from) || !exists(to))
				return;
			
			var fromElement:ITreeLayoutElement = currentModel.elements[from] as ITreeLayoutElement;

			var data:LayoutElementData = currentModel.tree.find(fromElement.layoutIndex).data as LayoutElementData;
				
			currentModel.remove(fromElement.layoutIndex);
			updateDisplayList();
			

			var toElement:ITreeLayoutElement = currentModel.elements[to] as ITreeLayoutElement;
			
			data.height = 100;
			data.width = 100;
			data.layout = layout;
			if(layout === 0)
				data.width = 50;
			else
				data.height = 50;
			
			if(to === 0)
				currentModel.addAbove(data,index,layout);
			else
				currentModel.add(toElement.layoutIndex,data,index,layout);
			
			updateDisplayList();
		}
		
		
		/** Expand module
		 * 
		 * @param module 
		 * 
		 */
		
		public function expand(element:ITreeLayoutElement):void{
			
			if(_expanded)
				return;
			
			_expandedTarget = element;
			
			_expanded = true;

			updateDisplayList();
		}
		
		
		
		private function expandByKey(key:String):void{
			var data:LayoutElementData = currentModel.tree.find(key).data as LayoutElementData;
			data && expand(currentModel.elements[data.id]);
		}
		
		
		/** Minimize expanded module
		 * 
		 * @param module
		 * 
		 */
		
		public function minimize(module:ITreeLayoutElement):void{
			
			if(!_expanded || (_expandedTarget != module))
					return;
			
			_expanded = false;
			
			updateDisplayList();
		}
		
		
		private function minimizeByKey(key:String):void{
			var data:LayoutElementData = currentModel.tree.find(key).data as LayoutElementData;
			data && minimize(currentModel.elements[data.id]);
		}
		
		

		/**
		 * Returns element under point and direction of drop.
		 * 
		 * @param pt Point
		 * 
		 * @return Object({direction:DragDirection.LEFT|RIGHT|UP|DOWN, element:IModuleInstance})
		 * 
		 */ 
		
		
		public function getElementUnderPoint(pt:Point):Object{
			
			
			if(this.currentModel.num <= 0)
				return null;
			
			var target:ITreeLayoutElement;
			var direction:uint;

			if(this.currentModel.num === 1)
			{
				target = getElementById((this.currentModel.tree.data as LayoutElementData).id);
				direction = getDropDirection(pt.x,pt.y,_container.width/2,_container.height/2,_container.width,_container.height);
				return {element:target,direction:direction};
			}
			
			if(pt.x < bordersDelta || pt.y < bordersDelta || _container.width - pt.x < bordersDelta || _container.height - pt.y < bordersDelta){
				direction = getDropDirection(pt.x,pt.y,_container.width/2,_container.height/2,_container.width,_container.height);
				return {element:_container,direction:direction};
			}
			
			var x:int = 0;
			var y:int = 0;
			var right:Boolean = false;
			var width:int = 1;
			var height:int = 1;
			var flag:Boolean = true;
			
			var _node:TreeNode = this.currentModel.tree.left; 
			
			width = _container.width+_gap;
			height = _container.height+_gap;
			
			while(flag)
			{ 
				if(pt.x > x + width * ((_node.data as LayoutElementData).width / 100) || pt.y > y + height * ((_node.data as LayoutElementData).height / 100))
				{
					if((_node.parent.data as LayoutElementData).layout === 1)
						y+= height * ((_node.data as LayoutElementData).height / 100) + _gap;
					else	
						x+= width * ((_node.data as LayoutElementData).width / 100) + _gap;
					
					_node = _node.parent.right;
				}
				
				if(!_node.hasChildren)
				{
					
					target = getElementById((_node.data as LayoutElementData).id);
					width = width * ((_node.data as LayoutElementData).width / 100);
					height = height * ((_node.data as LayoutElementData).height / 100);
					direction = getDropDirection(pt.x, pt.y, x + width/2, y + height/2, width, height);

					if( (direction === DragDirection.LEFT || direction === DragDirection.RIGHT) && target.width/2 < (this.width / contMinWidth) * minWidth
						||
						(direction === DragDirection.UP || direction === DragDirection.DOWN) && target.height/2 < (this.height / contMinHeight) * minHeight
						)
						return null;

					return {element:target,direction:direction};
				}
				else
				{
					width*=((_node.data as LayoutElementData).width / 100);
					height*=((_node.data as LayoutElementData).height / 100);
					_node = _node.left;
				}
			}
			
			return null;
		}

		
		public function updateDisplayList():void
		{
			if(this.currentModel.num <= 0 || !this.active)
				return;
			
			
			this.height = _container.height;
			this.width = _container.width;
			
			
			_minW = minWidth * (this.width / contMinWidth);
			_minH = minHeight * (this.height / contMinHeight);

			if(_expanded){
				_expandedTarget.setLayoutBoundsPosition(0,0);
				_expandedTarget.setLayoutBoundsSize(_container.width,_container.height);
				return;
			}

			
			var target:ITreeLayoutElement;
			
			if(this.currentModel.num === 1)
			{
				target = getElementById((this.currentModel.tree.data as LayoutElementData).id);
				if(!target)
					return;
				target.setLayoutBoundsPosition(0,0);
				target.setLayoutBoundsSize(_container.width,_container.height);
				target.layoutIndex = "";
				return;
			}
			
			
			var x:int = 0;
			var y:int = 0;
			var right:Boolean = false;
			var flag:Boolean = true;
			var l:uint = 0;
			var paramsStack:Stack = new Stack();

			var _node:TreeNode = this.currentModel.tree; 
			
			width = _container.width+_gap;
			height = _container.height+_gap;
			
			paramsStack.pushObj(width,height);
			
			while(flag)
			{ 
				l = (_node.data as LayoutElementData).layout;
				
				if(!right){
					_node = _node.left;
					width = LayoutUtils.accuratePercentMultiply(width,(_node.data as LayoutElementData).width);
					height = LayoutUtils.accuratePercentMultiply(height,(_node.data as LayoutElementData).height);
				}else{
					
					initResizer(
						_node.key
						,(_node.data as LayoutElementData).layout 
						,width
						,height
						,x - (1 - (_node.data as LayoutElementData).layout)*_gap*1.5
						,y - (_node.data as LayoutElementData).layout*_gap*1.5
						,width*((_node.right.data as LayoutElementData).width / 100)
						,height*((_node.right.data as LayoutElementData).height / 100)
					);
					
					_node = _node.right;
					width*=((_node.data as LayoutElementData).width / 100);
					height*=((_node.data as LayoutElementData).height / 100);
				}	
				
				
				
				paramsStack.pushObj(width,height);
				
				
				if(!_node.hasChildren)
				{
					target = getElementById((_node.data as LayoutElementData).id);
					if(!target)
						return;
					target.layoutIndex = _node.key;
					target.setLayoutBoundsPosition(x,y);
					target.width = width - _gap;
					target.height = height - _gap;

					var tempObj:Object = paramsStack.pop();
					
					
					if(right)
					{	
						x+=width;
						y += height;

						while(_node.type === 1)
						{
							tempObj = paramsStack.pop();
							_node = _node.parent;
						}
						
						if(_node.type === 2)
							flag = false;	
						else
						{
							var tempW:int = tempObj.width;
							var tempH:int = tempObj.height;
							width  = paramsStack.top().width; 
							height = paramsStack.top().height;
							_node = _node.parent;
							
							if((_node.data as LayoutElementData).layout === 0)
								y-=	tempH;						
							else
								x-= tempW;
							
						}
					}
					else
					{
						if(l === 1)
							y+=height;
						else	
							x+=width;
						
						width  = paramsStack.top().width; 
						height = paramsStack.top().height; 
						_node = _node.parent;
						right = true;
					}
				}
				else
					right = false;	
			}
			
		}
		
		
		private function getDropDirection(x:int, y:int, x2:int, y2:int, w:int, h:int):uint
		{
			
			var pt:Point = new Point();
			
			pt.x = h*(x - x2) - w*(y - y2);
			pt.y = w*(x - x2) + h*(y - y2);
			
			
			if(pt.x>0 && pt.y>0)
				return DragDirection.RIGHT;
			
			if(pt.x>0 && pt.y<0)
				return DragDirection.UP;
			
			if(pt.x<0 && pt.y>0)
				return DragDirection.DOWN;
			
			if(pt.x<0 && pt.y<0)
				return DragDirection.LEFT;
			
			
			return null;
		}		
		
		private function getElementById(id:int):ITreeLayoutElement{
			
			return (currentModel.elements[id]!=undefined) ? currentModel.elements[id] : null;
			
		}
		
		

		private function exists(id:uint):Boolean{
			return !(currentModel.elements[id] == undefined) || !id;
		}
		
		
		
		public function get width():int
		{
			return _width;
		}

	
		public function get height():int
		{
			return _height;
		}

		
		public function get model():LayoutModel
		{
			return _model;
		}

		public function set width(value:int):void
		{
			_width = value;
		}

		public function set height(value:int):void
		{
			_height = value;
		}

		public function get initialized():Boolean
		{
			return _initialized;
		}

		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			_active = value;
		}

		public function get useVirtual():Boolean
		{
			return _useVirtual;
		}

		public function set useVirtual(value:Boolean):void
		{
			
			if(_useVirtual === value)
				return;
			
			if(value){
				virtualModel = _model.clone();
				currentModel = virtualModel;
			}else{
				currentModel = _model;
				virtualModel.dispose();
				virtualModel = null;
				updateDisplayList();
			}
			
			_useVirtual = value;
		}

    public function get resizers():Object {
        return _resizers;
    }
}
}
