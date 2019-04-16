package {

	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.Collada;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.parsers.KMZ;
	import org.papervision3d.view.BasicView;

	public class Example009a extends BasicView {
		[Embed(source="/../assets/Cow.dae", mimeType="application/octet-stream")]
		private var CowDAE:Class;
		
		[Embed(source="/../assets/Cow.jpg")]
		private var CowBitmapImage:Class;

		private var light:PointLight3D;

		private var doRotation:Boolean=false;
		private var lastMouseX:int;
		private var lastMouseY:int;
		private var cameraPitch:Number=60;
		private var cameraYaw:Number=-60;

		public function Example009a() {
			super(0,0,true,true);

			// Initialise Papervision3D
			init3D();

			// Create the 3D objects
			createScene();

			// Listen to mouse up and down events on the stage
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);

			// Start rendering the scene
			startRendering();
		}
		private function init3D():void {
			// position the camera
			camera.z=-700;
			camera.fov=60;
			camera.orbit(cameraPitch,cameraYaw);
		}
		private function createScene():void {

			// create new Collada from URL, using original materials and scaled to 50%
			var cow:Collada=new Collada("http://www.tartiflop.com/pv3d/FirstSteps/collada/cow.dae",null,0.5);
			cow.moveDown(100);
			cow.moveBackward(200);
			cow.yaw(90);
			scene.addChild(cow);

			// create a texture mapped material from embedded png
			var cowMaterial:BitmapMaterial=new MovieMaterial(new CowBitmapImage  ,true);

			// add the texture map to a material list corresponding to the material symbols in the dae
			var cowMaterials:MaterialsList=new MaterialsList  ;
			cowMaterials.addMaterial(cowMaterial,"mat0");

			// create a new Collada, specifying the materials we want to use
			var cow2:Collada=new Collada(new XML(new CowDAE  ),cowMaterials);
			cow2.moveRight(300);
			cow2.moveDown(100);
			scene.addChild(cow2);

			// create a new DAE that is animated and perform actions once it is loaded
			var seymour:DAE=new DAE(true);
			seymour.addEventListener(FileLoadEvent.LOAD_COMPLETE, function onLoad(event:Event):void {;
			seymour.scale = 20;
			seymour.moveForward(200);
			seymour.moveDown(100);
			scene.addChild(seymour);
			});

			// load the DAE from a specific URL
			seymour.load("http://www.tartiflop.com/pv3d/FirstSteps/collada/Seymour.dae");


			// create a new 3D object from a 3D google earth object file and perform actions when loaded
			var kmz:KMZ=new KMZ  ;
			kmz.addEventListener(FileLoadEvent.LOAD_COMPLETE, function onLoad(event:Event):void {;
			kmz.scale = 20;
			kmz.moveLeft(300);
			kmz.moveDown(100);
			scene.addChild(kmz);
			});

			// load kmz from a specific URL
			kmz.load("http://www.tartiflop.com/pv3d/FirstSteps/collada/thing.kmz");

		}

		override protected  function onRenderTick(event:Event=null):void {

			// update camera position
			updateCamera();

			// call the renderer
			super.onRenderTick(event);
		}
		private function updateCamera():void {

			// If the mouse button has been clicked then update the camera position     
			if (doRotation) {

				// convert the change in mouse position into a change in camera angle
				var dPitch:Number=mouseY - lastMouseY / 2;
				var dYaw:Number=mouseX - lastMouseX / 2;

				// update the camera angles
				cameraPitch-= dPitch;
				cameraYaw-= dYaw;
				// limit the pitch of the camera
				if (cameraPitch <= 0) {
					cameraPitch=0.1;
				} else if (cameraPitch >= 180) {
					cameraPitch=179.9;
				}
				// reset the last mouse position
				lastMouseX=mouseX;
				lastMouseY=mouseY;

				// reposition the camera
				camera.orbit(cameraPitch,cameraYaw);
			}
		}

		// called when mouse down on stage
		private function onMouseDown(event:MouseEvent):void {
			doRotation=true;
			lastMouseX=event.stageX;
			lastMouseY=event.stageY;
		}

		// called when mouse up on stage
		private function onMouseUp(event:MouseEvent):void {
			doRotation=false;
		}
	}
}