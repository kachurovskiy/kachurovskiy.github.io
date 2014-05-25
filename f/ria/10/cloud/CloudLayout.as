package
{
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.FlexGlobals;
import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalAlign;
import spark.layouts.supportClasses.LayoutBase;
import spark.primitives.Graphic;

/**
 * Lays out elements as a Web 2.0 tag cloud.
 * 
 * <p>Percent sizes are not supported for elements. Authomatic height 
 * measurement is supported: set <code>width<code> and layout will set 
 * <code>measuredHeight</code>.</p>
 */
public class CloudLayout extends LayoutBase
{
	
	public function CloudLayout()
	{
		super();
		
		hitTestShape = new Shape();
		graphics = hitTestShape.graphics;
		
		// we need to add hit-testing shape to the stage so that hitTestPoint()
		// method work correctly
		hitTestShape.visible = false;
		if (FlexGlobals.topLevelApplication.stage)
			application_addedToStageHandler();
		else
			FlexGlobals.topLevelApplication.addEventListener(Event.ADDED_TO_STAGE,
				application_addedToStageHandler, false, 0, true);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var hitTestShape:Shape;
	private var graphics:Graphics;
	
	private var lastWidth:Number = -1;
	private var lastHeight:Number = -1;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
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
	//  horizontalAlign
	//----------------------------------
	
	private var _horizontalAlign:String = HorizontalAlign.CENTER;
	
	[Inspectable(category="General", enumeration="left,right,center", defaultValue="center")]
	public function get horizontalAlign():String
	{
		return _horizontalAlign;
	}
	
	public function set horizontalAlign(value:String):void
	{
		if (_horizontalAlign == value)
			return;
		
		_horizontalAlign = value;
		invalidateTargetSizeAndDisplayList();
	}
	
	//----------------------------------
	//  verticalAlign
	//----------------------------------
	
	private var _verticalAlign:String = VerticalAlign.MIDDLE;
	
	[Inspectable(category="General", enumeration="top,bottom,middle", defaultValue="middle")]
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

	//--------------------------------------------------------------------------
	//
	//  Overriden methods
	//
	//--------------------------------------------------------------------------
	
	override public function updateDisplayList(width:Number, height:Number):void
	{
		var pureWidth:Number = width - _paddingLeft - _paddingRight;
		var pureHeight:Number = height - _paddingTop - _paddingBottom;
		var points:Vector.<Vector.<Point>> = Vector.<Vector.<Point>>(
			[
				new Vector.<Point>(),
				new Vector.<Point>(),
				new Vector.<Point>(),
				new Vector.<Point>(),
				new Vector.<Point>(),
				new Vector.<Point>(),
				new Vector.<Point>(),
				new Vector.<Point>()
			]);
		
		var layoutTarget:GroupBase = target;
		var element:ILayoutElement;
		var n:int;
		var i:int;
		
		var elements:Vector.<ILayoutElement> = new Vector.<ILayoutElement>();
		var elementRectangles:Vector.<Rectangle> = new Vector.<Rectangle>();
		fillWithSortedElements(elements, elementRectangles);
		
		var rectangle:Rectangle;
		n = elementRectangles.length;
		if (n == 0)
			return;
		rectangle = elementRectangles[0];
		// horizontalAlign
		if (_horizontalAlign == HorizontalAlign.LEFT)
			rectangle.x = _paddingLeft;
		else if (_horizontalAlign == HorizontalAlign.CENTER)
			rectangle.x = _paddingLeft + (pureWidth - rectangle.width) / 2;
		else // if (_horizontalAlign == HorizontalAlign.RIGHT)
			rectangle.x = _paddingLeft + pureWidth - rectangle.width;
		// verticalAlign
		if (_verticalAlign == VerticalAlign.TOP)
			rectangle.y = _paddingTop;
		else if (_verticalAlign == VerticalAlign.MIDDLE)
			rectangle.y = _paddingTop + Math.max(1, (pureHeight - rectangle.height) / 2);
		else // if (_verticalAlign == VerticalAlign.BOTTOM)
			rectangle.y = _paddingTop + Math.max(1, pureHeight - rectangle.height);
		graphics.clear();
		drawRectangleIntoGraphics(rectangle);
		points[1].push(new Point(rectangle.x + rectangle.width / 2, rectangle.y + rectangle.height));
		points[3].push(new Point(rectangle.x, rectangle.y + rectangle.height / 2));
		points[7].push(new Point(rectangle.x + rectangle.width, rectangle.y + rectangle.height / 2));
		points[5].push(new Point(rectangle.x + rectangle.width / 2, rectangle.y));
		var minX:Number = rectangle.x;
		var minY:Number = rectangle.y;
		var maxX:Number = minX + rectangle.width;
		var maxY:Number = minY + rectangle.height;
		var minAllowedX:Number = _paddingLeft;
		var minAllowedY:Number = _paddingTop;
		var maxAllowedX:Number = pureWidth;
		var maxAllowedY:Number = pureHeight;
		for (i = 1; i < n; i++)
		{
			element = elements[i];
			rectangle = elementRectangles[i];
			
			// calculate point of the best append - vector index and item index
			var appendVectorIndex:int = -1;
			var appendVectorItemIndex:int = -1;
			var minArea:Number = 10000 * 10000;
			var minAreaMinX:Number;
			var minAreaMaxX:Number;
			var minAreaMinY:Number;
			var minAreaMaxY:Number;
			for (var j:int = 0; j < 8; j++)
			{
				var correspondingVector:Vector.<Point> = points[j];
				var m:int = correspondingVector.length;
				if (m == 0)
					continue;
				
				for (var k:int = 0; k < m; k++)
				{
					var correspondingPoint:Point = correspondingVector[k];
					var newMinX:Number = minX;
					var newMinY:Number = minY;
					var newMaxX:Number = maxX;
					var newMaxY:Number = maxY;
					if (j == 0) // top-left point of rectangle
					{
						newMaxX = Math.max(newMaxX, correspondingPoint.x + rectangle.width);
						newMaxY = Math.max(newMaxY, correspondingPoint.y + rectangle.height);
					}
					else if (j == 1) // top point of rectangle
					{
						newMinX = Math.min(newMinX, correspondingPoint.x - rectangle.width / 2);
						newMaxX = Math.max(newMaxX, correspondingPoint.x + rectangle.width / 2);
						newMaxY = Math.max(newMaxY, correspondingPoint.y + rectangle.height);
					}
					else if (j == 2) // top-right
					{
						newMinX = Math.min(newMinX, correspondingPoint.x - rectangle.width);
						newMaxY = Math.max(newMaxY, correspondingPoint.y + rectangle.height);
					}
					else if (j == 3) // right
					{
						newMinX = Math.min(newMinX, correspondingPoint.x - rectangle.width);
						newMinY = Math.min(newMinY, correspondingPoint.y - rectangle.height / 2);
						newMaxY = Math.max(newMaxY, correspondingPoint.y + rectangle.height / 2);
					}
					else if (j == 4) // bottom-right
					{
						newMinX = Math.min(newMinX, correspondingPoint.x - rectangle.width);
						newMinY = Math.min(newMaxY, correspondingPoint.y - rectangle.height);
					}
					else if (j == 5) // bottom
					{
						newMinX = Math.min(newMinX, correspondingPoint.x - rectangle.width / 2);
						newMaxX = Math.max(newMaxX, correspondingPoint.x + rectangle.width / 2);
						newMinY = Math.min(newMinY, correspondingPoint.y - rectangle.height);
					}
					else if (j == 6) // bottom-left
					{
						newMaxX = Math.max(newMaxX, correspondingPoint.x + rectangle.width);
						newMinY = Math.min(newMinY, correspondingPoint.y - rectangle.height);
					}
					else if (j == 7) // left
					{
						newMaxX = Math.max(newMaxX, correspondingPoint.x + rectangle.width);
						newMinY = Math.min(newMinY, correspondingPoint.y - rectangle.height / 2);
						newMaxY = Math.max(newMaxY, correspondingPoint.y + rectangle.height / 2);
					}
					if (!isNaN(layoutTarget.explicitWidth) && 
						(newMinX < minAllowedX || newMaxX > maxAllowedX))
						continue;
						
					if (newMinY < minAllowedY)
						continue;
					if (!isNaN(layoutTarget.explicitHeight) && newMaxY > maxAllowedY)
						continue;
					
					setRectangePosition(rectangle, correspondingPoint, j);
					// if overlaps - try to fit this element again
					if (hitTestShape.hitTestPoint(rectangle.x, rectangle.y, true) ||
						hitTestShape.hitTestPoint(rectangle.right, rectangle.y, true) ||
						hitTestShape.hitTestPoint(rectangle.right, rectangle.bottom, true) ||
						hitTestShape.hitTestPoint(rectangle.x, rectangle.bottom, true) ||
						hitTestShape.hitTestPoint(rectangle.x + rectangle.width / 2, 
							rectangle.y + rectangle.height / 2, true) ||
						hitTestShape.hitTestPoint(rectangle.x, 
							rectangle.y + rectangle.height / 2, true) ||
						hitTestShape.hitTestPoint(rectangle.x + rectangle.width / 2, 
							rectangle.y, true) ||
						hitTestShape.hitTestPoint(rectangle.x + rectangle.width, 
							rectangle.y + rectangle.height / 2, true) ||
						hitTestShape.hitTestPoint(rectangle.x + rectangle.width / 2, 
							rectangle.y + rectangle.height, true))
						continue;
					
					var newArea:Number = (newMaxX - newMinX) * (newMaxY - newMinY);
					if (newArea < minArea)
					{
						minArea = newArea;
						minAreaMinX = newMinX;
						minAreaMaxX = newMaxX;
						minAreaMinY = newMinY;
						minAreaMaxY = newMaxY;
						appendVectorIndex = j;
						appendVectorItemIndex = k;
					}
				}
			}
			if (appendVectorIndex == -1) // not enough place to place this element
			{
				if (element is DisplayObject)
					DisplayObject(element).visible = false;
				continue; // go to next element
			}
			else if (element is DisplayObject)
			{
				DisplayObject(element).visible = true;
			}
			var bestPoint:Point = points[appendVectorIndex][appendVectorItemIndex];
			// this point can not be used - it is now occupied
			points[appendVectorIndex].splice(appendVectorItemIndex, 1);
			setRectangePosition(rectangle, bestPoint, appendVectorIndex);
			minX = minAreaMinX;
			maxX = minAreaMaxX;
			minY = minAreaMinY;
			maxY = minAreaMaxY;
			
			drawRectangleIntoGraphics(rectangle);
			
			// now add new rectangle append points to the points vectors
			if (appendVectorIndex == 0)
			{
				points[0].push(new Point(rectangle.right, rectangle.y));
				points[0].push(new Point(rectangle.x, rectangle.bottom));
				points[7].push(new Point(rectangle.right, rectangle.y + rectangle.height / 2));
				points[1].push(new Point(rectangle.x + rectangle.width / 2, rectangle.bottom));
			}
			else if (appendVectorIndex == 1)
			{
				points[0].push(new Point(rectangle.right, rectangle.y));
				points[1].push(new Point(rectangle.x + rectangle.width / 2, rectangle.bottom));
				points[2].push(new Point(rectangle.x, rectangle.y));
				points[7].push(new Point(rectangle.right, rectangle.y + rectangle.height / 2));
				points[3].push(new Point(rectangle.x, rectangle.y + rectangle.height / 2));
			}
			else if (appendVectorIndex == 2)
			{
				points[2].push(new Point(rectangle.x, rectangle.y));
				points[2].push(new Point(rectangle.right, rectangle.bottom));
				points[3].push(new Point(rectangle.x, rectangle.y + rectangle.height / 2));
				points[1].push(new Point(rectangle.x + rectangle.width / 2, rectangle.bottom));
			}
			else if (appendVectorIndex == 3)
			{
				points[1].push(new Point(rectangle.x + rectangle.width / 2, rectangle.bottom));
				points[2].push(new Point(rectangle.right, rectangle.bottom));
				points[3].push(new Point(rectangle.x, rectangle.y + rectangle.height / 2));
				points[4].push(new Point(rectangle.right, rectangle.y));
				points[5].push(new Point(rectangle.x + rectangle.width / 2, rectangle.y));
			}
			else if (appendVectorIndex == 4)
			{
				points[3].push(new Point(rectangle.x, rectangle.y + rectangle.height / 2));
				points[4].push(new Point(rectangle.x, rectangle.bottom));
				points[4].push(new Point(rectangle.right, rectangle.y));
				points[5].push(new Point(rectangle.x + rectangle.width / 2, rectangle.y));
				points[4].push(new Point(rectangle.right, rectangle.y));
			}
			else if (appendVectorIndex == 5)
			{
				points[3].push(new Point(rectangle.x, rectangle.y + rectangle.height / 2));
				points[4].push(new Point(rectangle.x, rectangle.bottom));
				points[5].push(new Point(rectangle.x + rectangle.width / 2, rectangle.y));
				points[6].push(new Point(rectangle.right, rectangle.bottom));
				points[7].push(new Point(rectangle.right, rectangle.y + rectangle.height / 2));
			}
			else if (appendVectorIndex == 6)
			{
				points[5].push(new Point(rectangle.x + rectangle.width / 2, rectangle.y));
				points[6].push(new Point(rectangle.x, rectangle.y));
				points[6].push(new Point(rectangle.right, rectangle.bottom));
				points[7].push(new Point(rectangle.right, rectangle.y + rectangle.height / 2));
			}
			else if (appendVectorIndex == 7)
			{
				points[0].push(new Point(rectangle.x, rectangle.bottom));
				points[1].push(new Point(rectangle.x + rectangle.width / 2, rectangle.bottom));
				points[5].push(new Point(rectangle.x + rectangle.width / 2, rectangle.y));
				points[6].push(new Point(rectangle.x, rectangle.y));
				points[7].push(new Point(rectangle.right, rectangle.y + rectangle.height / 2));
			}
		}
		
		// if horizontalAlign is center or verticalAlign is middle (or both)
		// then we may need to center the content on the screen
		for (i = 0; i < n; i++)
		{
			rectangle = elementRectangles[i];
			minX = Math.min(rectangle.x, minX);
			minY = Math.min(rectangle.y, minY);
		}
		var xDelta:Number = 0;
		var yDelta:Number = 0;
		if (_horizontalAlign == HorizontalAlign.CENTER)
			xDelta = Math.max(-minX, Math.round(width / 2 - (minX + hitTestShape.width / 2)));
		if (_verticalAlign == VerticalAlign.MIDDLE)
			yDelta = Math.max(-minY, Math.round(height / 2 - (minY + hitTestShape.height / 2)));
		if (xDelta != 0 || yDelta != 0)
		{
			for (i = 0; i < n; i++)
			{
				rectangle = elementRectangles[i];
				rectangle.x += xDelta;
				if (rectangle.y + yDelta < 0)
					trace("Error");
				rectangle.y += yDelta;
			}
		}
		
		for (i = 0; i < n; i++)
		{
			rectangle = elementRectangles[i];
			element = elements[i];
			element.setLayoutBoundsPosition(rectangle.x + _horizontalGap / 2, rectangle.y + _verticalGap / 2);
			element.setLayoutBoundsSize(NaN, NaN);
		}
		
		// now we know the real values of 
		if (lastWidth == -1 || Math.round(hitTestShape.width - lastWidth) != 0 ||
			lastHeight == -1 || Math.round(hitTestShape.height - lastHeight) != 0)
		{
			lastWidth = hitTestShape.width + _horizontalGap;
			lastHeight = hitTestShape.height + _verticalGap;
			layoutTarget.invalidateSize();
		}
	}
	
	override public function measure():void
	{
		var layoutTarget:GroupBase = target;
		layoutTarget.measuredWidth = 10;
		layoutTarget.measuredMinWidth = 10;
		layoutTarget.measuredHeight = 10;
		layoutTarget.measuredMinHeight = 10;
		if (lastHeight >= 0)
			layoutTarget.measuredHeight = lastHeight;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	private function drawRectangleIntoGraphics(rectangle:Rectangle):void
	{
		// draw corresponding rect in graphics to disallow overlapping
		graphics.beginFill(0, 0.5);
		graphics.drawRect(rectangle.x + 1, rectangle.y + 1, rectangle.width - 2, rectangle.height - 2);
		graphics.endFill();
	}
	
	private function fillWithSortedElements(elements:Vector.<ILayoutElement>, 
		rectangles:Vector.<Rectangle>):void
	{
		var layoutTarget:GroupBase = target;
		var element:ILayoutElement;
		var n:int = layoutTarget.numElements;
		var i:int;
		var areas:Array = [];
		var tempElements:Vector.<ILayoutElement> = new Vector.<ILayoutElement>(); 
		var tempRectangles:Vector.<Rectangle> = new Vector.<Rectangle>();
		for (i = 0; i < n; i++)
		{
			element = layoutTarget.getElementAt(i);
			if (!element || !element.includeInLayout)
			{
				continue;
			}
			tempElements.push(element);
			var rectangle:Rectangle = new Rectangle(_horizontalGap / 2, _verticalGap / 2, 
				element.getPreferredBoundsWidth() + _horizontalGap,
				element.getPreferredBoundsHeight() + _verticalGap);
			tempRectangles.push(rectangle);
			areas.push(rectangle.width * rectangle.height);
		}
		var indexes:Array = areas.sort(Array.RETURNINDEXEDARRAY | Array.NUMERIC | Array.DESCENDING);
		n = areas.length;
		for (i = 0; i < n; i++)
		{
			elements[i] = tempElements[indexes[i]];
			rectangles[i] = tempRectangles[indexes[i]];
		}
	}
	
	private function setRectangePosition(rectangle:Rectangle, bestPoint:Point, appendVectorIndex:int):void
	{
		// best point found. Now set rectangle coordinates
		if (appendVectorIndex == 0)
		{
			rectangle.x = bestPoint.x;
			rectangle.y = bestPoint.y;
		}
		else if (appendVectorIndex == 1)
		{
			rectangle.x = bestPoint.x - rectangle.width / 2;
			rectangle.y = bestPoint.y;
		}
		else if (appendVectorIndex == 2)
		{
			rectangle.x = bestPoint.x - rectangle.width;
			rectangle.y = bestPoint.y;
		}
		else if (appendVectorIndex == 3)
		{
			rectangle.x = bestPoint.x - rectangle.width;
			rectangle.y = bestPoint.y - rectangle.height / 2;
		}
		else if (appendVectorIndex == 4)
		{
			rectangle.x = bestPoint.x - rectangle.width;
			rectangle.y = bestPoint.y - rectangle.height;
		}
		else if (appendVectorIndex == 5)
		{
			rectangle.x = bestPoint.x - rectangle.width / 2;
			rectangle.y = bestPoint.y - rectangle.height;
		}
		else if (appendVectorIndex == 6)
		{
			rectangle.x = bestPoint.x;
			rectangle.y = bestPoint.y - rectangle.height;
		}
		else if (appendVectorIndex == 7)
		{
			rectangle.x = bestPoint.x;
			rectangle.y = bestPoint.y - rectangle.height / 2;
		}
	}
	
	private function invalidateTargetSizeAndDisplayList():void
	{
		var g:GroupBase = target;
		if (!g)
			return;
		
		g.invalidateSize();
		g.invalidateDisplayList();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event hanlers
	//
	//--------------------------------------------------------------------------
	
	private function application_addedToStageHandler(event:Event = null):void
	{
		FlexGlobals.topLevelApplication.stage.addChild(hitTestShape);
		FlexGlobals.topLevelApplication.removeEventListener(Event.ADDED_TO_STAGE,
			application_addedToStageHandler);
	}
	
}
}