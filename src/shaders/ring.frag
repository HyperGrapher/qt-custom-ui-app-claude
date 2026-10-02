#version 440

// Progress ring drawn with distance functions: a faint track, a gradient arc with round
// caps, a soft glow, and a bright "comet head" at the tip of the arc.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float value;     // 0..1
    float thickness; // in pixels
    float devicePixelRatio;
    float glow;      // 0..1 extra glow, used for emphasis
    vec2 itemSize;
    vec4 startColor;
    vec4 endColor;
    vec4 trackColor;
};

const float kTau = 6.28318530718;

vec4 over(vec4 top, vec4 bottom)
{
    return top + bottom * (1.0 - top.a);
}

void main()
{
    float size = min(itemSize.x, itemSize.y);
    vec2 point = (qt_TexCoord0 - 0.5) * itemSize;
    float glowRoom = thickness * 1.6;
    float ringRadius = size * 0.5 - thickness * 0.5 - glowRoom;
    float halfThickness = thickness * 0.5;
    float pixel = 1.0 / devicePixelRatio;

    float radial = length(point);
    float ringDistance = abs(radial - ringRadius) - halfThickness;

    // Angle measured clockwise from 12 o'clock, in 0..1.
    float angle = atan(point.x, -point.y) / kTau;
    angle = angle < 0.0 ? angle + 1.0 : angle;

    float clampedValue = clamp(value, 0.0, 1.0);
    float headAngle = clampedValue * kTau;
    vec2 tail = vec2(0.0, -ringRadius);
    vec2 head = ringRadius * vec2(sin(headAngle), -cos(headAngle));

    float tailDistance = length(point - tail);
    float headDistance = length(point - head);
    float capDistance = min(tailDistance, headDistance) - halfThickness;
    bool onArc = angle <= clampedValue;
    float arcDistance = onArc ? ringDistance : capDistance;
    float visible = step(0.001, clampedValue);

    float trackAlpha = (1.0 - smoothstep(-pixel, pixel, ringDistance)) * trackColor.a;
    vec4 color = vec4(trackColor.rgb * trackAlpha, trackAlpha);

    float along = clampedValue > 0.0 ? clamp(angle / clampedValue, 0.0, 1.0) : 0.0;
    // Outside the arc's angle range only the caps are visible; color each by its own end.
    float capAlong = tailDistance < headDistance ? 0.0 : 1.0;
    vec3 arcRgb = mix(startColor.rgb, endColor.rgb, onArc ? along : capAlong);

    float glowAlpha = exp(-max(arcDistance, 0.0) / (thickness * 0.55)) * (0.28 + 0.3 * glow) * visible;
    color = over(vec4(arcRgb * glowAlpha, glowAlpha) * (1.0 - step(arcDistance, 0.0)), color);

    float arcAlpha = (1.0 - smoothstep(-pixel, pixel, arcDistance)) * visible;
    color = over(vec4(arcRgb * arcAlpha, arcAlpha), color);

    float headGlow = exp(-dot(point - head, point - head) / (thickness * thickness * 0.6)) * visible;
    vec3 headRgb = mix(endColor.rgb, vec3(1.0), 0.65);
    color = over(vec4(headRgb * headGlow * 0.85, headGlow * 0.85), color);

    fragColor = color * qt_Opacity;
}
