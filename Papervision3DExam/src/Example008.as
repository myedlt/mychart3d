package {
 
  import caurina.transitions.Tweener;
 
  import flash.display.MovieClip;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.media.Video;
  import flash.net.NetConnection;
  import flash.net.NetStream;
 
  import org.papervision3d.core.proto.MaterialObject3D;
  import org.papervision3d.events.InteractiveScene3DEvent;
  import org.papervision3d.lights.PointLight3D;
  import org.papervision3d.materials.MovieMaterial;
  import org.papervision3d.materials.VideoStreamMaterial;
  import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
  import org.papervision3d.materials.utils.MaterialsList;
  import org.papervision3d.objects.DisplayObject3D;
  import org.papervision3d.objects.primitives.Cube;
  import org.papervision3d.view.BasicView;

  [SWF(backgroundColor="#222222")]

  public class Example008 extends BasicView {
 
    private static const ORBITAL_RADIUS:Number = 400;

    [Embed(source="/../assets/DrawTool.swf")]
    private var DrawTool:Class;

    private var exampleMovie:MovieClip;

     private var videoURL:String = "http://www.tartiflop.com/pv3d/FirstSteps/Radiohead_HOC.flv";

    private var video:Video;
    private var stream:NetStream;
    private var connection:NetConnection;

    private var objectGroup:DisplayObject3D;
    private var light:PointLight3D;
    private var currentActiveObject:DisplayObject3D = null;
   
    private var projectors:Array = new Array();
   
    private var doRotation:Boolean = false;
    private var canRotate:Boolean = true;
    private var lastMouseX:int;
    private var lastMouseY:int;
    private var cameraPitch:Number = 60;
    private var cameraYaw:Number = -60;
   
    public function Example008() {
      super(0, 0, true, true);

      // Initialise Papervision3D
      init3D();

      // create video stream for VideoStreamMaterial
      createVideoStream();

      // create the 3D Objects
      createScene();

      // Listen to mouse up and down events on the stage
      stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

      // Start rendering the scene
      startRendering();
    }
   
    private function init3D():void {
      // position the camera
      camera.z = -1000;
      camera.fov = 60;
      camera.orbit(cameraPitch, cameraYaw);
    }

    private function createVideoStream():void {
      // Create a NetConnection. 2-way connection not necessary: connect to null
      connection = new NetConnection();
      connection.connect(null);

      // Create a new NetStream to obtain the flv stream. Ignore client messages so use a simple Object
      stream = new NetStream(connection);
      stream.client = new Object();
     
      // create a new video player
      video = new Video();
     
      // start streaming the video from the given URL and play it on the video player
      stream.play(videoURL);
      video.attachNetStream(stream);
    }

    private function createScene():void {
      // Specify a point light source and its location
      light = new PointLight3D();
      light.x = 400;
      light.y = 1000;
      light.z = -400;

      // Create a 3D object to group the projectors
      objectGroup = new DisplayObject3D();

      // Create a new video stream material with precise rendering.
      var videoMaterial:VideoStreamMaterial = new VideoStreamMaterial(video, stream, true);
      addProjector(videoMaterial);
         
      // Create a new flash movie material from an actionscript class (not transparent, animated and precise rendering)
      var movieMaterial1:MovieMaterial = new MovieMaterial(new Example006b(), false, true, true);
      addProjector(movieMaterial1);

      // Create a new flash movie material from an embedded flash movie (not transparent, animated and precise rendering)
      var movieMaterial2:MovieMaterial = new MovieMaterial(new DrawTool(), false, true, true);
      addProjector(movieMaterial2);
   
      // add the object group and light
      scene.addChild(objectGroup);
      scene.addChild(light);

      // set up the projector positions in the scene
      organiseProjectors();
    }
   
    private function addProjector(material:MovieMaterial):void {
      // materials are smooth rendred, interactive and resize to the 3D object.
      material.smooth = true;
      material.interactive = true;
      material.allowAutoResize = true;

      // simple flat shaded material as default for the projector
      var flatShadedMaterial:MaterialObject3D = new FlatShadeMaterial(light, 0x554D33, 0x1A120C);
      flatShadedMaterial.interactive = true;
     
      // Material list with MovieMaterial used on the front, the rest being flat shaded
      var materialList:MaterialsList = new MaterialsList({"all":flatShadedMaterial, "front":material});

      // create a new interactive projector
      var projector:Cube = new Cube(materialList, 320, 10, 240);
      projector.addEventListener(InteractiveScene3DEvent.OBJECT_DOUBLE_CLICK, onMouseDoubleClickOnObject);
      projector.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, onMouseOverObject);
      projector.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, onMouseOutObject);

      // add the projector to the scene, being part of the object group
      objectGroup.addChild(projector);
     
      // store projector in an array
      projectors.push(projector);
    }
   
    private function organiseProjectors():void {
      // calculate angle between projectors
      var theta:Number = 360 / projectors.length;
     
      // set up each projector so that they are distributed in a circle and facing outwards
      for (var i:int = 0; i < projectors.length; i++) {
        var projector:Cube = projectors[i];
       
        // specifc angle for projector
        var angle:Number = i * theta - 180;
        var angleRadians:Number = angle * 2 * Math.PI / 360.;

        // position of projector
        var x:Number = Math.sin(angleRadians) * ORBITAL_RADIUS;
        var z:Number = Math.cos(angleRadians) * ORBITAL_RADIUS;

        // create tween to position, rotate and scale projector smoothly over 1 second
        Tweener.addTween(projector, {x:x, y:-150, z:z, rotationY:angle, scale:0.8, time:1, transition:"linear" });
      }
    }
   
    override protected function onRenderTick(event:Event=null):void {
      // rotate the object group: angle kept between 0 and 360 degrees
      objectGroup.rotationY += 1;
      if (objectGroup.rotationY > 360) {
        objectGroup.rotationY -= 360;
      }
     
      // if an object is active (double clicked) rotate it in the opposite direction
      // to the group so that it is stationary
      if (currentActiveObject != null) {
        currentActiveObject.rotationY -=1;
        if (currentActiveObject.rotationY < 0) {
          currentActiveObject.rotationY += 360;
        }
      }
     
      // If the mouse button has been clicked then update the camera position     
      if (doRotation && canRotate) {
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
     
      // call the renderer
      super.onRenderTick(event);
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
   
    // called when mouse double clicked on a projector
    private function onMouseDoubleClickOnObject(event:InteractiveScene3DEvent):void {
      var object:DisplayObject3D = event.displayObject3D;
     
      // determine if the object is to be activated (placed in center) or deactivated
      if (object == currentActiveObject) {
        deactivate(object);
      } else {
        activate(object);
      }
    }
   
    // disable camera rotation when mouse is over a projector
    private function onMouseOverObject(event:InteractiveScene3DEvent):void {
      canRotate = false;
    }
   
    // re-enable camera rotation when mouse is out of a projector
    private function onMouseOutObject(event:InteractiveScene3DEvent):void {
      canRotate = true;
    }
   
    // places a projector in the center
    private function activate(object:DisplayObject3D):void {
      // remove projector from rotating projectors array
      projectors.splice(projectors.indexOf(object), 1);
     
      // if a projector is active already, put it back in the array of rotating projectors
      if (currentActiveObject != null) {
        projectors.push(currentActiveObject);
      }
     
      // create a tween to place selected projector in the center
      Tweener.addTween(object, {y:100, x:0, z:0, rotationY:-objectGroup.rotationY, scale:2, time:1, transition:"linear" });
      currentActiveObject = object;

      // re-organise the other projectors
      organiseProjectors();     
    }
   
    // puts an activated projector back into the main pack of rotating projectors
    private function deactivate(object:DisplayObject3D):void {
      // put the projector back into the rotating projectors array
      projectors.push(currentActiveObject);
      currentActiveObject = null; 
   
      // re-organise all projectors
      organiseProjectors();     
    }
   
  }
}
