#version 450
precision highp float;

in vec4 fragmentColor;
out vec4 outColor;
in vec4 fragmentPosition;

float rand(float n){return fract(sin(n) * 43758.5453123);}

float noise(float p){
	float fl = floor(p);
  float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}

void main() {
	outColor = 0.2* (fragmentColor + vec4(noise(fragmentPosition.y))+ vec4(noise(fragmentPosition.x-sin(fragmentPosition.z))));
}