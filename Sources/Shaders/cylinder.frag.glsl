#version 450
precision mediump float;

in vec4 fragmentColor;
out vec4 outColor;

void main() {
	outColor = fragmentColor;
}