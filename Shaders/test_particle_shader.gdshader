shader_type particles;

//varying float time;

vec2 rot_2d(vec2 vector, float rotation) {
	vec2 rotated;
	rotated.x = vector.x * cos(rotation) - vector.y * sin(rotation);
	rotated.y = vector.x * sin(rotation) + vector.y * cos(rotation);
	return rotated;
}

void start() {
	TRANSFORM = EMISSION_TRANSFORM;
	MASS = 1.0;
	VELOCITY = vec3(10, 0, 0) * 2.0;
	COLOR.r = mod(TIME / 750.0, 0.001) / 0.001;
	float time = COLOR.r * 2.0 * PI;
	VELOCITY.xz = rot_2d(VELOCITY.xz, time);
	VELOCITY.xy = rot_2d(VELOCITY.xz, time + 2.0);
	VELOCITY.yz = rot_2d(VELOCITY.xz, time + 4.0);
}

void process() {
	float time = COLOR.r * 2.0 * PI;
	//DELTA / LIFETIME
	//TRANSFORM[1][1] -= DELTA / LIFETIME;
	//TRANSFORM[2][2] -= DELTA / LIFETIME;
	//TRANSFORM[3][3] = 1.1;
	VELOCITY /= (DELTA / LIFETIME) * 2.0 + 1.0;
	VELOCITY.xz = rot_2d(VELOCITY.xz, 0.1 * sin(time));
	VELOCITY.xy = rot_2d(VELOCITY.xy, 0.1 * sin(time + 2.0));
	VELOCITY.yz = rot_2d(VELOCITY.yz, -0.1 * sin(time + 4.0));
}
