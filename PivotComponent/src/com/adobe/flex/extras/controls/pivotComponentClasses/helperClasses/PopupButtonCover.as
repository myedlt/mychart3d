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
package com.adobe.flex.extras.controls.pivotComponentClasses.helperClasses
{
	import com.adobe.flex.extras.controls.myEvent.EnableChangeEvent;
	
	import flash.events.Event;
	
	import mx.controls.Button;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.UIComponent;
	[Event(name="selected" , type="myEvent.EnableChange")] 
	[Event(name="delete" , type="myEvent.EnableChange")] 
	public class PopupButtonCover extends UIComponent implements IDropInListItemRenderer , IListItemRenderer
	{
		public function PopupButtonCover():void
		{
			super();
			if(!popupButton)
			{
				popupButton = new PivotPopUpButton ;
				popupButton.explicitWidth = 80 ; 
				popupButton.addEventListener("selected",traceSelect);
				addChild(popupButton);		
			}
			if(!delButton)
			{
				delButton = new Button();
				delButton.setStyle("icon",imgClass);
				delButton.addEventListener("click", deleteDimension ) ;
				addChild(delButton);
			}
		}
		public var label:String;	
		private var popupButton:PivotPopUpButton ;
		private var delButton:Button ;
		[Embed(source = "Delete_Small.png")]
		public var imgClass:Class
		
		
		private function traceSelect(event:EnableChangeEvent):void
		{
			var eventObj:EnableChangeEvent = new EnableChangeEvent("selected");
			eventObj.param = event.param ;
			eventObj.param1 = event.param1
			dispatchEvent(eventObj);
			
		}
		override protected function createChildren():void
		{
		
				
		}
		
		override protected function measure():void
		{
			super.measure();
			var popupwidth:Number = popupButton.getExplicitOrMeasuredWidth();
			var popupHeight:Number = popupButton.getExplicitOrMeasuredHeight();
		
			measuredMinWidth = measuredWidth = popupwidth +  34;
			measuredHeight = popupHeight;
		}
	
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			delButton.minWidth = 30 ;
			popupButton.setActualSize(unscaledWidth - 34,unscaledHeight);
			delButton.setActualSize(30,unscaledHeight);
			
			delButton.move(popupButton.width +2 , 0);
		}
		
		override protected function commitProperties():void
		{
			label = popupButton.label ; 
			super.commitProperties();
		}
		
		
		private var _listData:BaseListData ;
		
		public function get listData():BaseListData
		{
			
			return _listData;
		}
		
		public function set listData(value:BaseListData):void
		{
			_listData = value ;
			popupButton.listData = listData 	
		}
		
		private var _data:Object
		public function set data(value:Object):void
		{
			_data = value;
		}
		public function get data():Object
		{
			return _data;
		}
		private function deleteDimension(event:Event):void
		{
			var eventObj:EnableChangeEvent = new EnableChangeEvent("delete");
			eventObj.param = this.label ;
			dispatchEvent(eventObj);
		}
	}
}