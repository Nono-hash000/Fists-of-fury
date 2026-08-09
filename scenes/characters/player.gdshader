shader_type canvas_item;

uniform vec4 original_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); 
uniform vec4 new_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tolerance : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
	
    if (distance(tex_color.rgb, original_color.rgb) <= tolerance && tex_color.a > 0.0) {
        COLOR = vec4(new_color.rgb, tex_color.a);
    } else {
        COLOR = tex_color;
    }
}