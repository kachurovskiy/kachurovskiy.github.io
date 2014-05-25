package 
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.getDefinitionByName;

	public class DefaultPreloader extends MovieClip
	{
		// ������ ������� ���������
		protected var libs:Array;
		// ������ ������� ���������� ��� ��������
		protected var libsLoadIndex:Number;
		// Loader ��� �������� ���������
		protected var libLoader:Loader;
		// ��� ������ ��������� ����������
		protected var mainApplicationClassName:String;
		
		// ������� ����� ������ � ��������� ��������
		protected var preloaderInitTime:Number;
		protected var loadAppCompleteTime:Number;
		protected var loadLibsCompleteTime:Number;
		
		public function DefaultPreloader(libs:Array, mainApplicationClassName:String)
		{
			preloaderInitTime = 
			(new Date()).getTime();
			
			this.libs = libs;
			this.mainApplicationClassName = 
				mainApplicationClassName;
			libsLoadIndex = 0;
			
			// �������������� ���������
			libLoader = new Loader();
			libLoader.contentLoaderInfo.addEventListener(Event.INIT, libLoaderInitHandler);
			libLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, libLoaderErrorHandler);
			libLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, libLoaderErrorHandler);
			
			stop();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		// ���������� ��� ��������� �������� .swf �����
		// �������� ����������
		protected function init():void
		{
			nextFrame();
			var mainClass:Class = Class(getDefinitionByName(mainApplicationClassName));
			if (mainClass)
			{
			    var app:Object = new mainClass();
			    addChild(app as DisplayObject);
			}
		}
        
		// �������� �������� ���������
		public function loadLibs():void
		{
			loadAppCompleteTime = (new Date()).getTime();
			if (libs &amp;&amp; libs.length > 0)
				loadLib();
			else
				libsLoaded();
		}</pre>

		// �������� ������� (libsLoadIndex) ����������
		protected function loadLib():void
		{
			var urlRequest:URLRequest = new URLRequest(libs[libsLoadIndex]);
			var loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			libLoader.load(urlRequest, loaderContext);
		}
		
		protected function libsLoaded():void
		{
			loadLibsCompleteTime = (new Date()).getTime();
			init();
		}
		
		// event handlers
		
		protected function libLoaderInitHandler(event:Event):void
		{
			libsLoadIndex++;
			if (libsLoadIndex == libs.length)
				libsLoaded();
			else
				loadLib();
		}
		
		protected function libLoaderErrorHandler(event:Event):void
		{
			trace("libLoaderErrorHandler: " + event);
		}
		
		public function onEnterFrame(event:Event):void
		{
			graphics.clear();
			if(framesLoaded == totalFrames)
			{
				removeEventListener
					(Event.ENTER_FRAME, onEnterFrame);
				loadLibs();
			}
			else
			{
				var percent:Number = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
			    graphics.beginFill(0);
			    graphics.drawRect(0, stage.stageHeight / 2 - 10, stage.stageWidth * percent, 20);
			    graphics.endFill();
			}
		}
	}
}