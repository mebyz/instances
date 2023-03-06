#version 450
precision highp float;

in vec4 fragmentColor;
out vec4 outColor;

void main() {
	outColor = fragmentColor;
}