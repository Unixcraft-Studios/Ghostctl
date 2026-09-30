// shader collection for use with Ghostty 1.3.x+
// Spirit-Heart
// Stage 1 - Shape Engine + Breathing Glow
//
// Heart implementation with pluggable shape distance field.
// Circle is included as the initial placeholder shape.
//
// BSD-3-Clause-v2 (Modified - Name Attribution Required)
//
// Copyright (c) 2026 GrandBIRDLizard.
// ALL rights reserved.

// FEATURE TOGGLES
#define ENABLE_BREATHING 1


// SHAPE ENGINE
// The renderer only talks to shapeDistance().
// Adding a new shape should not require changing the
// rendering/compositing code below.
// 0 = Heart
// 1 = Circle

#define SHAPE_HEART  1
#define SHAPE_CIRCLE 0

#define SHAPE_TYPE SHAPE_HEART

// SHAPE POSITION
#define SHAPE_OFFSET vec2(0.0, -0.10)


// HEART SETTINGS
#define HEART_SCALE     0.22
#define HEART_Y_OFFSET  0.015

#define BREATH_SPEED    1.35
#define BREATH_STRENGTH 0.035


// CIRCLE SETTINGS
#define CIRCLE_RADIUS 0.55


// COLORS
const vec3 HEART_CORE = vec3(0.12, 0.42, 0.25);
const vec3 HEART_GLOW = vec3(0.58, 0.34, 0.06);


// HEART DISTANCE FIELD
// A compact 2D heart distance field.
// The upper portion is formed from two rounded lobes.
// The lower portion converges toward the characteristic
// heart point.
// p is expected to be aspect-corrected before entering here.



// CIRCLE DISTANCE FIELD
// This is intentionally simple. Its purpose is to prove
// that the rendering pipeline is independent of the shape.

float circleSDF(vec2 p)
{
    p /= HEART_SCALE;

    return length(p) - CIRCLE_RADIUS;
}


float heartSDF(vec2 p)
{
    p /= HEART_SCALE;

    p.y += HEART_Y_OFFSET;

#if ENABLE_BREATHING

    float beat = pow(
        max(0.0, sin(iTime * BREATH_SPEED)),
        6.0
    );

    p /= 1.0 + beat * BREATH_STRENGTH;

#endif

    p.x = abs(p.x);

    // Upper half

    if (p.y + p.x > 1.0)
    {
        vec2 q = p - vec2(0.25, 0.75);

        return length(q) - sqrt(2.0) * 0.25;
    }

    // Bottom half

    vec2 q1 = p - vec2(0.0, 1.0);

    vec2 q2 = p - 0.5 * max(
        p.x + p.y,
        0.0
    );

    float d = sqrt(
        min(
            dot(q1, q1),
            dot(q2, q2)
        )
    );

    return d * sign(p.x - p.y);
}


// SHAPE DISPATCH
// Everything below this function is shape-agnostic.

float shapeDistance(vec2 p)
{
#if SHAPE_TYPE == SHAPE_HEART

    return heartSDF(p);

#elif SHAPE_TYPE == SHAPE_CIRCLE

    return circleSDF(p);

#else

    // Safe circle.
    return circleSDF(p);

#endif
}


float shapeFill(float d)
{
    // Derivative keeps edge stable at different
    // terminal resolutions without requiring fixed pixel threshold.
    float aa = max(fwidth(d), 0.0015);

    return 1.0 - smoothstep(-aa, aa, d);
}


// SHAPE BLOOM
// Two falloffs tighter inner glow plus faint
// outer glow without blur pass.
float shapeBloom(float d)
{
    float ad = abs(d);

    float tight = exp(-28.0 * ad);
    float medium = exp(-11.0 * ad);
    float wide = exp(-4.5 * ad);

    return
        tight  * 0.55 +
        medium * 0.30 +
        wide   * 0.15;
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    if (iResolution.y == 0.0)
        return;

    // Terminal framebuffer
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col = texture(iChannel0, uv).rgb;
    // Terminal luminance mask
    float lum = dot(
        col,
        vec3(0.299, 0.587, 0.114)
    );

    float darkMask = 1.0 - smoothstep(
        0.04,
        0.20,
        lum
    );


    // Shape coordinate systemi
    vec2 p = uv - 0.5;

    float aspect = iResolution.x / iResolution.y;

    p.x *= aspect;

    // Move the entire shape without modifying its SDF.
    p -= SHAPE_OFFSET;
    
    // Engine
    float d = shapeDistance(p);


    // lighting
    float fill = shapeFill(d);
    float glow = shapeBloom(d);


    // Composite
    // Keeps effect additive and restrained.
    // Bright terminal content naturally suppresses it through darkMask.
    col += HEART_GLOW
         * glow
         * 0.30
         * darkMask;

    col += HEART_CORE
         * fill
         * 0.22
         * darkMask;

    fragColor = vec4(col, 1.0);
}
