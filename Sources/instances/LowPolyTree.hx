package instances;

class LowPolyTree {
    var trunkSize: Float;
    var trunkHeight: Float;
    var numBranches: Int;
    var branchAngle: Float;
    var branchLengthFactor: Float;
    var branchThicknessFactor: Float;
    var leafSize: Float;
    
    public function new() {
        // Default parameters
        trunkSize = 0.2;
        trunkHeight = 0.5;
        numBranches = 5;
        branchAngle = 45.0;
        branchLengthFactor = 0.7;
        branchThicknessFactor = 0.7;
        leafSize = 0.2;
    }
    
    public function generateTree(): kha.graphics3d.Mesh {
        // Generate trunk mesh
        var trunkMesh = generateCylinder(trunkSize, trunkSize * trunkHeight);
        
        // Generate branches
        for (i in 0...numBranches) {
            var branchSize = trunkSize * branchThicknessFactor * (1.0 - i / numBranches);
            var branchLength = trunkHeight * branchLengthFactor * (1.0 - i / numBranches);
            var branchRotation = Quaternion.fromAxisAngle(Vec3(0, 1, 0), i * branchAngle);
            
            var branchMesh = generateCylinder(branchSize, branchLength);
            branchMesh.transform(branchRotation.toMat4());
            branchMesh.translate(Vec3(0, branchLength / 2, 0));
            
            trunkMesh.combineWith(branchMesh);
        }
        
        // Generate leaves
        var numLeaves = Math.pow(numBranches, 2);
        var leafMesh = generateSphere(leafSize);
        for (i in 0...numLeaves) {
            var leafPosition = Vec3(Random.float(trunkSize, trunkSize * 2), Random.float(trunkHeight * 0.7, trunkHeight), Random.float(-trunkSize, trunkSize));
            leafMesh.translate(leafPosition);
            
            trunkMesh.combineWith(leafMesh);
        }
        
        return trunkMesh;
    }
    
    function generateCylinder(radius: Float, height: Float): kha.graphics3d.Mesh {
        var cylinderMesh = kha.graphics3d.MeshTools.createCylinder(radius, height, 16, true);
        return cylinderMesh;
    }
    
    function generateSphere(radius: Float): kha.graphics3d.Mesh {
        var sphereMesh = kha.graphics3d.MeshTools.createSphere(radius, 16, 16);
        return sphereMesh;
    }
}

/* 
LowPolyTree class

This class has several parameters that can be adjusted to customize the appearance of the generated tree. These parameters include:

trunkSize: The radius of the tree trunk.
trunkHeight: The height of the tree trunk.
numBranches: The number of branches on the tree.
branchAngle: The angle between each branch (in degrees).
branchLengthFactor: A factor that controls how much shorter each successive branch is than the previous one.
branchThicknessFactor: A factor that controls how much thinner each successive branch is than the previous one.
leafSize: The radius of the leaves on the tree.
The generateTree() method generates a low-poly tree mesh using these parameters. 
It first generates a mesh for the trunk using the generateCylinder() method, then generates meshes for each of the branches 
and combines them with the trunk and branch meshes using the combineWith() method, and returns the resulting mesh.

The generateCylinder() and generateSphere() methods are helper functions that create cylinder and sphere meshes, respectively, with the specified radius and height (for cylinders) or radius (for spheres).

To use this class in a Kha project, you would first create an instance of the LowPolyTree class with the desired parameters, and then call the generateTree() method to generate a mesh:


var tree = new LowPolyTree();
tree.trunkSize = 0.3;
tree.numBranches = 7;
var mesh = tree.generateTree();
You can then use the resulting mesh object in your Kha project, for example by creating a Model object:

var model = new Model(mesh, Material.fromColor(Color.fromFloats(0.5, 0.8, 0.5, 1.0)));
This creates a Model object with the generated mesh and a simple green material. You can then add this model to your scene or use it in any other way that you would use a Kha Model object.
*/