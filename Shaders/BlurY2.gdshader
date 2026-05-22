shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float normal_dist(float sd, float x) {
	float output = pow((1.0 / (sd * sqrt(2.0 * PI))) * 2.71828, -(1.0 / 2.0) * pow(x / sd, 2.0));
	return output;
}

// Blurs the screen in the Y-direction.
void fragment() {
	float start = 10.5;
	float multi = start;
	float value = 0.0;
	int repeats = 0;
	vec3 col;
	float maxval = 2.0;
	while (value <= maxval && repeats < 40) {
		//start *= pow(decay, abs(float(repeats)));
		multi = normal_dist(start, float(repeats) / 1.0) / maxval;
		if (multi * 2.0 + value >= maxval || multi < 0.0) {
			multi = (1.0 - (value)) / 2.0;
		}
		col += texture(screen_texture, SCREEN_UV + vec2(0.0, float(repeats) * SCREEN_PIXEL_SIZE.y)).xyz * multi;
		value += multi;
		if (repeats > 0) {
			col += texture(screen_texture, SCREEN_UV + vec2(0.0, -float(repeats) * SCREEN_PIXEL_SIZE.y)).xyz * multi;
			value += multi;
		}
		repeats++;
		//multi = start - decay * float(repeats);
	}
	//col = col / maxval;
    //vec3 col = texture(screen_texture, SCREEN_UV).xyz * 0.16;
    //col += texture(screen_texture, SCREEN_UV + vec2(0.0, SCREEN_PIXEL_SIZE.y)).xyz * 0.15;
    //col += texture(screen_texture, SCREEN_UV + vec2(0.0, -SCREEN_PIXEL_SIZE.y)).xyz * 0.15;
    //col += texture(screen_texture, SCREEN_UV + vec2(0.0, 2.0 * SCREEN_PIXEL_SIZE.y)).xyz * 0.12;
    //col += texture(screen_texture, SCREEN_UV + vec2(0.0, 2.0 * -SCREEN_PIXEL_SIZE.y)).xyz * 0.12;
    //col += texture(screen_texture, SCREEN_UV + vec2(0.0, 3.0 * SCREEN_PIXEL_SIZE.y)).xyz * 0.09;
    //col += texture(screen_texture, SCREEN_UV + vec2(0.0, 3.0 * -SCREEN_PIXEL_SIZE.y)).xyz * 0.09;
    //col += texture(screen_texture, SCREEN_UV + vec2(0.0, 4.0 * SCREEN_PIXEL_SIZE.y)).xyz * 0.05;
    //col += texture(screen_texture, SCREEN_UV + vec2(0.0, 4.0 * -SCREEN_PIXEL_SIZE.y)).xyz * 0.05;
    ivec3 render = (ivec3((col - textureLod(screen_texture, SCREEN_UV, 0.1).xyz) * 10.0));
	vec3 render2 = vec3(float(render.x) + (float(render.y) + float(render.z)) / 2.0, float(render.x) + (float(render.y) + float(render.z)) / 2.0, float(render.x) + (float(render.y) + float(render.z)) / 2.0);
	//vec3 render = vec3(1, 1, 1) * ((col.x - textureLod(screen_texture, SCREEN_UV, 0.0).x) + (col.y - textureLod(screen_texture, SCREEN_UV, 0.0).y) + (col.z - textureLod(screen_texture, SCREEN_UV, 0.0).z));
	COLOR.xyz =  textureLod(screen_texture, SCREEN_UV, 0.0).xyz - abs(vec3(render2) * 1.0);
	//COLOR.xyz = col;
}