#version 450
precision highp float;

// Input vertex data, different for all executions of this shader
in vec3 pos;
in mat4 m;

// Instanced input data (different for each instance but the same for each vertex of an instance)
in vec3 col;


// Output data - will be interpolated for each fragment
out vec4 fragmentColor;

void main() {
	fragmentColor = vec4(col,1.0);
	gl_Position = m * vec4(pos, 1.0);
}