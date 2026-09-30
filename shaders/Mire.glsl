// Shader collection for Ghostty 1.3.x+ // Mire.glsl // Prototype // 
// BSD-3-Clause-v2 (Modified - Name Attribution Required)

//Copyright (c) 2026 GrandBIRDLizard.
//ALL rights reserved.

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    if (iResolution.y == 0.0)
        return;
    vec2 uv = fragCoord / iResolution.xy;
    vec3 col = texture(iChannel0, uv).rgb;


    float aspect = iResolution.x / iResolution.y;
    vec2 p = uv - 0.5;
    
    p.x *= aspect;

    float t = iTime;

    vec2 q = p;

    // Slow global deformation.
    q += 0.025 * vec2(
        sin(t * 0.37),
        cos(t * 0.31)
    );

    // Radial distance.
    float r = length(q);

    // Angular component.
    float angle = atan(q.y, q.x);

    float radial = sin(
        r * 18.0
        - t * 0.65
        + sin(angle * 5.0 + t * 0.2) * 1.4
    );

    vec2 w = q;

    w.x += sin(q.y * 8.0 + t * 0.42) * 0.09;
    w.y += cos(q.x * 7.0 - t * 0.35) * 0.09;

    float cellular =
        sin(w.x * 21.0 + sin(w.y * 5.0))
        *
        sin(w.y * 19.0 + cos(w.x * 4.0));

    float detail =
        sin(q.x * 42.0 + t * 0.75)
        *
        sin(q.y * 37.0 - t * 0.61);

    float field =
        radial * 0.35
        + cellular * 0.45
        + detail * 0.20;

    // Convert signed field into concentration-like value.
    float concentration = field * 0.5 + 0.5;

    // Sharpen the reaction boundary.
    concentration = smoothstep(
        0.38,
        0.62,
        concentration
    );

    // Organic-ish modulation

    float growth =
        smoothstep(
            0.15,
            0.85,
            sin(concentration * 3.14159)
        );

    // Fade toward the outside for visibility.
    float radialMask =
        1.0 - smoothstep(
            0.20,
            0.72,
            r
        );

    growth *= radialMask;

    vec3 reactionColor = vec3(
        concentration * 0.55,
        concentration * 0.18,
        concentration * 0.75
    );

    // Fine luminous structures.
    reactionColor += vec3(
        0.08,
        0.02,
        0.12
    ) * detail * 0.5;

    // Blend with framebuffer

    float intensity = growth * 0.32;
    col += reactionColor * intensity;

    // Vignete gives the pattern
    // more separation without destroying terminal text.
    col *= 1.0 - growth * 0.045;
    
    fragColor = vec4(col, 1.0);

}
