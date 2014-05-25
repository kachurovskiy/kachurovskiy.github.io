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
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.managers.ICursorManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.IStyleManager;
import mx.styles.IStyleManager2;

/**
 * Provides <code>fontSize</code> property to control font size across the application.
 * Changes <code>fontSize</code> automatically using Ctrl+/- and Ctrl-scrolling.
 * 
 * <p>Simplest usage example:</p>
 * 
 * <listing>
 * <pre>
 * new FontSizeManager();
 * </pre>
 * </listing>
 * 
 * If some component need to have font size 2 pixels bigger then others, 
 * set it's <code>styleName</code> to <code>"fontSizeDelta2"</code>. The same
 * <code>"fontSizeDelta-3"</code> will make font size 3 pixels less then usual.
 * 
 * <listing>
 * <pre>
 * &lt;s:Label text="I'm 2 pixels bigger" styleName="fontSizeDelta2"/&gt;
 * </pre>
 * </listing>
 * 
 * Use "fontSizeDelta" style property to make <code>FontSizeManager</code>
 * inject corresponding <code>fontSize</code> in style at runtime:
 * 
 * <listing>
 * <pre>
 * .header
 * {
 *     fontSizeDelta: 2;
 * }
 * 
 * &lt;s:Label text="I'm 2 pixels bigger" styleName="header"/&gt;
 * </pre>
 * </listing>
 * 
 * <b>Note:</b> <code>FontSizeManager</code> can not affect styles and components
 * that have fixed <code>fontSize</code>:
 * 
 * <listing>
 * <pre>
 * .popupText
 * {
 *     fontSize: 11px;
 * }
 * 
 * &lt;s:Label text="I'm always 11px" styleName="popupText"/&gt;
 * &lt;s:Label text="Me too" fontSize="11"/&gt;
 * </pre>
 * </listing>
 * 
 * @see http://kachurovskiy.com/2010/font-size-ctrl/
 */
public class FontSizeManager extends EventDispatcher
{
	
	//--------------------------------------------------------------------------
	//
	//  Static constants
	//
	//--------------------------------------------------------------------------

	public static const DEFAULT_FONT_SIZE:Number = 12;
	public static const MAX_FONT_SIZE:Number = 50;
	public static const MIN_FONT_SIZE:Number = 8;
	
	/**
	 * Specifies amount of ".fontSizeDeltaN" style classes to generate. E.g.
	 * if <code>AMOUNT_OF_STYLE_CLASSES</code> is 3 then "fontSizeDelta-3",
	 * "fontSizeDelta-2", "fontSizeDelta-1", "fontSizeDelta1", "fontSizeDelta2"
	 * and "fontSizeDelta3" style selectors can be used.
	 */
	public static const AMOUNT_OF_STYLE_CLASSES:Number = 10;
	
