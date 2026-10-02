#version 440

// Ambient "aurora" background: five soft color blobs drifting on slow paths, blended in
// linear light. A second palette spreads out from an origin point when the section changes.
// The same pass adds a readability vignette, a faint inner rim, dithering against color
// banding, and the antialiased rounded window corners (as real alpha).
//
// It renders in one full-resolution pass on purpose: rendering at reduced resolution through
// a layer was measured to make Qt Quick render an extra frame per update, which cost far more
// than the pixels it saved.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float cornerRadius;
    float devicePixelRatio;
    float spread;       // 0..1 progress of the mood change
    float uniformBlend; // 1 = plain cross-fade instead of spreading (reduced motion)
    float intensity;    // 0..1 how strongly blobs show over the base color
    vec2 origin;        // mood spread start, in 0..1 texture coordinates
    vec2 itemSize;
    vec4 fromColor0;
    vec4 fromColor1;
    vec4 fromColor2;
    vec4 fromColor3;
    vec4 fromBase;
    vec4 toColor0;
    vec4 toColor1;
    vec4 toColor2;
    vec4 toColor3;
    vec4 toBase;
};

// Gamma 2.0 instead of 2.2: visually the same for soft blending, and much cheaper than pow()
// for a shader that runs on every window pixel.
vec3 toLinear(vec3 color)
{
    return color * color;
}

vec3 toGamma(vec3 color)
{
    return sqrt(max(color, vec3(0.0)));
}

// Two summed sine paths with unrelated periods per axis, so the motion never visibly loops.
vec2 blobCenter(float t, vec4 frequency, vec4 phase, vec2 anchor, vec2 range)
{
    vec2 wave = vec2(sin(t * frequency.x + phase.x) * 0.7 + sin(t * frequency.y + phase.y) * 0.3,
                     cos(t * frequency.z + phase.z) * 0.7 + sin(t * frequency.w + phase.w) * 0.3);
    return anchor + range * wave;
}

