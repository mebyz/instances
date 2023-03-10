package instances;

import kha.Assets;
import kha.Framebuffer;
import kha.Module;
import kha.Scheduler;
import kha.Shaders;
import kha.Texture;
import kha.graphics4.Graphics;
import kha.math.FastMatrix4;
import kha.math.Matrix4;
import kha.mesh.Mesh;
import kha.mesh.VertexData;
import kha.renderer.DrawPath;
import kha.renderer.TextureUnit;

import gltf.Asset;
import gltf.Material;
import gltf.Mesh as GLTFMesh;
import gltf.Primitive;
import gltf.TextureInfo;
import gltf.animation.Animation;
import gltf.animation.Sampler;
import gltf.animation.Channel;
import gltf.animation.Interpolator;

class AnimatedModel {
    var asset:Asset;
    var meshes:Array<Mesh>;
    var animations:Array<Animation>;
    var currentAnimation:Int = 0;
    var currentAnimationTime:Float = 0;
    var currentAnimationFrame:Int = 0;
    var currentAnimationLoop:Bool = true;

    public function new(assetPath:String) {
        asset = Assets.loadJson(assetPath);

        var scene = asset.getDefaultScene();
        var nodes = scene.getNodes();

        // Load meshes
        meshes = [];
        for (node in nodes) {
            var mesh = node.getMesh();
            if (mesh != null) {
                meshes.push(loadMesh(mesh));
            }
        }

        // Load animations
        animations = asset.getAnimations();
    }

    private function loadMesh(gltfMesh:GLTFMesh):Mesh {
        var vertices = new VertexData();
        var indices = gltfMesh.getIndices();
        var positionAccessor = gltfMesh.getAccessor(gltfMesh.getPrimitive(0).getAttributes().getPosition());
        var normalAccessor = gltfMesh.getAccessor(gltfMesh.getPrimitive(0).getAttributes().getNormal());
        var texCoordAccessor = gltfMesh.getAccessor(gltfMesh.getPrimitive(0).getAttributes().getTexCoord());

        for (i in 0...positionAccessor.getCount()) {
            var position = positionAccessor.getVec3(i);
            var normal = normalAccessor.getVec3(i);
            var texCoord = texCoordAccessor.getVec2(i);

            vertices.add(position.x, position.y, position.z, normal.x, normal.y, normal.z, texCoord.x, texCoord.y);
        }

        var mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.indices = indices;
        mesh.setPrimitiveType(Primitive.TriangleList);
        mesh.compile(Shaders.standard);

        return mesh;
    }

    public function update(dt:Float) {
        if (currentAnimationLoop) {
            currentAnimationTime += dt;
        }

        var animation = animations[currentAnimation];
        var channels = animation.getChannels();

        for (channel in channels) {
            var sampler = animation.getSampler(channel.getSampler());
            var time = currentAnimationTime % sampler.getInput().last();
            var value = sampler.getOutput().interpolate(time, channel.getTargetPath(), channel.getInterpolation());

            var targetNode = asset.getNode(channel.getTargetNode());
            var targetPath = channel.getTargetPath();
            var targetMesh = targetNode.getMesh();
            if (targetMesh != null) {
                updateMesh(targetMesh, value);
            }
        }
    }

    private function updateMesh(mesh:GLTFMesh, matrix:Matrix4) {
        var vertices = mesh.getPrimitive(0).getVertexData();
        var positionAccessor = mesh.getAccessor(mesh.getPrimitive(0).getAttributes().getPosition());
        var normalAccessor = mesh.getAccessor(mesh.getPrimitive(0).getAttributes().getNormal());
        var texCoordAccessor = mesh.getAccessor(mesh.getPrimitive(0).getAttributes().getTexCoord());

        for (i in 0...positionAccessor.getCount()) {
            var position = positionAccessor.getVec3(i);
            var normal = normalAccessor.getVec3(i);
            var texCoord = texCoordAccessor.getVec2(i);
    
            var vertexMatrix = matrix.multiply(new FastMatrix4(position.x, position.y, position.z, 1));
            position.x = vertexMatrix.get(0, 3);
            position.y = vertexMatrix.get(1, 3);
            position.z = vertexMatrix.get(2, 3);
    
            var normalMatrix = matrix.inverse().transpose();
            var normalVector = new FastMatrix4(normal.x, normal.y, normal.z, 0);
            normalVector = normalMatrix.multiply(normalVector);
            normal.x = normalVector.get(0, 0);
            normal.y = normalVector.get(1, 0);
            normal.z = normalVector.get(2, 0);
    
            vertices.set(i, position.x, position.y, position.z, normal.x, normal.y, normal.z, texCoord.x, texCoord.y);
        }
    
        mesh.getPrimitive(0).setVertexData(vertices);
        mesh.getPrimitive(0).compile(Shaders.standard);
    }
    
    public function playAnimation(animationIndex:Int, loop:Bool = true) {
        currentAnimation = animationIndex;
        currentAnimationTime = 0;
        currentAnimationFrame = 0;
        currentAnimationLoop = loop;
    }
    
    public function render(graphics:Graphics, transform:Matrix4) {
        for (mesh in meshes) {
            var material = mesh.getPrimitive(0).getMaterial();
            var textureInfo = material.getBaseColorTexture();
            var texturePath = textureInfo.getTexture().getSource().getPath();
            var texture = Assets.loadTexture(texturePath);
            var textureUnit = new TextureUnit(texture);
            var modelMatrix = transform;
    
            graphics.setShaderParameter("texture", textureUnit);
    
            var drawPath = new DrawPath();
            drawPath.mesh = mesh;
            drawPath.transform = modelMatrix;
            drawPath.texture = texture;
            drawPath.program = Shaders.standard;
    
            graphics.draw(drawPath);
        }
    }
}

/*

Here's a brief explanation of what this code does:

- The `AnimatedModel` class loads a glTF 2.0 3D model file using the `gltf` library and extracts its meshes and animations.
- The `loadMesh` function converts a glTF mesh into a Kha mesh.
- The `update` function updates the meshes of the model based on the current animation time.
- The `playAnimation` function sets the current animation and loop flag.
- The `render` function renders the meshes of the model using the Kha graphics API.

To use this class, you can create an instance of it and call its `playAnimation` function to start playing an animation. You can then call its `update` and `render` functions every frame to update and render the model. Here's an example usage:

```haxe
class Main {
    var model:AnimatedModel;

    public function new() {
        model = new AnimatedModel("models/robot.glb");
        model.playAnimation(0);
    }

    public function update(dt:Float) {
        model.update(dt);
    }

    public function render(framebuffer:Framebuffer) {
        var graphics = framebuffer.g4;
        var transform = new Matrix4();
        model.render(graphics, transform);
    }

    static function main() {
        var app = new Main();
        Module.init('MyApp', app.update, app.render);
        Scheduler.addTimeTask(
        function(dt:Float) {
            app.update(dt);
        }, 0);
    }
}

    */