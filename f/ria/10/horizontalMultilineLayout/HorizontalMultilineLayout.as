package
{
import flash.geom.Point;

import mx.core.ILayoutElement;

import org.osmf.layout.PaddingLayoutFacet;

import spark.components.supportClasses.GroupBase;
import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalAlign;
import spark.layouts.supportClasses.LayoutBase;

/**
 * Lays out elements the same way as text area positions words: putting them in
 * one line and going to next line when there is no space for new word.
 */
public class HorizontalMultilineLayout extends LayoutBase
{
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var lastWidth:Number = -1;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  horizontalGap
	//----------------------------------
	
	private var _horizontalGap:Number = 6;
	
	public function get horizontalGap():Number
	{
		return _horizontalGap;
	}
	
	public function set horizontalGap(value:Number):void
	{
		if (value == _horizontalGap)
			return;
		
		_horizontalGap = value;
		invalidateTargetSizeAndDisplayList();
	}
	
	//----------------------------------
	//  verticalGap
	//----------------------------------
	
	private var _verticalGap:Number = 6;
	
	public function get verticalGap():Number
	{
		return _verticalGap;
	}
	
	public function set verticalGap(value:Number):void
	{
		if (value == _verticalGap)
			return;
		
		_verticalGap = value;
		invalidateTargetSizeAndDisplayList();
	}
	
	//----------------------------------
	//  verticalAlign
	//----------------------------------
	
	private var _verticalAlign:String = VerticalAlign.TOP;
	
	[Inspectable(category="General", enumeration="top,bottom,middle", defaultValue="top")]
	public function get verticalAlign():String
	{
		return _verticalAlign;
	}
	
	public function set verticalAlign(value:String):void
	{
		if (_verticalAlign == value)
			return;
		
		_verticalAlign = value;
		invalidateTargetSizeAndDisplayList();
	}
	
	//----------------------------------
	//  paddingLeft
	//----------------------------------
	
	private var _paddingLeft:Number = 0;
	
	public function get paddingLeft():Number
	{
		return _paddingLeft;
	}
	
	public function set paddingLeft(value:Number):void
	{
		if (_paddingLeft == value)
			return;
		
		_paddingLeft = value;
		invalidateTargetSizeAndDisplayList();
	}    
	
	//----------------------------------
	//  paddingRight
	//----------------------------------
	
	private var _paddingRight:Number = 0;
	
	public function get paddingRight():Number
	{
		return _paddingRight;
	}
	
	public function set paddingRight(value:Number):void
	{
		if (_paddingRight == value)
			return;
		
		_paddingRight = value;
		invalidateTargetSizeAndDisplayList();
	}    
	
	//----------------------------------
	//  paddingTop
	//----------------------------------
	
	private var _paddingTop:Number = 0;
	
	public function get paddingTop():Number
	{
		return _paddingTop;
	}
	
	public function set paddingTop(value:Number):void
	{
		if (_paddingTop == value)
			return;
		
		_paddingTop = value;
		invalidateTargetSizeAndDisplayList();
	}    
	
	//----------------------------------
	//  paddingBottom
	//----------------------------------
	
	private var _paddingBottom:Number = 0;
	
	public function get paddingBottom():Number
	{
		return _paddingBottom;
	}
	
	public function set paddingBottom(value:Number):void
	{
		if (_paddingBottom == value)
			return;
		
		_paddingBottom = value;
		invalidateTargetSizeAndDisplayList();
	}    
	
	//--------------------------------------------------------------------------
	//
	//  Overriden methods
	//
	//--------------------------------------------------------------------------
	
	override public function measure():void
	{
		if (lastWidth == -1)
			return;
		
		var measuredWidth:Number = 0;
		var measuredMinWidth:Number = 0;
		var measuredHeight:Number = 0;
		var measuredMinHeight:Number = 0;
		
		var layoutTarget:GroupBase = target;
		var n:int = layoutTarget.numElements;
		var element:ILayoutElement;
		var i:int;
		var width:Number = layoutTarget.explicitWidth;
		if (isNaN(width) && lastWidth != -1)
			width = lastWidth;
		if (isNaN(width)) // width is not defined by parent or user
		{
			// do not specify measuredWidth and measuredHeight to real
			// values because in fact we can layout at any width or height
			for (i = 0; i < n; i++)
			{
				element = layoutTarget.getElementAt(i);
				if (!element || !element.includeInLayout)
					continue;
				
				measuredWidth = Math.ceil(element.getPreferredBoundsWidth());
				measuredHeight = Math.ceil(element.getPreferredBoundsHeight());
				break;
			}
			measuredMinWidth = measuredWidth;
			measuredMinHeight = measuredHeight;
		}
		else
		{
			// calculate lines based on width
			var currentLineWidth:Number = 0;
			var currentLineHeight:Number = 0;
			var lineNum:int = 1;
			for (i = 0; i < n; i++)
			{
				element = layoutTarget.getElementAt(i);
				if (!element || !element.includeInLayout)
					continue;
				
				var widthWithoutPaddings:Number = width - _paddingLeft - _paddingRight;
				var elementWidth:Number = Math.ceil(element.getPreferredBoundsWidth());
				if (currentLineWidth == 0 || 
					currentLineWidth + _horizontalGap + elementWidth <= widthWithoutPaddings)
				{
					currentLineWidth += elementWidth + (currentLineWidth == 0 ? 0 : _horizontalGap);
					currentLineHeight = Math.max(currentLineHeight, Math.ceil(element.getPreferredBoundsHeight()));
				}
				else
				{
					measuredHeight += currentLineHeight;
					
					lineNum++;
					currentLineWidth = elementWidth;
					currentLineHeight = Math.ceil(element.getPreferredBoundsHeight());
				}
			}
			measuredHeight += currentLineHeight;
			if (lineNum > 1)
				measuredHeight += _verticalGap * (lineNum - 1);

			// do not set measuredWidth to real value because really we can  
			// layout at any width
			for (i = 0; i < n; i++)
			{
				element = layoutTarget.getElementAt(i);
				if (!element || !element.includeInLayout)
					continue;
				
				measuredWidth =
				measuredMinWidth = Math.ceil(element.getPreferredBoundsWidth());
				break;
			}
			measuredMinHeight = measuredHeight;
		}
		
		layoutTarget.measuredWidth = measuredWidth + _paddingLeft + _paddingRight;
		layoutTarget.measuredMinWidth = measuredMinWidth + _paddingLeft + _paddingRight;
		layoutTarget.measuredHeight = measuredHeight + _paddingTop + _paddingBottom;
		layoutTarget.measuredMinHeight = measuredMinHeight + _paddingTop + _paddingBottom;
	}
	
	override public function updateDisplayList(width:Number, height:Number):void
	{
		var layoutTarget:GroupBase = target;
		var n:int = layoutTarget.numElements;
		var element:ILayoutElement;
		var i:int;
		// calculate lines based on width
		var x:Number = _paddingLeft;
		var y:Number = _paddingTop;
		var maxLineHeight:Number = 0;
		var elementCounter:int = 0;
		var positions:Vector.<Point> = new Vector.<Point>();
		for (i = 0; i < n; i++)
		{
			element = layoutTarget.getElementAt(i);
			if (!element || !element.includeInLayout)
				continue;
			
			var elementWidth:Number = Math.ceil(element.getPreferredBoundsWidth());
			if (x == _paddingLeft || 
				x + _horizontalGap + elementWidth <= width - _paddingRight)
			{
				if (elementCounter > 0)
					x += _horizontalGap;
				positions[i] = new Point(x, y);
				element.setLayoutBoundsSize(NaN, NaN);
				maxLineHeight = Math.max(maxLineHeight, Math.ceil(element.getPreferredBoundsHeight()));
			}
			else
			{
				x = _paddingLeft;
				y += _verticalGap + maxLineHeight;
				maxLineHeight = Math.ceil(element.getPreferredBoundsHeight());
				positions[i] = new Point(x, y);
				element.setLayoutBoundsSize(NaN, NaN);
			}
			x += elementWidth;
			elementCounter++;
		}
		
		// verticalAlign and setLayoutBoundsPosition() for elements
		var yAdd:Number = 0;
		var yDifference:Number = height - (y + maxLineHeight + _paddingBottom);
		if (_verticalAlign == VerticalAlign.MIDDLE)
			yAdd = Math.round(yDifference / 2);
		else if (_verticalAlign == VerticalAlign.BOTTOM)
			yAdd = Math.round(yDifference);
		for (i = 0; i < n; i++)
		{
			element = layoutTarget.getElementAt(i);
			if (!element || !element.includeInLayout)
				continue;
			var point:Point = positions[i];
			point.y += yAdd;
			element.setLayoutBoundsPosition(point.x, point.y);
		}
		
		// if width changed then height will change too - remeasure
		if (lastWidth == -1 || lastWidth != width)
		{
			lastWidth = width;
			invalidateTargetSizeAndDisplayList();
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	private function invalidateTargetSizeAndDisplayList():void
	{
		var g:GroupBase = target;
		if (!g)
			return;
		
		g.invalidateSize();
		g.invalidateDisplayList();
	}

}
}