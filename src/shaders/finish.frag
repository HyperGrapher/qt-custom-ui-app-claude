#version 440

// Final pass of the background: scales the low-resolution aurora up to window size and adds
// a readability vignette, a faint inner rim, dithering against color banding, and the
// antialiased rounded window corners (as real alpha).

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float cornerRadius;
    float devicePixelRatio;
    vec2 itemSize;
};

layout(binding = 1) uniform sampler2D source;

float roundedBoxDistance(vec2 point, vec2 halfSize, float radius)
{
    vec2 q = abs(point) - halfSize + radius;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}

void main()
{
    vec2 uv = qt_TexCoord0;
    vec3 color = texture(source, uv).rgb;

    // Darken the edges slightly so text near them stays readable.
    vec2 centered = (uv - 0.5) * vec2(1.0, 1.2);
    float vignette = smoothstep(0.95, 0.25, length(centered));
    color *= mix(0.72, 1.0, vignette);

    vec2 point = (uv - 0.5) * itemSize;
    float distanceToEdge = roundedBoxDistance(point, itemSize * 0.5, cornerRadius);
    float coverage = clamp(0.5 - distanceToEdge * devicePixelRatio, 0.0, 1.0);

    // One logical pixel of light just inside the edge, brighter at the top.
    float rim = 1.0 - smoothstep(0.0, 1.2, abs(distanceToEdge + 0.8));
    color += vec3(rim * mix(0.03, 0.10, 1.0 - uv.y));

    // Below one 8-bit step, so it is invisible as noise but breaks up gradient bands.
    float noise = fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453);
    color += (noise - 0.5) / 255.0;

    fragColor = vec4(color * coverage, coverage) * qt_Opacity;
}