float roundedBoxDistance(vec2 point, vec2 halfSize, float radius)
{
    vec2 q = abs(point) - halfSize + radius;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

float blobWeight(vec2 point, vec2 center, float radius)
{
    vec2 offset = point - center;
    return exp(-dot(offset, offset) / (radius * radius));
}

void main()
{
    vec2 uv = qt_TexCoord0;
    float aspect = itemSize.x / max(itemSize.y, 1.0);
    vec2 p = vec2(uv.x * aspect, uv.y);
    float t = time;

    // Low-frequency warp bends the field so blob outlines look organic, not circular.
    vec2 warp = vec2(sin(p.y * 2.3 + t * 0.11) + sin(p.x * 1.7 - t * 0.07),
                     cos(p.x * 2.1 - t * 0.09) + sin(p.y * 1.3 + t * 0.05));
    vec2 q = p + 0.06 * warp;

    vec2 c0 = blobCenter(t, vec4(0.051, 0.083, 0.047, 0.071), vec4(0.0, 1.3, 2.1, 0.4),
                         vec2(0.28 * aspect, 0.30), vec2(0.20 * aspect, 0.20));
    vec2 c1 = blobCenter(t, vec4(0.043, 0.067, 0.059, 0.089), vec4(2.4, 0.7, 4.0, 1.9),
                         vec2(0.74 * aspect, 0.28), vec2(0.18 * aspect, 0.22));
    vec2 c2 = blobCenter(t, vec4(0.061, 0.037, 0.041, 0.077), vec4(4.1, 2.9, 0.9, 3.3),
                         vec2(0.62 * aspect, 0.78), vec2(0.24 * aspect, 0.18));
    vec2 c3 = blobCenter(t, vec4(0.035, 0.091, 0.053, 0.063), vec4(5.3, 4.4, 2.6, 0.2),
                         vec2(0.22 * aspect, 0.80), vec2(0.18 * aspect, 0.16));
    vec2 c4 = blobCenter(t, vec4(0.029, 0.057, 0.033, 0.049), vec4(1.1, 5.7, 3.7, 2.2),
                         vec2(0.50 * aspect, 0.50), vec2(0.30 * aspect, 0.26));

    // Radii "breathe" slowly so shapes keep changing even when blobs pass each other.
    float w0 = blobWeight(q, c0, 0.42 + 0.06 * sin(t * 0.13));
    float w1 = blobWeight(q, c1, 0.38 + 0.05 * sin(t * 0.11 + 1.7));
    float w2 = blobWeight(q, c2, 0.44 + 0.06 * sin(t * 0.09 + 3.1));
    float w3 = blobWeight(q, c3, 0.34 + 0.05 * sin(t * 0.15 + 4.6));
    float w4 = blobWeight(q, c4, 0.30 + 0.04 * sin(t * 0.07 + 2.3)) * 0.7;

    // Mood spread: a soft, slightly wobbly circle growing from the origin. Skipped entirely
    // while no spread runs (spread is a uniform, so the branch is cheap).
    float mask = 1.0;
    float band = 0.0;
    if (spread < 1.0) {
        vec2 o = vec2(origin.x * aspect, origin.y);
        vec2 fromOrigin = p - o;
        float wobble = 0.045 * sin(atan(fromOrigin.y, fromOrigin.x + 1e-4) * 5.0 + t * 0.4)
                       + 0.035 * sin(p.y * 7.0 - t * 0.3);
        float dist = length(fromOrigin) + wobble;
        float feather = 0.38;
        float reach = length(vec2(aspect, 1.0)) + 0.12;
        float radius = spread * (reach + feather);
        float radial = 1.0 - smoothstep(radius - feather, radius, dist);
        mask = mix(radial, spread, uniformBlend);

        // A faint luminous band rides on the spreading edge, like light caught in ink.
        band = smoothstep(radius - feather, radius - feather * 0.45, dist)
               * (1.0 - smoothstep(radius - feather * 0.45, radius, dist));
        band *= (1.0 - uniformBlend) * (1.0 - spread) * 1.6;
    }

    vec3 col0 = toLinear(mix(fromColor0.rgb, toColor0.rgb, mask));
    vec3 col1 = toLinear(mix(fromColor1.rgb, toColor1.rgb, mask));
    vec3 col2 = toLinear(mix(fromColor2.rgb, toColor2.rgb, mask));
    vec3 col3 = toLinear(mix(fromColor3.rgb, toColor3.rgb, mask));
    vec3 col4 = mix(col0, col3, 0.5);
    vec3 base = toLinear(mix(fromBase.rgb, toBase.rgb, mask));

    float total = w0 + w1 + w2 + w3 + w4;
    vec3 blend = (col0 * w0 + col1 * w1 + col2 * w2 + col3 * w3 + col4 * w4) / max(total, 1e-4);
    float blobCoverage = 1.0 - exp(-total * 1.5);

    vec3 color = mix(base, blend * 0.85, blobCoverage * intensity);
    color += blend * band * 0.35;

    color = toGamma(color);

    // Darken the edges slightly so text near them stays readable.
    vec2 centered = (uv - 0.5) * vec2(1.0, 1.2);
    color *= mix(0.72, 1.0, smoothstep(0.95, 0.25, length(centered)));

    vec2 point = (uv - 0.5) * itemSize;
    float distanceToEdge = roundedBoxDistance(point, itemSize * 0.5, cornerRadius);
    float coverage = clamp(0.5 - distanceToEdge * devicePixelRatio, 0.0, 1.0);

    // One logical pixel of light just inside the edge, brighter at the top.
    float rim = 1.0 - smoothstep(0.0, 1.2, abs(distanceToEdge + 0.8));
    color += vec3(rim * mix(0.03, 0.10, 1.0 - uv.y));

    // Below one 8-bit step: invisible as noise, but it breaks up gradient bands.
    float noise = fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453);
    color += (noise - 0.5) / 255.0;

    fragColor = vec4(color * coverage, coverage) * qt_Opacity;
}
