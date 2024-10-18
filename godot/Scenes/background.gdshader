shader_type canvas_item;

uniform vec4 tint;
uniform sampler2D gradient;
uniform float offset;
uniform float phase;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tx = texture( TEXTURE, UV+vec2(offset, 0.0) );//*tint;
	COLOR = texture( gradient, vec2( tx.r, phase ) );
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
