shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_enable; //Current texure of the screen
uniform ivec2 screen_ratio = ivec2(16, 9); //Aspect ratio of display, should be same as other shaders
uniform int screen_size = 25; //Multiplies screen_ratio, should be same as other shaders
uniform float bloom_mult = 1.0; //Multiplier for bloom effect, set 0 to disable
uniform sampler2D noise; //Noise texture set in the inspecoe
uniform float noise_rat = 0.015; //Multiplier for insensity of noise effect, set 0 to disable
uniform float dither_rat = 0.15; //Multiplier for insensity of dither effect, set 0 to disable
uniform float levels = 6.0; //Amount of brightness levels allowed by the shader
uniform float posterization_ratio = 0.8; //Controls how visible the shader should be


float bayer4x4(ivec2 pos) {
	//Generates a value for dither based on coordinates
	int x = pos.x % 4;
	int y = pos.y % 4;
	
	float bayer_matrix[16] = float[16](
		0.0/16.0,  8.0/16.0,  2.0/16.0, 10.0/16.0,
		12.0/16.0, 4.0/16.0, 14.0/16.0,  6.0/16.0,
		3.0/16.0, 11.0/16.0,  1.0/16.0,  9.0/16.0,
		15.0/16.0, 7.0/16.0, 13.0/16.0,  5.0/16.0
	);
	
	return bayer_matrix[y * 4 + x];
}


void fragment() {
	vec3 col; //Define col variable to use as main output of the shader
	col = textureLod(screen_texture, UV, 0.0).rgb; //Set to the colour of the current pixel
	
	//Bloom effect. Note: most constants in this section are arbatrary and can be modiflied to preference
	vec3 bloom = textureLod(screen_texture, UV, 4.0).rgb; //Final argument is the blur amount applied when getting texture
	vec3 bloom_val = clamp(pow(bloom * 0.5 + length(bloom) / 4.0, vec3(3.5)) - normalize(col + 10.0) / 1000.0, vec3(0), 1.5 * col + vec3(0.5)); //Perform calculations to determine the value for bloom
	bloom_val *= bloom_mult; //Multiply the bloom
	//bloom_val *= floor(UV.x + 0.5); //Uncomment to apply bloom to only half the screen
	vec3 col_bloom = bloom_val + col; //Store the colour of the pixel with bloom in a new variable
	
	//Dither + noise effect
	vec2 screen_pos = floor(UV * vec2(screen_ratio * screen_size)) + 0.5; //Current position on the screen to the nearest pixel
	float noise_val = noise_rat * (sin(texture(noise, vec2(UV.x, UV.y + (TIME / 200.0 - floor(TIME / 200.0 + UV.y)) )).r * 2.0 * PI)); //Value of a single point on a slowly scrolling noise texture
	float dither_val = dither_rat * bayer4x4(ivec2(screen_pos)); //Value of dither on an enlarged pixel
	vec3 col_dither = clamp(col_bloom * (1.0 - (noise_val + dither_val)), col_bloom - 1.0 / levels, col_bloom + 1.0 / levels); //Store the colour of the dithered pixel in a new variable
	
	//Calculations for posterization
	float greyscale = max(col_dither.r ,max(col_dither.g, col_dither.b));
	float lower = floor(greyscale * levels) / levels;
	float lower_diff = abs(greyscale - lower);
	float upper = ceil(greyscale * levels) / levels;
	float upper_diff = abs(upper - greyscale);
	float level = lower_diff <= upper_diff ? lower : upper;
	float adjustment = level / greyscale;
	
	vec3 light_mult = (1.0 + (vec3(1.0 - pow(level, 0.5)) * vec3(0.3, -0.1, 1) - vec3(pow(level, 1.5)) * vec3(-0.3, -0.1, 0.1))); //Make darker/ligher colours appear cooler/warmer respectively
	vec3 col_posterized = ((col_bloom * adjustment * posterization_ratio) * light_mult) + col * (1.0 - posterization_ratio); //Opacity of the shader is controlled by posterization_ratio
	
	COLOR.rgb = col_posterized; //Assign the pixel colour to the calculated value
	//COLOR.rgb = (col_bloom - col) * adjustment * light_mult; //Uncomment to see only bloom
	//COLOR.rgb = ((light_mult - 1.0) * col_bloom * adjustment); //Uncomment to see only colour added by light_mult
}






