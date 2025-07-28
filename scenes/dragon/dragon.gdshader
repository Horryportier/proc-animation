/*
Shader from Godot Shttps://x.com/kaeritai07/mediahaders - the free shader library.
godotshaders.com/shader/pixelate

This shader is under CC0 license. Feel free to use, improve and
change this shader according to your needs and consider sharing
the modified result to godotshaders.com.
*/

shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;
uniform int amount = 40;

void fragment()
{
	vec2 grid_uv = round(SCREEN_UV * float(amount)) / float(amount);

	vec4 text = texture(screen_texture, grid_uv);

	COLOR = text;
}