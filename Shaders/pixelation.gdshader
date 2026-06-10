shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_enable; //Current texure of the screen
uniform ivec2 screen_ratio = ivec2(16, 9); //Aspect ratio of display
uniform int screen_size = 25; //Multiplies screen_ratio
uniform int res_mult = 2; //Multiplies higher res render
uniform float pixelation_ratio = 0.8; //Controls how visible the shader should be


void fragment() {
	vec3 col; //Define col variable to use as main output of the shader
	
	//Pixelation effect
	vec2 screen_pos = floor(UV * vec2(screen_ratio * screen_size)) + 0.5; //Current position on the screen to the nearest pixel
	vec2 pos = screen_pos / vec2(screen_ratio * screen_size); //Screen position scaled back to UV coordinates
	col = textureLod(screen_texture, pos, 0.0).rgb; //Find the colour of the scaled pixel 
	
	//Repeat steps above with a multiplier to resolution
	vec2 screen_pos_xres = floor(UV * vec2(screen_ratio * screen_size * res_mult)) + 0.5;
	vec2 pos_xres = screen_pos_xres / vec2(screen_ratio * screen_size * res_mult);
	vec3 col_xres = textureLod(screen_texture, pos_xres, 0.0).rgb;
	
	//Set the colour of the pixel to to value determined above
	vec3 col_pixelated = col * pixelation_ratio + col_xres * (1.0 - pixelation_ratio); //Opacity of the shader is controlled by pixelation_ratio
	COLOR.rgb = col_pixelated; //Assign the pixel colour to the calculated value
	//COLOR.rgb = vec3(UV.x);
}