	/**
	 * Specifies how real "fontSize" for e.g. "fontSizeDelta2" is calculated.
	 * If false then it is just <code>fontSize + 2</code>. If true then it is 
	 * <code>(DEFAULT_FONT_SIZE + 2) / DEFAULT_FONT_SIZE * fontSize</code>. 
	 * The second case is better for big font sizes.
	 */
	public static const SCALE_FONT_SIZES:Boolean = true;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	public function FontSizeManager()
	{
		initialize();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	private var application:*;
	
	/**
	 * It is <code>IStyleManager</code> for Flex 3 and <code>IStyleManager2</code>
	 * for Flex 4.
	 */
	private var styleManager:IStyleManager2;
	
	private var cursorManager:ICursorManager;
	
	private var declarations:Vector.<CSSStyleDeclaration>;
	
	private var global:CSSStyleDeclaration;
	private var globalDefaultFontSize:Number;
	
	private var stages:Vector.<Stage> = new Vector.<Stage>();
	
	/**
	 * Indicates whether we are waiting for <code>FlexEvent.UPDATE_COMPLETE</code>
	 * event from application.
	 */
	private var changing:Boolean = false;
	
	/**
	 * Indicates whether <code>fontSize</code> was changed when <code>changing</code>
	 * was <code>true</code>.
	 */
	private var pending:Boolean = false;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	private var _fontSize:Number = DEFAULT_FONT_SIZE;

	[Bindable("fontSizeChange")]
	/**
	 * Changes base font size in the applications. This property is automatically
	 * changed when user presses Ctrl+/- or Ctrl+scrolling. It can also be set
	 * manually.
	 * 
	 * <p>Default value is <code>DEFAULT_FONT_SIZE</code>.</p>
	 */
	public function get fontSize():Number
	{
		return _fontSize;
	}

	public function set fontSize(value:Number):void
	{
		value = Math.max(value, MIN_FONT_SIZE);
		value = Math.min(value, MAX_FONT_SIZE);

		if (_fontSize == value)
			return;
		
		_fontSize = value;
		setFontSizeToStyles();
		dispatchEvent(new Event("fontSizeChange"));
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	private function initialize():void
	{
		application = FlexGlobals.topLevelApplication;
		styleManager = application.styleManager;
		cursorManager = application.cursorManager;
		
		declarations = new Vector.<CSSStyleDeclaration>();
		var n:int = AMOUNT_OF_STYLE_CLASSES;
		for (var i:int = -n; i <= n; i++)
		{
			if (i == 0) // we don't need "fontSizeDelta0" class
				continue;
			
			var selector:String = ".fontSizeDelta" + i;
			var declaration:CSSStyleDeclaration = new CSSStyleDeclaration(
				selector, styleManager, false);
			declarations.push(declaration);
			styleManager.setStyleDeclaration(selector, declaration, false);
		}
		global = styleManager.getStyleDeclaration("global");
		globalDefaultFontSize = global.getStyle("fontSize");
		
		setFontSizeToStyles();
		
		var stage:Stage = application.stage;
		if (stage)
			addStage(stage);
		else
			application.addEventListener(Event.ADDED_TO_STAGE,
				application_addedToStage);
	}
	
	private function setFontSizeToStyles():void
	{
		if (changing)
		{
			pending = true;
			return;
		}
		changing = true;
		pending = false;
		
		// set "fontSize" style for ".fontSizeDeltaN" declarations
		var n:int = declarations.length;
		var declaration:CSSStyleDeclaration;
		var selector:String;
		for (var i:int = 0; i < n; i++)
		{
			declaration = declarations[i];
			selector = declaration.selector.toString();
			// get delta from "fontSizeDelta2" or "fontSizeDelta-3"
			var delta:int = int(selector.substr(".fontSizeDelta".length));
			declaration.setStyle("fontSize", getFontSizeForDelta(delta));
			styleManager.setStyleDeclaration(selector, declaration, false);
		}
		
		// set fontSize style for all declarations that have "fontSizeDelta" style
		// set inside
		var selectors:Array = styleManager.selectors;
		var m:int = selectors.length;
		for (var j:int = 0; j < m; j++)
		{
			selector = selectors[j];
			declaration = styleManager.getStyleDeclaration(selector);
			var fontSizeDelta:Number = declaration.getStyle("fontSizeDelta");
			if (isNaN(fontSizeDelta) || fontSizeDelta == 0)
				continue;
			
			declaration.setStyle("fontSize", getFontSizeForDelta(fontSizeDelta));
			styleManager.setStyleDeclaration(selector, declaration, false);
		}
		
		global.setStyle("fontSize", _fontSize);
		styleManager.setStyleDeclaration("global", global, true);
		
		application.addEventListener(FlexEvent.UPDATE_COMPLETE,
			application_updateCompleteHandler);
		cursorManager.setBusyCursor();
	}
	
	private function getFontSizeForDelta(delta:Number):Number
	{
		var newFontSize:Number;
		if (SCALE_FONT_SIZES)
			newFontSize = _fontSize * (DEFAULT_FONT_SIZE + delta) / DEFAULT_FONT_SIZE;
		else
			newFontSize = _fontSize + delta;
		newFontSize = Math.max(newFontSize, MIN_FONT_SIZE);
		return Math.min(newFontSize, MAX_FONT_SIZE);
	}
	
	/**
	 * Starts to listen to keyboard and mouse events from the given <code>stage</code>.
	 * Main stage is added automatically. Should be used if AIR native windows
	 * are used.
	 */
	public function addStage(stage:Stage):void
	{
		if (stages.indexOf(stage) >= 0)
			return;
		
		stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, stage_mouseWheelHandler);
		stages.push(stage);
	}
	
	/**
	 * Stops listening to <code>stage</code>.
	 */
	public function removeStage(stage:Stage):void
	{
		if (stages.indexOf(stage) == -1)
			return;
		
		stage.removeEventListener(MouseEvent.MOUSE_WHEEL, stage_mouseWheelHandler);
		stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
		stages.splice(stages.indexOf(stage), 1);
	}

	/**
	 * Removes all event listeners, clears links and restores original styles.
	 */
	public function destroy():void
	{
		application.removeEventListener(Event.ADDED_TO_STAGE,
			application_addedToStage);
		application.removeEventListener(FlexEvent.UPDATE_COMPLETE,
			application_updateCompleteHandler);
		
		var stagesCopy:Vector.<Stage> = stages.concat();
		var m:int = stagesCopy.length;
		for (var j:int = 0; j < m; j++)
		{
			removeStage(stagesCopy[j]);
		}
		stages = null;
		
		// set initial "fontSize" into global 
		global.setStyle("fontSize", globalDefaultFontSize);
		styleManager.setStyleDeclaration("global", global, false);
		global = null;
		
		var selectors:Array = styleManager.selectors;
		var declaration:CSSStyleDeclaration;
		var selector:String;
		var k:int = selectors.length;
		for (var g:int = 0; g < k; g++)
		{
			selector = selectors[g];
			declaration = styleManager.getStyleDeclaration(selector);
			var fontSizeDelta:Number = declaration.getStyle("fontSizeDelta");
			if (isNaN(fontSizeDelta) || fontSizeDelta == 0)
				continue;
			
			declaration.clearStyle("fontSize");
			styleManager.setStyleDeclaration(selector, declaration, false);
		}
		
		var n:int = declarations.length;
		for (var i:int = 0; i < n; i++)
		{
			declaration = declarations[i];
			selector = declaration.selector.toString();
			styleManager.clearStyleDeclaration(selector, i == n - 1);
		}
		declarations = null;
		styleManager = null;
		cursorManager = null;
		application = null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	private function stage_keyUpHandler(event:KeyboardEvent):void
	{
		if (!event.ctrlKey)
			return;
		
		var keyCode:uint = event.keyCode;
		if (keyCode == Keyboard.NUMPAD_ADD || keyCode == Keyboard.PAGE_UP ||
			keyCode == 187) // 187 is "+"
			fontSize++;
		else if (keyCode == Keyboard.NUMPAD_SUBTRACT || keyCode == Keyboard.PAGE_DOWN ||
			keyCode == 189) // 189 is "-"
			fontSize--;
	}
	
	private function stage_mouseWheelHandler(event:MouseEvent):void
	{
		if (!event.ctrlKey)
			return;
		
		if (event.delta > 0)
			fontSize++;
		else
			fontSize--;
	}
	
	private function application_updateCompleteHandler(event:FlexEvent):void
	{
		application.removeEventListener(FlexEvent.UPDATE_COMPLETE,
			application_updateCompleteHandler);
		
		cursorManager.removeBusyCursor();
		
		changing = false;
		if (pending)
			setFontSizeToStyles();
	}
	
	private function application_addedToStage(event:Event):void
	{
		application.removeEventListener(Event.ADDED_TO_STAGE,
			application_addedToStage);
		
		addStage(event.target.stage);
	}
	
}
}