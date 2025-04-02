precision mediump float;

uniform float uTime;
uniform vec2 uResolution;



float sdRoundedBox( in vec2 p, in vec2 b, in vec4 r )
{
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}

float sdCircle( vec2 p, float r )
{
    
    return (length(p) - r);
}

void main() {
    // Normalize fragment coordinates to [-1, 1] space
    vec2 uv = gl_FragCoord.xy / uResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= uResolution.x / uResolution.y; // Correct aspect ratio

    // Convert UV to 3D space
    vec2 p = vec2(uv.x, uv.y); // 2D coordinates in the plane

    // Define sphere properties
    float radius = 0.4 ; // Sphere radius
    vec2 CircleCenter1 = vec2(cos(uTime), cos(uTime)); // Sphere center

    // Compute signed distance to the sphere
    
    float distCircle =sdCircle(p - CircleCenter1, radius);
    float distRoundedBox = sdRoundedBox(p, vec2(0.5), vec4(0.1, 0.1, 0.1, 0.1)); // Rounded box
    float dist =min(distCircle, distRoundedBox); // Minimum distance to the sphere
    
    // Color the sphere and background
    vec3 color = dist < 0.0 ? vec3(0.0, 0.5, 1.0) : vec3(1.0, 0.5, 0.0); // Blue sphere, orange background

    // Smooth the edges of the sphere
    color = mix(vec3(1.0), color, smoothstep(0.0, 0.1, abs(dist)));

    // Output the color
    gl_FragColor = vec4(color, 1.0);
}