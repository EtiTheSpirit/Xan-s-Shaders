# About
The Color Shifter Shader is a shader designed to merge as many color shift controls (full HSV) into a single material as possible (with as little overhead as possible). It is designed for those that want maximum customizability on their avatars without wasting material slots on the same texture in 2+ different places. 

This operates its color shifts based on the Shift Key. This is a texture using up to 8 unique colors (mentioned below). It should have the same UV map as the diffuse texture, and tells the shader what areas to shift, and what color option it should use when shifting.

An image example of the old version of this shader I made for myself is here: https://imgur.com/a/VTFlmMl

## Important Stuff (If you don't read this, you probably won't even be able to use it)
1. Diffuse texture does not support alpha. This is an opaque shader. This may change in a future update.
2. Specular/Smoothness/Emission is a multiplied mask, not a color of its own. Sorry. Makes it easy to pack data into textures by channel.
3. **The Key texture MUST STRICTLY ONLY *EVER* USE BLACK, RED, GREEN, BLUE, CYAN, MAGENTA, YELLOW, AND/OR WHITE WITH FULL BRIGHTNESS (HEX CODES BELOW).** One of this shader's optimizations will cause unpredictable and buggy behavior if anything other than these are used.
- #000000
- #FF0000
- #00FF00
- #0000FF
- #FFFF00
- #FF00FF
- #00FFFF
- #FFFFFF

These are the only allowed colors. Not using these will brick the shader.

4. Color shift keys are in HSV, apply to the texture multiplicatively, and use Vector format due to some rendering jargon (that is, you don't see a color picker in the material editor, just four textboxes). The last value (W) is not used, only the first three. While this makes editing the colors by hand kind of hard, it makes it trivially easy to animate for expressions and we don't need to worry about preventing gamma correction, because this is just a color change. The texture itself already has gamma correction.
5. These are a bit memory hungry as far as avatar parameters go. You might not be able to use all 8 shifts with full HSV unless VRC increases the parameter memory limit.
