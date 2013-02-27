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
import com.adobe.flex.extras.controls.pivotComponentClasses.helperClasses.MeasuresComboBox;

import flash.events.Event;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.controls.List;
import mx.core.ClassFactory;
import mx.events.DragEvent;
import mx.managers.DragManager;
/**
 * MeasuresList displays the measures 
 * of the OLAPCube . Measures are displayed 
 * in the cells of OLAPDataGrid and as a series 
 * in the OLAPChart. 
 * 
 * <code> MeasuresList </code> is a List control
 * @mxml
 * <p>
 * 
 * The <code>&lt;fc:MeasuresList&gt;</code> inherits all the tag attributes
 * from its super classes .   
 * 
 */ 	
public class MeasuresList extends List
{
		
		
	//-----------------------------------------------------------------
	//
	// Constructor
	//
	//-------------------------------------------------------------------
		
	/**
	 * @private
	 */
		  
	public function MeasuresList():void
	{	
		this.dragEnabled=true;
		this.dropEnabled=true;
		this.dragMoveEnabled=true;
		this.itemRenderer=ComboBoxClassFactory();
		super.dataProvider=measures;
	}
		
	//------------------------------------------------------------------------
	//
	// Variables
	//
	//-----------------------------------------------------------------------
	[Bindable]
	private var measures:ArrayCollection;
	[Bindable]
	private var pivotComponent:PivotComponent;
	public  var measuresCopy:Array ;
		
	//-------------------------------------------------------------------
	// Properties
	//------------------------------------------------------------------
	/**
	 * Custom Aggregators are passed on as Array
	 */ 
		
	private var _aggregators:Array=[];
	public function set aggregators(value : Array):void
	{
			_aggregators=value;
	}
		
	private function get aggregators():Array
	{
		return _aggregators;
	}
		
				
		
	//---------------------------------------------------------------------------
	//
	// Overridden Methods
	//
	//--------------------------------------------------------------------------
	/**
	 * @private 
	 * set the measures 
	 */  
		
	private var mflag:Boolean=false;
	override public function set dataProvider(value:Object):void
	{
		measures=new ArrayCollection();
		if ((!value || value!=null) && value.length!=0)
		{
			for	(var i:int=0;i<value.length;i++)
				measures.addItem(value[i]);
			super.dataProvider=measures;
			if	(!pivotComponent)
			{
				var p:Object = this.parent;
				while (p)
				{
					if (p is PivotComponent)
					{
						pivotComponent = p as PivotComponent;
						p = null;
					}
					else
						p = p.parent;
				}
			}
		
			if (!mflag)
			{
				if (value is ArrayCollection)
					pivotComponent.facts = measures.toArray();
				if (value is Array)
					pivotComponent.facts = value as Array;
				measuresCopy = clone( measures.toArray());
				dispatchEvent(new Event("measuresChanged"));
				mflag=true;
			}
		}
	}
	
	override protected function dragOverHandler(event:DragEvent):void
	{
		var measuresArray:Array = measures.toArray();
		trace("hi");
    	if (event.dragInitiator is DimensionList )
    	{
    		 DragManager.showFeedback(DragManager.NONE);
    	}
    	if(event.dragSource.hasFormat("items"))
    	{
    		var items:Array = event.dragSource.dataForFormat("items") as Array;
    		getPivotComponent();
    		var index:int = measuresArray.indexOf(items[0]);
    		if(index != -1) DragManager.showFeedback(DragManager.NONE);
    	}
			
	}
	//--------------------------------------------------------------------------
	// 
	// Private Methods
	//
	//---------------------------------------------------------------------------
	/**
	 * @private
	 */
		 
	 private function ComboBoxClassFactory():ClassFactory
	 {
		getPivotComponent();
		var temp:ClassFactory=new ClassFactory;
		temp.generator=MeasuresComboBox;
		temp.properties={agg:_aggregators};
		return temp;
	 }	 
		
	/**
	 * @private
	 */
	 private function getPivotComponent():void
	 {
		if (!pivotComponent)
	    {
			var p:Object = this.parent;
	    	while (p)
	    	{
	    		if (p is PivotComponent)
	    		{
	    			pivotComponent = p as PivotComponent;
	    			return;
	    		}
	    		else
	    			p = p.parent;
	    	}
	    }	    	
	}
	 /**
	 * Called to reset the measuresList
	 */   
	public  function resetDp():void
	{
		this.dataProvider = measuresCopy;
	}
		
		
	private function clone(source:Object):*
	{
    	var myBA:ByteArray = new ByteArray();
    	myBA.writeObject(source);
    	myBA.position = 0;
    	return(myBA.readObject());
	}
		
}
	
}
