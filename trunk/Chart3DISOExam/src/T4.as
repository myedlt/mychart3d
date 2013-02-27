package
{       
	import as3isolib.display.IsoView;
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	
	import flash.display.Sprite;
	
	public class T4 extends Sprite
	{
		public function T4 ()
		{                       
			var box:IsoBox = new IsoBox();
			box.moveTo(15, 15, 0);
			
			var grid:IsoGrid = new IsoGrid();
			
			var scene:IsoScene = new IsoScene();
			scene.addChild(box);
			scene.addChild(grid);
			scene.render();
			
			var view:IsoView = new IsoView();
			view.setSize(150, 100);
			view.addScene(scene);
			
			addChild(view);
		}
	}
}