#version 440

// "Energy orb": a shaded sphere with a slowly swirling interior, rim light, a specular
// highlight and an outer halo. Colors follow the current section mood.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float pulse; // 0..1, brightens and swells the orb
    float pixelSize; // one device pixel in 0..2 orb space
    vec4 colorA;
    vec4 colorB;
    vec4 colorC;
};

void main()
{
    vec2 p = (qt_TexCoord0 - 0.5) * 2.0;
    float sphereRadius = 0.6 + 0.03 * pulse;
    float r = length(p);
    float body = 1.0 - smoothstep(sphereRadius - pixelSize, sphereRadius + pixelSize, r);

    vec2 n2 = p / sphereRadius;
    float z = sqrt(max(0.0, 1.0 - dot(n2, n2)));

    // Spherical distortion makes the flow look wrapped around a ball. Nested sines give a
    // slow liquid flow without the pinch point an angle-based swirl has at the center.
    vec2 s = n2 / (z + 0.6) * 1.6;
    float swirl = 0.5 + 0.5 * sin(s.x * 2.1 + sin(s.y * 1.7 + time * 0.23) * 1.4 + time * 0.17);
    float drift = 0.5 + 0.5 * sin(s.y * 2.6 + sin(s.x * 2.2 - time * 0.19) * 1.3 - time * 0.13);

    vec3 inner = mix(colorA.rgb, colorB.rgb, swirl);
    inner = mix(inner, colorC.rgb, drift * 0.55);

    vec3 normal = normalize(vec3(n2, z + 1e-4));
    float light = 0.32 + 0.68 * z;
    vec3 color = inner * light;
    float rim = pow(1.0 - z, 3.0);
    color += mix(colorB.rgb, vec3(1.0), 0.45) * rim * 0.9;
    float specular = pow(max(0.0, dot(normal, normalize(vec3(-0.45, -0.6, 0.66)))), 28.0);
    color += vec3(specular * 0.6);
    color *= 1.0 + 0.25 * pulse;

    float halo = exp(-max(r - sphereRadius, 0.0) * 6.5) * (0.42 + 0.38 * pulse);
    halo *= (1.0 - body) * (1.0 - smoothstep(0.82, 1.0, r));
    vec3 haloColor = mix(colorA.rgb, colorB.rgb, 0.5);

    vec4 sphere = vec4(color, 1.0) * body;
    vec4 glow = vec4(haloColor * halo, halo * 0.75);
    fragColor = (sphere + glow) * qt_Opacity;
}
