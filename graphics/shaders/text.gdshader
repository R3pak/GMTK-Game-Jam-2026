shader_type canvas_item;

uniform float SPEED = 0.15;

void vertex() {
	UV.y += TIME * SPEED;
	UV.y -= TIME * SPEED;
}