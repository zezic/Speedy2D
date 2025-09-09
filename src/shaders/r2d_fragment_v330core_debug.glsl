#version 330 core

/*
 *  Copyright 2021 QuantumBadger
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

uniform sampler2D in_Texture;

in vec4 pass_Color;
in vec2 pass_TextureCoord;
in float pass_TextureMix;
in float pass_CircleMix;

out vec4 out_FragColor;

void main(void) {
    // DEBUG VERSION: Instead of sampling texture, show texture coordinates as colors
    // This helps isolate whether the issue is in coordinate passing or texture sampling

    // Test 1: Show texture coordinates as red/green channels
    vec4 coordColor = vec4(pass_TextureCoord.x, pass_TextureCoord.y, 0.0, 1.0);

    // Test 2: Show texture mix and circle mix as blue/alpha
    vec4 mixColor = vec4(0.0, 0.0, pass_TextureMix, pass_CircleMix);

    // Test 3: Try actual texture sampling (might fail on macOS)
    vec4 texCol = texture(in_Texture, pass_TextureCoord);

    // Combine tests - if texture sampling works, you'll see the texture
    // If it fails, you'll see coordinate colors
    float texCoordMagSquared = pass_TextureCoord.x * pass_TextureCoord.x
            + pass_TextureCoord.y * pass_TextureCoord.y;

    float circleAlpha = 1.0 - step(1.0, texCoordMagSquared);

    // Debug output: Show different things based on texture mix value
    if (pass_TextureMix > 0.5) {
        // For textured rendering, try to sample texture
        // If this fails (shows black/nothing), texture sampling is broken
        out_FragColor = pass_Color * texCol;
    } else if (pass_CircleMix > 0.5) {
        // For circle rendering, show circle alpha as brightness
        out_FragColor = vec4(vec3(circleAlpha), 1.0) * pass_Color;
    } else {
        // For solid color rendering, show texture coordinates as debug colors
        // Red = X coordinate, Green = Y coordinate, Blue = mix values
        out_FragColor = pass_Color * (coordColor + mixColor * 0.5);
    }
}
