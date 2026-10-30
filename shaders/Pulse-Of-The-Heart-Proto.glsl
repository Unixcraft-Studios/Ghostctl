// Ghostty ShaderToy-compatible format
// Uniforms available: iChannel0, iResolution, iTime, iTimeCursorChange

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 col = texture(iChannel0, uv);

    float timeSinceType = iTime - iTimeCursorChange;
    float bleedAge = clamp(timeSinceType / 1.8, 0.0, 1.0); // fades over 1.8s
    float bleedRadius = 0.008 * (1.0 - bleedAge); // shrinks as it "dries"

    // Sample neighbors to find bright (ink) pixels
    float inkBleed = 0.0;
    int samples = 8;
    for (int i = 0; i < samples; i++) {
        float angle = float(i) * 3.14159 * 2.0 / float(samples);
        vec2 offset = vec2(cos(angle), sin(angle)) * bleedRadius;
        vec4 neighbor = texture(iChannel0, uv + offset);
        float neighborLum = dot(neighbor.rgb, vec3(0.299, 0.587, 0.114));
        inkBleed = max(inkBleed, neighborLum);
    }

    // Blend: original + bleed halo that fades as ink dries
    float bleedStrength = inkBleed * (1.0 - bleedAge) * 0.35;
    vec3 inkColor = col.rgb + bleedStrength * vec3(0.1, 0.15, 0.3); // cool-tinted bleed

    fragColor = vec4(inkColor, col.a);
}
