#version 450
precision mediump float;

// Input vertex data, different for all executions of this shader
in vec3 pos;

// Instanced input data (different for each instance but the same for each vertex of an instance)
in vec3 col;
uniform mat4 MVP;


// Output data - will be interpolated for each fragment
out vec4 fragmentColor;

void main() {
	fragmentColor = MVP * vec4(pos, 1.0);
	gl_Position = fragmentColor;
}