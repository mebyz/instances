package instances;
/*The MIT License (MIT)
Copyright (c) 2016 Christian Reuter
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/
import js.lib.Object;
import kha.math.Matrix3;
import kha.Assets;
import kha.Assets;
import kha.math.FastVector3;
import kha.math.Vector2;

class OMesh {
	public var pos: Array<FastVector3>;
	public var uv: Array<Vector2>;
	public var color: Array<Dynamic>;
	public var indices: Array<Int>;

	public function new() {
		pos = new Array<FastVector3>();
		uv = new Array<Vector2>();
		color = new Array<Dynamic>();
		indices = new Array<Int>();
	}
}

// Generates index and vertex data for a cylinder
class CylinderMesh {
	
	public var vertices: Array<Float>;
	public var indices: Array<Int>;
	
	public function generateBlade (center, vArrOffset, uv):OMesh {
	  var MID_WIDTH = 10 * 0.5;
	  var TIP_OFFSET = 0.1;
	  var height = 100 + (Math.random() * 10);
	
	  var yaw = Math.random() * Math.PI * 2;
	  var yawUnitVec = new FastVector3(Math.sin(yaw), 0, -Math.cos(yaw));
	  var tipBend = Math.random() * Math.PI * 2;
	  var tipBendUnitVec = new FastVector3(Math.sin(tipBend), 0, -Math.cos(tipBend));
	
	  // Find the Bottom Left, Bottom Right, Top Left, Top right, Top Center vertex positions
	  var bl = new FastVector3().add(center).add(yawUnitVec).mult((10 / 2) * 1);
	  var br = new FastVector3().add(center).add(yawUnitVec).mult((10 / 2) * -1);
	  var tl = new FastVector3().add(center).add(yawUnitVec).mult((MID_WIDTH / 2) * 1);
	  var tr = new FastVector3().add(center).add(yawUnitVec).mult((MID_WIDTH / 2) * -1);
	  var tc = new FastVector3().add(center).add(tipBendUnitVec).mult(TIP_OFFSET);
	
	  tl.y += height / 2;
	  tr.y += height / 2;
	  tc.y += height;
	
	  // Vertex Colors
	  var black = [0, 0, 0];
	  var gray = [0.5, 0.5, 0.5];
	  var white = [1.0, 1.0, 1.0];
	
	var poss = [bl, br, tr, tl, tc];
	var uvs = [uv, uv, uv, uv, uv];
	var colors: Array<Dynamic> = [black, black, gray, gray, white];

/*	  var verts = [
		{ pos: bl.toArray(), uv: uv, color: black },
		{ pos: br.toArray(), uv: uv, color: black },
		{ pos: tr.toArray(), uv: uv, color: gray },
		{ pos: tl.toArray(), uv: uv, color: gray },
		{ pos: tc.toArray(), uv: uv, color: white }
	  ];
	*/
	  var indices = [
		vArrOffset,
		vArrOffset + 1,
		vArrOffset + 2,
		vArrOffset + 2,
		vArrOffset + 4,
		vArrOffset + 3,
		vArrOffset + 3,
		vArrOffset,
		vArrOffset + 2
	  ];
	
	  var o = new OMesh();
	  o.pos = poss;
	  o.uv = uvs;
	  o.color = colors;
	  o.indices = indices;
	  return o;
	}

	public function new(sections : Int) {

		/*var obj = new ObjLoader(Assets.blobs.grass_obj.toString());
		
		vertices = obj.data;
		indices = obj.indices;
		return;*/

		// Radius
		var r : Float = 1;
		// Height
		var h : Float = 30;
		
		vertices = new Array<Float>();
		indices = new Array<Int>();
		
		// Bottom center
		vertices.push(0);
		vertices.push(0);
		vertices.push(0);
		
		// Top center
		vertices.push(0);
		vertices.push(h);
		vertices.push(0);
		
		var index : Int = 2;
		var firstPoint : Vector2 = new Vector2(0, r);
		var lastPoint : Vector2 = firstPoint;
		var nextPoint : Vector2;
		for (i in 0...sections) {
			nextPoint = Matrix3.rotation(i * (2 / sections) * Math.PI).multvec(firstPoint);
			
			addSection(lastPoint, nextPoint, h, index);
			
			lastPoint = nextPoint;
			index += 4;
		}
		
		addSection(lastPoint, firstPoint, h, index);
		
	}
	
	private function addSection(lastPoint : Vector2, nextPoint : Vector2, h : Float, index : Int) {
		vertices.push(lastPoint.x);
		vertices.push(0);
		vertices.push(lastPoint.y);
		
		vertices.push(lastPoint.x/20);
		vertices.push(h);
		vertices.push(lastPoint.y/20);
		
		vertices.push(nextPoint.x);
		vertices.push(0);
		vertices.push(nextPoint.y);
		
		vertices.push(nextPoint.x/20);
		vertices.push(h);
		vertices.push(nextPoint.y/20);
		
		// First part of side
		indices.push(index);
		indices.push(index + 1);
		indices.push(index + 2);
		
		// Second part of side
		indices.push(index + 3);
		indices.push(index + 2);
		indices.push(index + 1);
		
		// Bottom
		indices.push(0);
		indices.push(index);
		indices.push(index + 2);
		
		// Top
		indices.push(index + 3);
		indices.push(index + 1);
		indices.push(1);
	}
}