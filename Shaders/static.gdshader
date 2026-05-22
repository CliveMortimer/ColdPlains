shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest_mipmap, repeat_enable;
uniform float ratio = 0.2;


float saw(float n){
	float p = 2.0;
	float output = 2.0 * (n / p - floor(0.5 + n / p));
	return output;
}


void fragment() {
	vec3 col;
	float y = UV.y * 10.0;
	float t = TIME;
	float offset = clamp(pow(saw(y + t), 2) * 1.1 * floor(sin(y + t) * 1.2) + pow(saw(10.0 * y + t), 2) / 5.0, 0.1, 2.0);
	offset *= clamp(pow(saw(y + 2.0 * t), 2) * 1.1 * floor(sin(y + 3.0 * t) * 1.2) + pow(saw(10.0 * y + 0.7 * t), 2) / 5.0, 0.1, 1.0);
	offset *= 2.0 * sin(2000.0 * y + 200.0 * t);
	col = 0.5 * (texture(screen_texture, SCREEN_UV + vec2(offset, 0.0)) + texture(screen_texture, SCREEN_UV + vec2(-offset, 0.0))).xyz;
	col = (2.0 * texture(screen_texture, SCREEN_UV).rgb - col).rgb / clamp(offset, 1.1, 1000.0);
	COLOR.rgb = col * ratio + texture(screen_texture, SCREEN_UV).rgb * (1.0 - ratio);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
