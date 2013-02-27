package
{       
	import as3isolib.core.ClassFactory;
	import as3isolib.core.IFactory;
	import as3isolib.display.IsoView;
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.renderers.DefaultShadowRenderer;
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	
	import flash.display.Sprite;
	
	public class T6 extends Sprite
	{
		public function T6 ()
		{                       
			var scene:IsoScene = new IsoScene();
			scene.hostContainer = this;
			
			var g:IsoGrid = new IsoGrid();
			g.showOrigin = false;
			scene.addChild(g);
			
			var box:IsoBox = new IsoBox();
			box.setSize(25, 25, 25);
			box.moveBy(20, 20, 15); //feature request added
			scene.addChild(box);
			
			var factory:as3isolib.core.ClassFactory = new ClassFactory(DefaultShadowRenderer);
			factory.properties = {shadowColor:0x000000, shadowAlpha:0.15, drawAll:false};
			scene.styleRenderers = [factory];
			
			scene.render();
			
			var view:IsoView = new IsoView();
			view.y = 50;
			view.setSize(150, 100);
			view.addScene( scene); //look in the future to be able to add more scenes
			
			addChild(view);
		}
	}
}