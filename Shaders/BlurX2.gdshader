shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float normal_dist(float sd, float x) {
	float output = pow((1.0 / (sd * sqrt(2.0 * PI))) * 2.71828, -(1.0 / 2.0) * pow(x / sd, 2.0));
	return output;
}

// Blurs the screen in the Y-direction.
void fragment() {
	float start = pow(abs(UV.x - 0.5), 1) * -8.25 + 5.0;
	float multi = start;
	float value = 0.0;
	int repeats = 0;
	vec3 col;
	float maxval = pow(abs(UV.x - 0.5), 7) * 50.0 + 2.0;
	while (value <= maxval && repeats < 40) {
		//start *= pow(decay, abs(float(repeats)));
		multi = normal_dist(start, float(repeats) / 1.0) / maxval;
		if (multi * 2.0 + value >= maxval || multi < 0.0) {
			multi = (1.0 - (value)) / 2.0;
		}
		col += texture(screen_texture, SCREEN_UV + vec2(float(repeats) * SCREEN_PIXEL_SIZE.x, 0.0)).xyz * multi;
		value += multi;
		if (repeats > 0) {
			col += texture(screen_texture, SCREEN_UV + vec2(-float(repeats) * SCREEN_PIXEL_SIZE.x, 0.0)).xyz * multi;
			value += multi;
		}
		repeats++;
		//multi = start - decay * float(repeats);
	}
    COLOR.xyz = col;
}