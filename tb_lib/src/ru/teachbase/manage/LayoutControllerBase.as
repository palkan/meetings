package ru.teachbase.manage
{
import flash.geom.Point;

import ru.teachbase.behaviours.DragDirection;
import ru.teachbase.behaviours.interfaces.IDraggle;
import ru.teachbase.events.LayoutEvent;
import ru.teachbase.layout.ITreeLayoutElement;
import ru.teachbase.model.LayoutChangeData;
import ru.teachbase.model.LayoutElementData;
import ru.teachbase.model.LayoutModel;
import ru.teachbase.model.constants.Recipients;
import ru.teachbase.module.base.IModule;
import ru.teachbase.module.base.IModuleContent;
import ru.teachbase.module.base.IModulePanel;
import ru.teachbase.traits.LayoutTrait;
import ru.teachbase.utils.LayoutUtils;
import ru.teachbase.utils.Logger;
import ru.teachbase.utils.data.Stack;
import ru.teachbase.utils.data.TreeNode;

import spark.components.Group;

/**
	 * @author Webils (2012)
	 */
	
	public class LayoutControllerBase
	{
		
		protected const bordersDelta:int = 25;
		
		protected var _model:LayoutModel;
		protected var _manager:LayoutModelManagerBase;
		protected var _container:Group;
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
		
		protected var _trait:LayoutTrait;
		
		protected var currentModel:LayoutModel;
		protected var virtualModel:LayoutModel;
		
		protected var _useVirtual:Boolean = false;
		
		protected var _fixed:Boolean = false;
		
		public var maxId:int = 0;
		
		
		public function LayoutControllerBase(manager:LayoutModelManagerBase)
		{
			_manager = manager;
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
				_container.addElementAt(element,0);
				
				maxId = (maxId < element.elementID) ? element.elementID : maxId;
				
				return true;
			}
			
			return false;
						
		}
		
		
		
		/**
		 * 
		 * Assigns container to the controller
		 */
		
		
		public function init(container:Group):void{
			
			
			_container = container;
			_initialized = true;
			_active = true;
			
			new LayoutChangeData();

			_trait.addEventListener(LayoutEvent.CHANGE,onLayoutChanged);
			_trait.readyToReceive = true;
		}
		
		
		
		protected function initResizer(groupKey:String,l:uint,width:int,height:int,x:int,y:int, rw:int, rh:int):void{
			// TODO Not Implemented
		}
		
		
		
		protected function hideResizers():void{
			// TODO Not Implemented
		}
		
		
		public function resize(key:String,delta:int):void
		{
			
			useVirtual = true;
			
			currentModel.resize_group(key,delta);
			
			_trait.output({type:"resize", key:key,d:delta},Recipients.ALL);
			
			updateDisplayList();
			
		}		
		
		
		protected function onLayoutChanged(event:LayoutEvent):void
		{
			
			Logger.log("onLayoutChanged: "+_useVirtual+"; type: "+event.data.type,'layout');
			
			
			if(_useVirtual)
				cancelLocalUncommitedChanges();
			
			useVirtual = false;
			
			switch(event.data.type){
				
				case "move":
					move(event.data.from,event.data.to,event.data.l,event.data.i);
				break;
				case "resize":
					currentModel.resize_group(event.data.key,event.data.d);
					updateDisplayList();
				break;
				
				case "add":
					addElementExternal(event.data.from,event.data.to,event.data.data,event.data.i,event.data.l);
				break;
				
				case "remove":
					removeByID(event.data.from);
				break;
				case "restart":
					restartByID(event.data.from,event.data.data);
				break;
				case "module_click":
					prepareAutoAdd(event.data.data.content[0].module);
				break;
				default:
				break;				
			}
			
			
			
		}		
		
		protected function cancelLocalUncommitedChanges():void
		{
			// TODO Not Implemented
		}		
		
		protected function restartByID(id:int,data:LayoutElementData):void{
			// TODO Not Implemented
		}
		
		protected function createNewElement(module:IModule):ITreeLayoutElement{
			// TODO Not Implemented
			return null; 
		}
		
		private function prepareAutoAdd(module:IModule):void{
			
			
			// create element
			
			var element:ITreeLayoutElement = createNewElement(module);

			
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
			
			addElement(element,maxEl,dir,false,false,[{module:module.moduleID, id:element.elementID}]);
			
			
			
		}
		
		
		
		
		
		/**
		 * 
		 * Adds element to the model and (if it is necessary) to the container
		 * 
		 * @param element instance to add
		 * @param elementTo dropholder instance
		 * @param direction direction of drop (DragDirection.RIGHT | DragDirection.LEFT | DragDirection.DOWN | DragDirection.UP)
		 * @param priv privacy of the model
		 * @param from true if comand received from server message
		 * 
		 * @see getElementUnderPoint
		 * 
		 */
		
		
		
		public function addElement(element:ITreeLayoutElement,elementTo:ITreeLayoutElement,direction:uint,priv:Boolean = false,from:Boolean = false,content:Array = null):void{
			
			
			Logger.log("addElement: "+_useVirtual+"; id: "+element.elementID,'layout');
			
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
			
			
			var	_data:LayoutElementData = new LayoutElementData(w,h,element.elementID,priv,layout,content);
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
				_trait.output({type:"add",to:elementTo ? elementTo.elementID : -1,from:element.elementID,l:layout,i:index,data:_data},Recipients.ALL);
				if(useVirtual)
					_model.elements[element.elementID] = element;
			}else{
				_trait.output({type:"move",to:elementTo ? elementTo.elementID : -1,from:element.elementID,l:layout,i:index},Recipients.ALL);		
			}
				
			element.visible = true;
			updateDisplayList();
		}
		
		
		
		
		
		
		
		protected function addElementExternal(elementID:uint, elementTo:uint, data:LayoutElementData,index:uint,layout:uint):void{
			
			if(!exists(elementTo) && model.num>0)
				return;
			
			var element:IModulePanel;
			
			if(!exists(elementID)){
				element = createNewElement(_manager.getModule(data.content[0]["module"])) as IModulePanel;
				initElement(element);
			}else{
				element = _model.elements[elementID];
			}
			
			
			if(data.content){
				var _instance:IModuleContent = _manager.getInstanceForLayout(data.content[0]["module"],data.content[0]["id"]);
				element.content = [_instance];
				element.title = _instance.label;
				_instance.panelID = elementID;
			}
			
			if(_model.num === 0)
				_model.init(data);
			else if(elementTo === 0)
				currentModel.addAbove(data,index,layout);
			else
				_model.add((_model.elements[elementTo] as ITreeLayoutElement).layoutIndex,data,index,layout);
			
			updateDisplayList();
		}
		
		
		
		/** Removes element from the model and (if not <i>weak</i>) from the container.'
		 * 
		 * @param element element to remove
		 * @param weak if <i>false</i> then element will be removed from the container;  otherwise not. Use <i>true</i> when dragging modules.
		 * @param from true iff comand received from server message
		 */
		
		public function removeElement(element:ITreeLayoutElement, weak:Boolean = true, from:Boolean = false):void{
			if(_expandedTarget == element) _expanded = false;		
			
			
			
			currentModel.remove(element.layoutIndex);
			element.visible = false;
			if(!weak){
				element.active = false;
				delete currentModel.elements[element.elementID];
				if(!from)
					_trait.output({type:"remove",from:element.elementID},Recipients.ALL);
				if(!useVirtual){
					_container.removeElement(element);
				}
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
			
			removeElement(currentModel.elements[id],false,true);
			
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
		
		public function expand(module:ITreeLayoutElement):void{
			
			if(_expanded)
				return;
			
			_expandedTarget = module;
			
			_container.setElementIndex(module,_container.numElements-1);
			
			_expanded = true;
			
			(_expandedTarget as IDraggle).dragBehavior.active = false;
			
			//_trait.output({type:"expand",from:module.layoutIndex},Recipients.ALL_EXCLUDE_ME);	 temporary unavailable
			
			updateDisplayList();
		}
		
		
		
		private function expandByKey(key:String):void{
			
			var data:LayoutElementData = currentModel.tree.find(key).data as LayoutElementData;
			expand(currentModel.elements[data.id]);
			
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
			
			//_trait.output({type:"minimize",from:module.layoutIndex},Recipients.ALL_EXCLUDE_ME);  temporary unavailable
			
			
		}
		
		
		private function minimizeByKey(key:String):void{
			
			var data:LayoutElementData = currentModel.tree.find(key).data as LayoutElementData;
			minimize(currentModel.elements[data.id]);
			
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
				target = getModuleByData(this.currentModel.tree.data as LayoutElementData);
				
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
					
					target = getModuleByData(_node.data as LayoutElementData);
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
			
			hideResizers();
			
			if(_expanded){
				
				_expandedTarget.setLayoutBoundsPosition(0,0);
				_expandedTarget.setLayoutBoundsSize(_container.width,_container.height);
				return;
				
			}
			
			
			
			var target:ITreeLayoutElement;
			
			if(this.currentModel.num === 1)
			{
				target = getModuleByData(this.currentModel.tree.data as LayoutElementData);
				if(!target)
					return;
				target.setLayoutBoundsPosition(0,0);
				target.setLayoutBoundsSize(_container.width,_container.height);
				target.layoutIndex = "";
				(target as IDraggle).dragBehavior.active = false;
				return;
			}
			
			
			var x:int = 0;
			var y:int = 0;
			var right:Boolean = false;
			var width:int = 1;
			var height:int = 1;
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
					
					!_fixed && initResizer(
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
					target = getModuleByData(_node.data as LayoutElementData);
					if(!target)
						return;
					target.layoutIndex = _node.key;
					target.setLayoutBoundsPosition(x,y);
					target.width = width - _gap;
					target.height = height - _gap;
					(target as IDraggle).dragBehavior.active = !_fixed;
					
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
		
		private function getModuleByData(element:LayoutElementData):ITreeLayoutElement{
			
			return (currentModel.elements[element.id]!=undefined) ? currentModel.elements[element.id] : null;
			
		}
		
		
		public function getModuleById(id:int):ITreeLayoutElement{
			
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

		public function get trait():LayoutTrait
		{
			return _trait;
		}

		public function set trait(value:LayoutTrait):void
		{
			_trait = value;
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

		/**
		 * If <i>true</i> then modules are not draggable
		 */
		public function get fixed():Boolean
		{
			return _fixed;
		}

		/**
		 * @private
		 */
		public function set fixed(value:Boolean):void
		{

			if(_fixed === value)
				return;
			
			_fixed = value;
			
			_fixed && hideResizers();
			
			updateDisplayList();

		}
		
		
		
		
	}
}
