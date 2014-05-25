/* Copyright (c) 2010 Maxim Kachurovskiy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. */

package
{
import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalAlign;
import spark.layouts.supportClasses.LayoutBase;

/**
 * <code>HorizontalSqueezeLayout</code> behaves mostly like <code>HorizontalLayout</code>.
 * The main difference is that when given width is not enough to show elements
 * with preferred width it squeezed them so that they fit the given width. It
 * is useful for example when buttons in possibly small toolbar are laid out.
 * 
 * <p>Does not support virtual layout, columns properties and percent widths
 * for elements.</p> 
 */
public class HorizontalSqueezeLayout extends LayoutBase
{
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  gap
	//----------------------------------
	
	private var _gap:int = 6;
	
	public function get gap():int
	{
		return _gap;
	}
	
	public function set gap(value:int):void
	{
		if (_gap == value) 
			return;
		
		_gap = value;
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
	
	//----------------------------------
	//  horizontalAlign
	//----------------------------------
	
	private var _horizontalAlign:String = HorizontalAlign.LEFT;
	
	[Inspectable(category="General", enumeration="left,right,center", defaultValue="left")]
	public function get horizontalAlign():String
	{
		return _horizontalAlign;
	}
	
	public function set horizontalAlign(value:String):void
	{
		if (value == _horizontalAlign) 
			return;
		
		_horizontalAlign = value;
		
		var layoutTarget:GroupBase = target;
		if (layoutTarget)
			layoutTarget.invalidateDisplayList();
	}
	
	//----------------------------------
	//  verticalAlign
	//----------------------------------
	
	private var _verticalAlign:String = VerticalAlign.TOP;
	
	[Inspectable(category="General", enumeration="top,bottom,middle,justify,contentJustify", defaultValue="top")]
	public function get verticalAlign():String
	{
		return _verticalAlign;
	}
	
	public function set verticalAlign(value:String):void
	{
		if (value == _verticalAlign) 
			return;
		
		_verticalAlign = value;
		
		var layoutTarget:GroupBase = target;
		if (layoutTarget)
			layoutTarget.invalidateDisplayList();
	}

	//--------------------------------------------------------------------------
	//
	//  Overriden methods
	//
	//--------------------------------------------------------------------------
	
	override public function measure():void
	{
		var measuredWidth:Number = _paddingLeft + _paddingRight;
		var measuredMinWidth:Number = _paddingLeft + _paddingRight;
		var measuredHeight:Number = 0;
		var measuredMinHeight:Number = 0;
		
		var layoutTarget:GroupBase = target;
		var n:int = layoutTarget.numElements;
		var elementsMeasured:int = 0;
		for (var i:int = 0; i < n; i++)
		{
			var element:ILayoutElement = layoutTarget.getElementAt(i);
			if (!element || !element.includeInLayout)
				continue;
			
			measuredWidth += element.getPreferredBoundsWidth();
			measuredMinWidth += element.getMinBoundsWidth();
			measuredHeight = Math.max(measuredHeight, element.getPreferredBoundsHeight());
			measuredMinHeight = Math.max(measuredMinHeight, element.getMinBoundsHeight());
			elementsMeasured++;
		}
		
		if (elementsMeasured > 1)
		{
			var totalGap:Number = _gap * (elementsMeasured - 1);
			measuredWidth += totalGap;
			measuredMinWidth += totalGap;
		}
		
		layoutTarget.measuredWidth = measuredWidth;
		layoutTarget.measuredMinWidth = measuredMinWidth;
		layoutTarget.measuredHeight = measuredHeight + _paddingTop + _paddingBottom;
		layoutTarget.measuredMinHeight = measuredMinHeight + _paddingTop + _paddingBottom;
	}
	
	override public function updateDisplayList(width:Number, height:Number):void
	{
		var layoutTarget:GroupBase = target;
		var widthMultiplier:Number = -1;
		var n:int = layoutTarget.numElements;
		var i:int;
		var elementsMeasured:int = 0;
		var element:ILayoutElement;
		var widthDifference:Number = width - layoutTarget.measuredWidth;
		var percents:Number = 0;
		if (widthDifference < 0) // need to squeeze all elements
		{
			// calculate widthMultiplier
			var elementsPrefMinDifference:Number = 0;
			for (i = 0; i < n; i++)
			{
				element = layoutTarget.getElementAt(i);
				if (!element || !element.includeInLayout)
					continue;
				
				elementsPrefMinDifference += element.getPreferredBoundsWidth() - 
					element.getMinBoundsWidth();
				elementsMeasured++;
			}
			if (elementsPrefMinDifference > 0)
				widthMultiplier = Math.max(0, 1 + widthDifference / elementsPrefMinDifference);
		}
		var gaps:Number = _gap * Math.max(0, elementsMeasured - 1);
		
		var x:Number = _paddingLeft;
		var y:Number = _paddingTop;
		// handle horizontalAlign
		if (widthDifference > 0 && _horizontalAlign != HorizontalAlign.LEFT)
		{
			if (_horizontalAlign == HorizontalAlign.CENTER)
				x += widthDifference / 2;
			else if (_horizontalAlign == HorizontalAlign.RIGHT)
				x += widthDifference;
		}
		
		var contentHeight:Number = 0;
		if (_verticalAlign == VerticalAlign.CONTENT_JUSTIFY)
		{
			for (i = 0; i < n; i++)
			{
				element = layoutTarget.getElementAt(i);
				if (!element || !element.includeInLayout)
					continue;
				
				contentHeight = Math.max(contentHeight, element.getPreferredBoundsHeight());
			}
		}
		
		var availableHeight:Number = height - _paddingBottom - _paddingTop;
		for (i = 0; i < n; i++)
		{
			element = layoutTarget.getElementAt(i);
			if (!element || !element.includeInLayout)
				continue;
			
			var elementHeight:Number;
			if (_verticalAlign == VerticalAlign.JUSTIFY)
				elementHeight = availableHeight;
			else if (_verticalAlign == VerticalAlign.CONTENT_JUSTIFY)
				elementHeight = Math.min(contentHeight, availableHeight);
			else
				elementHeight = element.getPreferredBoundsHeight();
			
			var elementWidth:Number;
			var preferredWidth:Number = element.getPreferredBoundsWidth();
			if (widthDifference >= 0)
			{
				elementWidth = preferredWidth;
				element.setLayoutBoundsSize(NaN, elementHeight);
			}
			else
			{
				elementWidth = element.getMinBoundsWidth() + 
					(preferredWidth - element.getMinBoundsWidth()) * widthMultiplier; 
				element.setLayoutBoundsSize(elementWidth, elementHeight);
			}
			
			var elementY:Number = y;
			if (_verticalAlign == VerticalAlign.BOTTOM)
				elementY += availableHeight - elementHeight;
			else if (_verticalAlign == VerticalAlign.MIDDLE)
				elementY += (availableHeight - elementHeight) / 2;
			else if (_verticalAlign == VerticalAlign.CONTENT_JUSTIFY)
				elementY += (availableHeight - contentHeight) / 2;
			element.setLayoutBoundsPosition(x, elementY);
			
			x += elementWidth + _gap;
		}
	}

	private function invalidateTargetSizeAndDisplayList():void
	{
		var groupBase:GroupBase = target;
		if (!groupBase)
			return;
		
		groupBase.invalidateSize();
		groupBase.invalidateDisplayList();
	}

	
}
}