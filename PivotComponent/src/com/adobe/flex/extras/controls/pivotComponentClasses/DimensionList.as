///////////////////////////////////////////////////////////////////////////////////////
//  
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//   
//  NOTICE:  Adobe permits you to use, modify, and distribute this file in 
//  accordance with the terms of the Adobe license agreement accompanying it.  
//  If you have received this file from a source other than Adobe, then your use,
//  modification, or distribution of it requires the prior written permission of Adobe.
////////////////////////////////////////////////////////////////////////////////////////





package com.adobe.flex.extras.controls.pivotComponentClasses
{
	import com.adobe.flex.extras.controls.PivotComponent;
	import flash.events.Event;
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.controls.List;
	import mx.events.DragEvent;
	import mx.utils.ObjectUtil;

	/**
	 * DimensionList displays the dimensions
	 * of the OLAPCube.It can take either an ArrayCollection
	 * or an XMLListCollection
	 *
	 * The <code>&lt;fc:DimensionList&gt;</code> inherits all the tag attributes
	 * from its super classes .
	 *
	 */
	public class DimensionList extends List
	{

		public function DimensionList():void
		{
			this.dragEnabled=true;
			this.addEventListener("dragComplete", changeHandler);
			this.addEventListener(DragEvent.DRAG_DROP, dragDropHandlerFunc);
			this.addEventListener("dataChange", changeHandler);
			super.dataProvider=dimensions;
		}

		/*-------------------------------------------------------
		   //
		   // variables
		   //
		 //--------------------------------------------------------*/
		private var change:Boolean=false;


		private var dimensions:ArrayCollection;
		private var pivotComponent:PivotComponent;

		override public function set dataProvider(value:Object):void
		{
			var j:int;
			var obj:Object
			if ((!value || value != null) && (value is ArrayCollection || value is Array || value is XMLListCollection || value is XMLList))
			{
				if (value is Array)
				{
					if (Array(value).length != 0)
					{
						dimensions=new ArrayCollection();
						for (j=0; j < value.length; j++)
							dimensions.addItem(value[j]);

					}
				}
				else if (value is ArrayCollection)
				{

					if (ArrayCollection(value).length != 0)
					{
						dimensions=new ArrayCollection();
						obj=ObjectUtil.getClassInfo(value[0]);
						for (j=0; j < obj.properties.length; j++)
						{
							dimensions.addItem(obj.properties[j].localName);
						}

					}

				}

				else if (value is XMLListCollection)
				{
					if (XMLListCollection(value).length != 0)
					{
						dimensions=new ArrayCollection();
						obj=ObjectUtil.getClassInfo(value[0]);
						for (j=0; j < obj.properties.length; j++)
						{
							dimensions.addItem(obj.properties[j].localName);
						}
					}
				}

				else if (value is XMLList)
				{
					if (XMLList(value).length() != 0)
					{
						dimensions=new ArrayCollection();
						var obj2:XML=XML(value[0]);
						var obj1:XMLList=obj2.*;

						for (var j1:int=0; j1 < obj1.length(); j1++)
						{
							//	trace(String( XML(obj1[j]).localName() ));
							dimensions.addItem(String(XML(obj1[j1]).localName()));
						}
					}
				}


				if (!pivotComponent)
				{
					var p:Object=this.parent;
					while (p)
					{
						if (p is PivotComponent)
						{
							pivotComponent=p as PivotComponent;
							p=null;
						}
						else
							p=p.parent;
					}
				}
				if (pivotComponent && dimensions.length != 0)
				{
					//pivotComponent.dimensions = dimensions.toArray();
					//dispatchEvent(new Event("dimensionsChanged"));
				}
				super.dataProvider=dimensions;
			}
		}

		private function changeHandler(event:Event):void
		{
			var temp:ArrayCollection=dimensions;
		}

		private function dragDropHandlerFunc(event:DragEvent):void
		{
			trace("Drag Drop in List");
		}
	}

}
