package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.*;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.special.LineMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.render.BasicRenderEngine;
	
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
   import org.papervision3d.materials.MovieMaterial;
    import org.papervision3d.materials.WireframeMaterial;
    import org.papervision3d.objects.primitives.Cone ;
    
      
    [SWF(width='800',height='600',backgroundColor='0x868686',frameRate='30')]
	public class Exam extends Sprite {
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var viewport:Viewport3D;
		private var renderer:BasicRenderEngine;
		
		private var axes:Lines3D;
		private var cube:Cube;
		private var plane:Plane;

    private var doRotation:Boolean = false;
    private var lastMouseX:int;
    private var lastMouseY:int;
    private var cameraPitch:Number = 60;
    private var cameraYaw:Number = -60;

		public function Exam() {
			// set up the stage
			// 当影片输出的时候，整个影片相对浏览器的左上方对齐
			stage.align=StageAlign.TOP_LEFT;
			// 影片不会跟随浏览的尺寸大小而发生缩放。
			stage.scaleMode=StageScaleMode.NO_SCALE;
			//stage.quality = High;
			//this.scaleX = 0.5;
			createTextField();
			// Initialise Papervision3D
			init3D();

			// Create the 3D objects
			createScene();
      		// Listen to mouse up and down events on the stage
      			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			// Initialise Event loop
			// 为场景注册一个事件监听器，每当场景ENTER_FRAME的时候，就执行一次loop函数
			// ,ENTER_FRAME的频率就是输出影片时设置的每秒帧数。
			this.addEventListener(Event.ENTER_FRAME,loop);

		}
		private function init3D():void {

			// create viewport
			viewport=new Viewport3D(80000,60000,true,false);
            //viewport.graphics.lineStyle(2, 0xffffff);
            //viewport.graphics.drawRect(0, 0, viewport.viewportWidth, viewport.viewportHeight);
            //viewport.x=stage.stageWidth/2-viewport.viewportWidth/2;
            //viewport.y=stage.stageHeight/2-viewport.viewportHeight/2;
            			
			addChild(viewport);

			// Create new camera with fov of 60 degrees (= default value)
			camera=new Camera3D();

			// initialise the camera position (default = [0, 0, -1000])
			//camera.ortho = true;
			//camera.x = -100;
			//camera.y = -5000;
			camera.z = -200000;
			camera.orbit(60,-60);
			//camera.zoom = 0.8;
			camera.focus = 50;

			// target camera on origin
			camera.target=DisplayObject3D.ZERO;

			// Create a new scene where our 3D objects will be displayed
			scene=new Scene3D();

			// Create new renderer
			renderer=new BasicRenderEngine  ;
			//renderer = new QuadrantRenderEngine(QuadrantRenderEngine.CORRECT_Z_FILTER);

		}

		private function createScene():void {

			// First object : a sphere

			// Second object : x-, y- and z-axis

			// Create a default line material and a Lines3D object (container for Line3D objects)
			var defaultMaterial:LineMaterial=new LineMaterial(0xFFFFFF);
			axes=new Lines3D(defaultMaterial);

			// Create a different colour line material for each axis
			var xAxisMaterial:LineMaterial=new LineMaterial(0xFF0000);	// FF0000,red
			var yAxisMaterial:LineMaterial=new LineMaterial(0xFFFF00);	// FFFF00,yello
			var zAxisMaterial:LineMaterial=new LineMaterial(0x0000FF);	// 0000FF,blue

			// Create a origin vertex
			var origin:Vertex3D=new Vertex3D(0,0,0);

			// Create a new line (length 100) for each axis using the different materials and a width of 2.
			var xAxis:Line3D=new Line3D(axes,xAxisMaterial,1,origin,new Vertex3D(50000,0,0));
			var yAxis:Line3D=new Line3D(axes,yAxisMaterial,1,origin,new Vertex3D(0,50000,0));
			var zAxis:Line3D=new Line3D(axes,zAxisMaterial,1,origin,new Vertex3D(0,0,50000));

			// Add lines to the Lines3D container
			axes.addLine(xAxis);
			axes.addLine(yAxis);
			axes.addLine(zAxis);
			scene.addChild(axes);

           var _coneX:Cone =new Cone(new ColorMaterial(0x0000FF,0.5),800,3200,3,1);//new ColorMaterial(0xff0000,0.5)
            scene.addChild(_coneX);
            _coneX.z=50000+1600;
            //_coneX.roll(-90);
            _coneX.pitch(90);
            			
        	var p:Plane;
          	p = createPlane(80, 80, "X",new TextFormat(null, 58), AntiAliasType.NORMAL, false, false);
          	//p.rotationX -=90;
          	p.rotationY -=180;
          	//p.rotationZ -=270;
          	p.x = 50000 + 2500;
          	p.scale = 30;
          	//p.y = 400;
          	//p.z = z;     
          				            
			// 创建一个线条材质
            var materialA:ColorMaterial = new ColorMaterial(0x56526A);
            var materialB:ColorMaterial = new ColorMaterial(0x6A6A86);
            var material:ColorMaterial = materialA;

			// 创建一个 128 * 128 的平面                
 			for(var iX:int=1;iX<=5;iX++)
			{
				material = (material == materialA)?materialB:materialA;
				for(var iZ:int=1;iZ<=4;iZ++)
				{
					material = (material == materialA)?materialB:materialA;
					material.doubleSided = true;
					var plane:Plane = new Plane( material, 10000, 9000, 10,10);
		            plane.rotationX -=90;
		            plane.x = 10000/2+(iX-1)*10000;
		            plane.z = 9000/2+(iZ-1)*9000;
		            //plane.moveForward(64);
		            plane.rotationZ -=180;
		            scene.addChild(plane);			
				}
			}   
			
			// 创建一个 128 * 128 的平面                
 			for(var iX:int=1;iX<=5;iX++)
			{
				material = (material == materialA)?materialB:materialA;
				for(var iY:int=1;iY<=2;iY++)
				{
					material = (material == materialA)?materialB:materialA;
					var plane:Plane = new Plane( material, 10000, 9000, 10, 10);
		            plane.rotationY -=180;
		            plane.x = 10000/2+(iX-1)*10000;
		            plane.y = 9000/2+(iY-1)*9000;
		            //plane.moveForward(64);
		            plane.rotationZ -=180;
		            scene.addChild(plane);			
				}
			}   
 
			var materialList:MaterialsList = new MaterialsList();
			 
			//六个面的材质        
			materialList.addMaterial(new ColorMaterial(0xFF0000), "top");
			materialList.addMaterial(new ColorMaterial(0xFF000), "bottom");
			materialList.addMaterial(new ColorMaterial(0x0000FF), "front");
			materialList.addMaterial(new ColorMaterial(0xFF000), "back");
			materialList.addMaterial(new ColorMaterial(0xFFAE00), "left");
			materialList.addMaterial(new ColorMaterial(0xFFAE00), "right");
			 
			var materialList1:MaterialsList = new MaterialsList();
			 
			//六个面的材质        
			materialList1.addMaterial(new ColorMaterial(0xff69b4), "top");
			materialList1.addMaterial(new ColorMaterial(0xFF0A00), "bottom");
			materialList1.addMaterial(new ColorMaterial(0xffe4c4), "front");
			materialList1.addMaterial(new ColorMaterial(0xFF0A00), "back");
			materialList1.addMaterial(new ColorMaterial(0xFF0A00), "left");
			materialList1.addMaterial(new ColorMaterial(0x5F9EA0), "right");

			var cw:int = 500;
			var cd:int = 500;
			var ch:int;
			for(var i:int=1;i<=5000;i++)
			{
				ch = 5000*Math.random();
				
				var cube1:Cube = new Cube(materialList1, cw, cd, ch, 1, 1, 1);
				//cube1.z = cw/2 + (i-1)*(cw + 30);
				cube1.z = 4*9000*Math.random();
				cube1.y = ch/2;
				cube1.x = cd/2 + 50000*Math.random();
				//cube1.moveForward(28*i + 50);
				scene.addChild(cube1);
			}

			
            //camera.x= -100;
			//camera.y= -500;
			//camera.z= -100;

			//axes.rotationX -=90;
//			axes.rotationZ -=90;
//			axes.rotationY -=90;
//						
			
//			plane.rotationX -=90;
//			plane.rotationY -=90;
//			
//			cube.rotationZ -=90;
//			cube.rotationY -=90;		
		}

		private function loop(event:Event):void {
//			axes.rotationX +=2;
//			axes.rotationY +=2;
//						
//			plane.rotationX +=2;
//			plane.rotationY +=2;
//			
//			cube.rotationX +=2;
//			cube.rotationY +=2;
			//cube.y +=0.5;
      // If the mouse button has been clicked then update the camera position
      if (doRotation) {

        // convert the change in mouse position into a change in camera angle
        var dPitch:Number = (mouseY - lastMouseY) / 2;
        var dYaw:Number = (mouseX - lastMouseX) / 2;

        // update the camera angles
        cameraPitch -= dPitch;
        cameraYaw -= dYaw;
        // limit the pitch of the camera
        if (cameraPitch <= 0) {
          cameraPitch = 0.1;
        } else if (cameraPitch >= 180) {
          cameraPitch = 179.9;
        }

        // reset the last mouse position
        lastMouseX = mouseX;
        lastMouseY = mouseY;

        // reposition the camera
        camera.orbit(cameraPitch, cameraYaw);
      }			
			// Render the 3D scene
			renderer.renderScene(scene,camera,viewport);
			
		}
		
    // called when mouse down on stage
    private function onMouseDown(event:MouseEvent):void {
      doRotation = true;
      lastMouseX = event.stageX;
      lastMouseY = event.stageY;
    }

    // called when mouse up on stage
    private function onMouseUp(event:MouseEvent):void {
      doRotation = false;
    }
    
        public function createPlane(width:Number=100, height:Number=100, message:String="Text goes here", format:TextFormat=null, alias:String = AntiAliasType.NORMAL , transparent:Boolean = false, smooth:Boolean = false):Plane{
        	
        	var mc:MovieClip = new MovieClip();
        	var txt:TextField = new TextField();
        	txt.wordWrap = true;
        	txt.width = width;
        	txt.height = height;
        	txt.multiline = true;
        	txt.htmlText= message;
        	
        	txt.autoSize = TextFieldAutoSize.CENTER;
        	if(format)
        		txt.setTextFormat(format);
        	
        	txt.antiAliasType = alias;
        
        	mc.graphics.beginFill(0x538C59);
        	mc.graphics.drawRect(0,0,width,height);
        	mc.graphics.endFill();
        
        	mc.addChild(txt);
        	
        	var mat:MovieMaterial = new MovieMaterial(mc, transparent, false, true);
        	mat.doubleSided = true;
        	mat.smooth = smooth;
        	mat.tiled = true;
        	
        	
        	var p:Plane = new Plane(mat, 80, 80);
        	scene.addChild(p);
        	
        	return p;

        }   
        
        private function createTextField() : void{
        
            var textNote:TextField = new TextField();
            textNote.width = 600;
            textNote.height =200;
            textNote.selectable=false;
            textNote.x = 50;
            textNote.y = 30;
            textNote.multiline = true;
            textNote.htmlText = "<font color = '#ffffff' size='16' & gt;<b>X-AXIS</b>(red)、<b>Y-AXIS</b> (green)、<b>Z-AXIS</b> (blue) <br>Press the buttons to start and stop rotation over the <b>Z-AXIS</b>." + "<br><br>The left cube will rotate over its own (blue) Z-AXIS.<br>The right cube will rotate over the (blue) Z-AXIS of the <b>parent cube</b>."+"<br><br> Drag the mouse to move the camera";
            //scene.addChild(textNote);
        }         
	}
}