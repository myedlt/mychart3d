package {
 
  import flash.display.BlendMode;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.utils.getTimer;
 
  import org.papervision3d.events.FileLoadEvent;
  import org.papervision3d.events.InteractiveScene3DEvent;
  import org.papervision3d.lights.PointLight3D;
  import org.papervision3d.materials.BitmapMaterial;
  import org.papervision3d.materials.MovieMaterial;
  import org.papervision3d.materials.shadematerials.GouraudMaterial;
  import org.papervision3d.materials.shaders.GouraudShader;
  import org.papervision3d.materials.shaders.ShadedMaterial;
  import org.papervision3d.materials.utils.MaterialsList;
  import org.papervision3d.objects.DisplayObject3D;
  import org.papervision3d.objects.parsers.DAE;
  import org.papervision3d.view.BasicView;

  public class Example009b extends BasicView {
 
    [Embed(source="/../assets/Cow.dae", mimeType="application/octet-stream")] private var CowDAE:Class;
    [Embed(source="/../assets/Cow.jpg")] private var CowBitmapImage:Class;

    private var light:PointLight3D;
   
    private var shadedMaterialCow:DAE;
    private var gouraudCow:DAE;
    private var texturedCow:DAE;
    private var allCows:DisplayObject3D;
   
    private var doRotation:Boolean = false;
    private var lastMouseX:int;
    private var lastMouseY:int;
    private var cameraPitch:Number = 60;

    private var cameraYaw:Number = -60;
     
    private var fpsText:TextField;
    private var textFormat:TextFormat;
 
    private var frames:Number = 0;
    private var lastTimeMS:Number = 0;
 
    private var doSimple:Boolean = false;
 
    public function Example009b() {
      super(0, 0, true, true);
     
      // Initialise Papervision3D
      init3D();
     
      // Create the 3D objects
      createScene();

      // create the frame rate counter label
      createFPSLabel();

      // Listen to mouse up and down events on the stage
      stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

      // Start rendering the scene
      startRendering();
    }
   
    private function init3D():void {
      // position the camera
      camera.z = -500;
      camera.fov = 60;
      camera.orbit(cameraPitch, cameraYaw);
    }
   
    private function createFPSLabel():void {
      // create text and format to display current fps
      textFormat = new TextFormat();
      textFormat.size = 20;
      textFormat.font = "Arial";
     
      fpsText = new TextField();
      fpsText.x = 50;
      fpsText.y = 50;
      fpsText.textColor = 0xFFFFFF;
      fpsText.text = "";
      fpsText.setTextFormat(textFormat);
      fpsText.autoSize = TextFieldAutoSize.LEFT;
     
      stage.addChild(fpsText);
    }

    private function createScene():void {

      // Specify a point light source and its location
      light = new PointLight3D(true);
      light.x = 500;
      light.y = 300;
      light.z = -500;
      scene.addChild(light);

      // create a display object to group all created cows
      allCows = new DisplayObject3D();
      scene.addChild(allCows);

      // create a cow with a shaded material
      createSimpleShadedDAE();
     
      // create a shaded cow by blending two different rendered objects
      createNiceShadedDAE();
    }

    private function createSimpleShadedDAE():void {

      // create BitmapMaterial from texture map
      var cowBitmapMaterial:BitmapMaterial = new MovieMaterial(new CowBitmapImage(), true);
 
      // create a ShadedMaterial using a Gouraud shader
      var shader:GouraudShader = new GouraudShader(light, 0xFFFFFF, 0x333333);
      var shadedMaterial:ShadedMaterial = new ShadedMaterial(cowBitmapMaterial, shader);
      shadedMaterial.interactive = true;
     
      // Material list linked to material symbol name in dae
      var mainMaterials:MaterialsList = new MaterialsList();
      mainMaterials.addMaterial(shadedMaterial, "mat0");

      // create a new dae and perform actions when loaded
      shadedMaterialCow = new DAE(false);
      shadedMaterialCow.addEventListener(FileLoadEvent.LOAD_COMPLETE, function onLoad(event:Event):void {
        shadedMaterialCow.moveDown(100);
        shadedMaterialCow.scale = 100;
       
        // add cow to scene when loaded
        allCows.addChild(shadedMaterialCow);
       
        // recursively add event listeners to dae and all children
        addEventListeners(shadedMaterialCow, InteractiveScene3DEvent.OBJECT_CLICK, toggleRendering);
      });
     
      // load the dae from the embedded structure and replace the materials
      shadedMaterialCow.load(new XML(new CowDAE()), mainMaterials);

    }
   
    private function createNiceShadedDAE():void {

      // create a simple texture mapped material for the embedded png
      var cowBitmapMaterial:BitmapMaterial = new MovieMaterial(new CowBitmapImage(), true);
      cowBitmapMaterial.interactive = true;
     
      // add the material to a material list corresponding to the dae
      var bitmapMaterials:MaterialsList = new MaterialsList();
      bitmapMaterials.addMaterial(cowBitmapMaterial, "mat0");

      // create a new dae and perform actions when loaded
      texturedCow = new DAE(false);
      texturedCow.addEventListener(FileLoadEvent.LOAD_COMPLETE, function onLoad(event:Event):void {
        texturedCow.moveDown(100);
        texturedCow.scale = 100;

        // set the dae to initially not be visible
        texturedCow.visible = false;
       
        // add to the scene
        allCows.addChild(texturedCow);
       
        // listen to events (applies to all children of dae as well)
        addEventListeners(texturedCow, InteractiveScene3DEvent.OBJECT_CLICK, toggleRendering);
       
      });

      // load the dae from the embedded structure and replace the materials
      texturedCow.load(new XML(new CowDAE()), bitmapMaterials);

      // create a simple Gouraud shaded material and add to list corresponding to dae
      var gouraudMaterial:GouraudMaterial = new GouraudMaterial(light, 0xFFFFFF, 0x333333);
      var shadedMaterials:MaterialsList = new MaterialsList();
      shadedMaterials.addMaterial(gouraudMaterial, "mat0");

      // create a new dae and perform actions when loaded
      gouraudCow = new DAE(false);
      gouraudCow.addEventListener(FileLoadEvent.LOAD_COMPLETE, function onLoad(event:Event):void {
        gouraudCow.scale = 100;
        gouraudCow.moveDown(100);

        // set the dae to initially not be visible
        gouraudCow.visible = false;
 
        // add to the scene
        allCows.addChild(gouraudCow);

        // change the rendering so that it is blended with other rendered objects
        viewport.getChildLayer(gouraudCow).blendMode = BlendMode.MULTIPLY; 
      });
     
      // load the dae from the embedded structure and replace the materials
      gouraudCow.load(new XML(new CowDAE()), shadedMaterials);

    }

    // used to ensure that all children in a dae listen to events
    private function addEventListeners(displayObject:DisplayObject3D, eventType:String, listener:Function):void {
      // add listener to DisplayObect
      displayObject.addEventListener(eventType, listener);
     
      // add listener to all contained childred
      for each(var child:DisplayObject3D in displayObject.children) {
        addEventListeners(child, eventType, listener);
      }
    }
   
    // toggles between the two rendering techniques
    private function toggleRendering(event:InteractiveScene3DEvent):void {
      texturedCow.visible = !texturedCow.visible;
      gouraudCow.visible = !gouraudCow.visible;
      shadedMaterialCow.visible = !shadedMaterialCow.visible;
    }

    override protected function onRenderTick(event:Event=null):void {
     
      // rotate the scene
      allCows.yaw(-1);
     
      // calculate the frame rate
      calculateFrameRate();

      // update the camera position
      updateCamera();
   
      // call the renderer
      super.onRenderTick(event);
    }
   
    private function calculateFrameRate():void {

      // calculate the time elapsed since the last calculation     
      var currentTimeMS:Number = getTimer();
      var elapsedTimeMS:Number = currentTimeMS - lastTimeMS;

      // if a second has elapsed then calculate the fps
      if (elapsedTimeMS >= 1000) {
        fpsText.text = frames.toString() + " fps";
        fpsText.setTextFormat(textFormat);
       
        // reset the counter
        lastTimeMS = currentTimeMS;
        frames = 0;
     
      } else {
        // increment the counter
        frames++;
      }
     
    }
   
    private function updateCamera():void {
     
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
   
  }
}
