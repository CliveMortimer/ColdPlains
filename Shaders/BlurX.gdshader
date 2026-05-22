shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float normal_dist(float sd, float x) {
	float output = pow((1.0 / (sd * sqrt(2.0 * PI))) * 2.71828, -(1.0 / 2.0) * pow(x / sd, 2.0));
	return output;
}

// Blurs the screen in the Y-direction.
void fragment() {
	//float start = 8.5;
	//float multi = start;
	//float value = 0.0;
	//int repeats = 0;
	//vec3 col;
	//float maxval = 5.0;
	//while (value <= maxval && repeats < 100) {
		////start *= pow(decay, abs(float(repeats)));
		//multi = normal_dist(start, float(repeats) / 1.0) / maxval;
		//if (multi * 2.0 + value >= maxval || multi < 0.0) {
			//multi = (1.0 - (value)) / 2.0;
		//}
		//col += texture(screen_texture, SCREEN_UV + vec2(float(repeats) * SCREEN_PIXEL_SIZE.x, 0.0)).xyz * multi;
		//value += multi;
		//if (repeats > 0) {
			//col += texture(screen_texture, SCREEN_UV + vec2(-float(repeats) * SCREEN_PIXEL_SIZE.x, 0.0)).xyz * multi;
			//value += multi;
		//}
		//repeats++;
		////multi = start - decay * float(repeats);
	//}
	////col = col / maxval;
    vec3 col = texture(screen_texture, SCREEN_UV).xyz * 0.16;
    col += texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE.x, 0.0)).xyz * 0.15;
    col += texture(screen_texture, SCREEN_UV + vec2(-SCREEN_PIXEL_SIZE.x, 0.0)).xyz * 0.15;
    col += texture(screen_texture, SCREEN_UV + vec2(2.0 * SCREEN_PIXEL_SIZE.x, 0.0)).xyz * 0.12;
    col += texture(screen_texture, SCREEN_UV + vec2(2.0 * -SCREEN_PIXEL_SIZE.x, 0.0)).xyz * 0.12;
    col += texture(screen_texture, SCREEN_UV + vec2(3.0 * SCREEN_PIXEL_SIZE.x, 0.0)).xyz * 0.09;
    col += texture(screen_texture, SCREEN_UV + vec2(3.0 * -SCREEN_PIXEL_SIZE.x, 0.0)).xyz * 0.09;
    col += texture(screen_texture, SCREEN_UV + vec2(4.0 * SCREEN_PIXEL_SIZE.x, 0.0)).xyz * 0.05;
    col += texture(screen_texture, SCREEN_UV + vec2(4.0 * -SCREEN_PIXEL_SIZE.x, 0.0)).xyz * 0.05;
    COLOR.xyz = col;
	vec3 difference = (1.0 * (col - textureLod(screen_texture, SCREEN_UV, 0.0).xyz));
	float greyscale = max(difference.r ,max(difference.g, difference.b));
	COLOR.xyz = col - vec3(greyscale);
}