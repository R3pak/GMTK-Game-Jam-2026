shader_type canvas_item;

uniform float SPEED = 0.15;

void vertex() {
	UV.x += TIME * SPEED;
	UV.y += TIME * SPEED;
}