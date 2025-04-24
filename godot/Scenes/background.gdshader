shader_type canvas_item;

uniform vec4 tint;
uniform sampler2D gradient;
uniform sampler2D gradient_b;
uniform float offset;
uniform float phase;
uniform float desaturate;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tx = texture( TEXTURE, UV+vec2(offset, 0.0) );//*tint;
	vec4 col = texture( gradient, vec2( tx.r, fract(phase) ) );
	vec4 col_b = texture( gradient_b, vec2( tx.r, fract(phase) ) );
	// float v = 0.3*col.r+0.59*col.g+0.11*col.b;
	// vec4 gray = vec4( v );
	// COLOR = gray;
	// G*.59+R*.3+B*.11
	// COLOR = col;
	//col = mix( col, gray, desaturate );
	//col = col * tint;
	col = mix( col, col_b, desaturate );
	COLOR = col;
	// COLOR = col;
	// COLOR = col_b;
	// COLOR = col;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
