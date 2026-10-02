#version 440

// Soft rounded-rectangle glow or shadow in a single pass (no blur). The visible shape is the
// item shrunk by "blur" on each side; the falloff fills the remaining border.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float radius;
    float blur;
    vec2 itemSize;
    vec4 color;
};

float roundedBoxDistance(vec2 point, vec2 halfSize, float cornerRadius)
{
    vec2 q = abs(point) - halfSize + cornerRadius;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - cornerRadius;
}

void main()
{
    vec2 point = (qt_TexCoord0 - 0.5) * itemSize;
    vec2 halfSize = max(itemSize * 0.5 - blur, vec2(1.0));
    float distanceToShape = roundedBoxDistance(point, halfSize, min(radius, min(halfSize.x, halfSize.y)));
    float x = clamp(distanceToShape / max(blur, 1.0), 0.0, 1.0);
    // Smooth cubic falloff that looks close to a gaussian blur.
    float strength = (1.0 - x) * (1.0 - x) * (1.0 - x);
    float alpha = color.a * strength;
    fragColor = vec4(color.rgb * alpha, alpha) * qt_Opacity;
}
