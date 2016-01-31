package instances;

import kha.Framebuffer;
import kha.Color;
import kha.graphics4.CullMode;
import kha.math.Random;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Scheduler;
import kha.Shaders;
import kha.Assets;
import kha.graphics4.CompareMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.math.Matrix4;

class Instances {

	static var instancesX : Int = 100;
	static var instancesZ : Int = 100;

	var cameraStart : Vector4;
	var view : Matrix4;
	var projection : Matrix4;
	var mvp : Matrix4;
	
	var ins : Array<Dynamic>;
	
	var vertexBuffers: Array<VertexBuffer>;
	var indexBuffer: IndexBuffer;
	var pipeline: PipelineState;



	public function createInstances(type : String, iX = 100, iZ = 100) {
		Random.init(Std.random(403));
		instancesX = iX;
		instancesZ = iZ;
		// Initialize data, not relevant for rendering
		ins = new Array<Dynamic>();
		for (x in 0...instancesX) {
			for (z in 0...instancesZ) {
				// Span x/z grid, center on 0/0
				var pos = new Vector3(x - (instancesX - 1) / 2, 0, z - (instancesZ - 1) / 2);
				switch (type) {
					case 'cylinder':
						ins.push(new Cylinder(pos));
				}
			}
		}
	}

	public function createMesh(type : String) {
		return switch (type) {
			case 'cylinder': new CylinderMesh(32);
			case _: null;
		}
	}

	public function setupPipeline(structures : Array<VertexStructure>, f : Dynamic, v : Dynamic) {
	
		// Setup pipeline
		pipeline = new PipelineState();
		pipeline.fragmentShader = f;
		pipeline.vertexShader = v;
		pipeline.inputLayout = structures;
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
		pipeline.cullMode = CullMode.CounterClockwise;
		pipeline.compile();	

	}

	public function fillStructure(mesh : Dynamic) :  Array<VertexStructure> {
	
		var structures = new Array<VertexStructure>();
		
		structures[0] = new VertexStructure();
        structures[0].add("pos", VertexData.Float3);
		
		// Vertex buffer
		vertexBuffers = new Array();
		vertexBuffers[0] = new VertexBuffer(
			Std.int(mesh.vertices.length / 3),
			structures[0],
			Usage.StaticUsage
		);
		
		var vbData = vertexBuffers[0].lock();
		for (i in 0...vbData.length) {
			vbData.set(i, mesh.vertices[i]);
		}
		vertexBuffers[0].unlock();
		
		// Index buffer
		indexBuffer = new IndexBuffer(
			mesh.indices.length,
			Usage.StaticUsage
		);
		
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = mesh.indices[i];
		}
		indexBuffer.unlock();
		
		// Color structure, is different for each instance
		structures[1] = new VertexStructure();
        structures[1].add("col", VertexData.Float3);
		
		vertexBuffers[1] = new VertexBuffer(
			ins.length,
			structures[1],
			Usage.StaticUsage,
			1 // changed after every instance, use i higher number for repetitions
		);
		
		var oData = vertexBuffers[1].lock();
		for (i in 0...ins.length) {
			oData.set(i * 3, 1);
			oData.set(i * 3 + 1, 0.75 + Random.getIn(-100, 100) / 500);
			oData.set(i * 3 + 2, 0);
		}
		vertexBuffers[1].unlock();
		
		// Transformation matrix, is different for each instance
		structures[2] = new VertexStructure();
		structures[2].add("m", VertexData.Float4x4);
		vertexBuffers[2] = new VertexBuffer(
			ins.length,
			structures[2],
			Usage.StaticUsage,
			1 
		);
		return structures;
	}

	public function new(type : String, iX = 100, iZ = 100) {

		createInstances(type, iX, iZ);

		cameraStart = new Vector4(0, 5, 10);
		projection = Matrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);
		
		var mesh = createMesh(type);
		
		var structures = fillStructure(mesh);
		
		switch (type) {
			case 'cylinder': {
				var f =  Shaders.cylinder_frag;
				var v = Shaders.cylinder_vert;				
				setupPipeline(structures, f, v);
			}
			case _: null;
		}

	}

	public function render(frame : Framebuffer) {
		
		var g = frame.g4;
		
		// Move camera and update view matrix
		var newCameraPos = Matrix4.rotationY(Scheduler.time() / 4).multvec(cameraStart);
		view = Matrix4.lookAt(new Vector3(newCameraPos.x, newCameraPos.y, newCameraPos.z), // Position in World Space
			new Vector3(0, 0, 0), // Looks at the origin
			new Vector3(0, 1, 0) // Up-vector
		);
		
		var vp = Matrix4.identity();
		vp = vp.multmat(projection);
		vp = vp.multmat(view);
		
		// Fill transformation matrix buffer with values from each instance
		var mData = vertexBuffers[2].lock();
		for (i in 0...ins.length) {
			mvp = vp.multmat(ins[i].getModelMatrix());
			
			mData.set(i * 16 + 0, mvp._00);		
			mData.set(i * 16 + 1, mvp._01);		
			mData.set(i * 16 + 2, mvp._02);		
			mData.set(i * 16 + 3, mvp._03);		
			
			mData.set(i * 16 + 4, mvp._10);		
			mData.set(i * 16 + 5, mvp._11);		
			mData.set(i * 16 + 6, mvp._12);		
			mData.set(i * 16 + 7, mvp._13);		
			
			mData.set(i * 16 + 8, mvp._20);		
			mData.set(i * 16 + 9, mvp._21);		
			mData.set(i * 16 + 10, mvp._22);		
			mData.set(i * 16 + 11, mvp._23);		
			
			mData.set(i * 16 + 12, mvp._30);		
			mData.set(i * 16 + 13, mvp._31);		
			mData.set(i * 16 + 14, mvp._32);		
			mData.set(i * 16 + 15, mvp._33);		
		}		
		vertexBuffers[2].unlock();
		
        g.begin();
		g.clear(Color.fromFloats(1, 0.75, 0));
		g.setPipeline(pipeline);
		
		// Instanced rendering
		if (g.instancedRenderingAvailable()) {
			g.setVertexBuffers(vertexBuffers);
			g.setIndexBuffer(indexBuffer);
			g.drawIndexedVerticesInstanced(ins.length);
		}
		
		g.end();			
	}

	public function updateAll() {
		for (i in 0...ins.length) {
			ins[i].update();
		}
	}
}