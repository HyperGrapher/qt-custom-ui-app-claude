#version 440

// Glass card surface: translucent fill with a top-lit gradient, a rim highlight that is
// brightest toward the light (top-left) and the pointer, and a soft specular spot that
// follows the pointer while hovered.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float radius;
    float hover;           // 0..1
    float highlightAmount; // 0 disables specular and pointer rim (setting "glass highlights")
    float devicePixelRatio;
    vec2 itemSize;
    vec2 pointer;          // in item pixels
    vec4 fillColor;
    vec4 tintColor;        // accent, used faintly in the specular spot
};

float roundedBoxDistance(vec2 point, vec2 halfSize, float cornerRadius)
{
    vec2 q = abs(point) - halfSize + cornerRadius;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - cornerRadius;
}

void main()
{
    vec2 uv = qt_TexCoord0;
    vec2 point = (uv - 0.5) * itemSize;
    float distanceToEdge = roundedBoxDistance(point, itemSize * 0.5, radius);
    float coverage = clamp(0.5 - distanceToEdge * devicePixelRatio, 0.0, 1.0);

    float fillAlpha = fillColor.a * mix(1.35, 0.8, uv.y) * (1.0 + 0.5 * hover);
    vec4 color = vec4(fillColor.rgb * fillAlpha, fillAlpha);

    vec2 pixel = uv * itemSize;
    vec2 toPointer = pixel - pointer;
    float pointerFalloff = exp(-dot(toPointer, toPointer) / (0.18 * dot(itemSize, itemSize)));

    // Specular spot under the pointer.
    float spot = pointerFalloff * hover * highlightAmount * 0.16;
    vec3 spotColor = mix(vec3(1.0), tintColor.rgb, 0.35);
    color += vec4(spotColor * spot, spot);

    // Rim: thin band inside the edge, lit from the top-left and from the pointer.
    float band = 1.0 - smoothstep(0.0, 1.1, abs(distanceToEdge + 0.75));
    vec2 direction = normalize(point + vec2(1e-4));
    float lightFacing = clamp(dot(direction, normalize(vec2(-0.55, -0.85))) * 0.5 + 0.5, 0.0, 1.0);
    float rim = band * (0.07 + 0.16 * lightFacing + 0.35 * pointerFalloff * hover * highlightAmount);
    color += vec4(vec3(rim), rim);

    fragColor = color * coverage * qt_Opacity;
}
