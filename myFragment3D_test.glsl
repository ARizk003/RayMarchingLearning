precision mediump float;

uniform float uTime;
uniform float uTime2;
uniform vec2 uResolution;

// Signed distance function for a sphere
float sdfSphere(vec3 p, float r) {
    return length(p) - r;
}

// Combine two SDFs using the union operation
float sdfUnion(float d1, float d2) {
    return min(d1, d2);
}

// Raymarching function
float rayMarch(vec3 ro, vec3 rd) {
    float t = 0.0; // Distance traveled along the ray
    for (int i = 0; i < 100; i++) { // Maximum steps
        vec3 p = ro + t * rd; // Current point along the ray

        // Main sphere at the origin
        float distMainSphere = sdfSphere(p, 1.0);

        // Small sphere orbiting around the main sphere
        vec3 orbitCenter = vec3(2.0 * cos(uTime), 0.0, 2.0 * sin(uTime)); // Orbit radius = 2.0
        float distSmallSphere = sdfSphere(p - orbitCenter, 0.3); // Small sphere radius = 0.3

        // Combine the two spheres
        float dist = sdfUnion(distMainSphere, distSmallSphere);

        if (dist < 0.001) return t; // Hit the surface
        t += dist; // Move along the ray
        if (t > 100.0) break; // Exit if too far
    }
    return -1.0; // No hit
}

// Function to calculate the normal at a point using the gradient of the SDF
vec3 calculateNormal(vec3 p) {
    float epsilon = 0.001; // Small offset for numerical gradient
    vec3 dx = vec3(epsilon, 0.0, 0.0);
    vec3 dy = vec3(0.0, epsilon, 0.0);
    vec3 dz = vec3(0.0, 0.0, epsilon);

    float nx = sdfSphere(p + dx, 1.0) - sdfSphere(p - dx, 1.0);
    float ny = sdfSphere(p + dy, 1.0) - sdfSphere(p - dy, 1.0);
    float nz = sdfSphere(p + dz, 1.0) - sdfSphere(p - dz, 1.0);

    return normalize(vec3(nx, ny, nz));
}

void main() {
    // Normalize fragment coordinates to [-1, 1]
    vec2 uv = gl_FragCoord.xy / uResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= uResolution.x / uResolution.y; // Correct aspect ratio

    // Camera setup
    vec3 ro = vec3(0.0, 0.0, 5.0); // Ray origin (camera position)
    vec3 rd = normalize(vec3(uv, -1.0)); // Ray direction

    // Perform raymarching
    float t = rayMarch(ro, rd);

    // Determine color based on hit or miss
    vec3 color = vec3(0.41, 0.27, 0.27); // Default background color (black)
    if (t > 0.0) {
        vec3 p = ro + t * rd; // Point of intersection

        // Calculate normal at the intersection point
        vec3 normal = calculateNormal(p);

        // Light setup
        vec3 lightPos = vec3(5.0 * sin(uTime), 5.0 * cos(uTime), 5.0); // Light position
        vec3 lightDir = normalize(lightPos - p); // Direction to the light

        // Diffuse lighting (Lambertian reflection)
        float diffuse = max(dot(normal, lightDir), 0.0);

        // Determine which sphere is hit
        vec3 orbitCenter = vec3(2.0 * cos(uTime), 0.0, 2.0 * sin(uTime)); // Orbiting sphere center
        float distToSmallSphere = sdfSphere(p - orbitCenter, 0.3);

        // Set colors for the spheres
        vec3 mainSphereColor = vec3(0.84, 0.07, 0.07); // Red for the main sphere
        vec3 smallSphereColor = vec3(0.17, 0.07, 0.84); // Green for the small sphere

        // Choose color based on which sphere is hit
        color = distToSmallSphere < 0.001 ? smallSphereColor : mainSphereColor;

        // Apply diffuse lighting
        color *= diffuse;
    }

    gl_FragColor = vec4(color, 1.0);
}