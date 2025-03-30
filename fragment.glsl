// uniform float uTime;
// uniform vec2 uResolution;

// #define MAX_STEPS 100
// #define MAX_DIST 100.0
// #define SURFACE_DIST 0.01

// float sdSphere(vec3 p, float radius) {
//     return length(p) - radius;
// }

// float scene(vec3 p) {
//   float plane = p.y + 1.0;
//   float sphere1 = sdSphere(p - vec3(1.0 + cos(uTime), 0.7, 0.0), 1.0);
//   float sphere2 = sdSphere(p + vec3(1.0, 0.5 + sin(uTime)/2.0, 0.0), 1.0);

//   float distance1 = min(sphere1, sphere2);
//   float distance2 = min(plane, distance1);
//   return distance2;
// }

// float raymarch(vec3 ro, vec3 rd) {
//   float dO = 0.0;
//   vec3 color = vec3(0.0);

//   for(int i = 0; i < MAX_STEPS; i++) {
//     vec3 p = ro + rd * dO;
//     float dS = scene(p);

//     dO += dS;

//     if(dO > MAX_DIST || dS < SURFACE_DIST) {
//         break;
//     }
//   }
//   return dO;
// }

// vec3 getNormal(vec3 p) {
//   vec2 e = vec2(.01, 0);

//   vec3 n = scene(p) - vec3(
//     scene(p-e.xyy),
//     scene(p-e.yxy),
//     scene(p-e.yyx));

//   return normalize(n);
// }

// float softShadows(vec3 ro, vec3 rd, float mint, float maxt, float k ) {
//   float resultingShadowColor = 1.0;
//   float t = mint;
//   for(int i = 0; i < 50 && t < maxt; i++) {
//       float h = scene(ro + rd*t);
//       if( h < 0.001 )
//           return 0.0;
//       resultingShadowColor = min(resultingShadowColor, k*h/t );
//       t += h;
//   }
//   return resultingShadowColor ;
// }

// void main() {
//   vec2 uv = gl_FragCoord.xy/uResolution.xy;
//   uv -= 0.5;
//   uv.x *= uResolution.x / uResolution.y;

//   // Light Position
//   vec3 lightPosition = vec3(-10.0, 10.0, 10.0);

//   vec3 ro = vec3(0.0, 0.0, 5.0);
//   vec3 rd = normalize(vec3(uv, -1.0));

//   float d = raymarch(ro, rd);
//   vec3 p = ro + rd * d;

//   vec3 color = vec3(0.0);

//   if(d<MAX_DIST) {
//     vec3 normal = getNormal(p);
//     vec3 lightDirection = normalize(lightPosition - p);

//     float diffuse = max(dot(normal, lightDirection), 0.0);
//     float shadows = softShadows(p, lightDirection, 0.1, 5.0, 64.0);
//     color = vec3(1.0, 1.0, 1.0) * diffuse * shadows;
//   }

//   gl_FragColor = vec4(color, 1.0);
// }

///////////////////////////////////////////////////////////////////////

uniform float uTime;
uniform vec2 uResolution;

#define MAX_STEPS 80
#define MAX_DIST 110.0
#define SURFACE_DIST 0.01

// I recommend setting up your codebase with glsify so you can import these functions
// This function comes from glsl-rotate https://github.com/dmnsgn/glsl-rotate/blob/main/rotation-3d.glsl
mat4 rotation3d(vec3 axis, float angle) {
  axis = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return mat4(
    oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
    0.0,                                0.0,                                0.0,                                1.0
  );
}

vec3 rotate(vec3 v, vec3 axis, float angle) {
  mat4 m = rotation3d(axis, angle);
  return (m * vec4(v, 1.0)).xyz;
}

// Tweaked Cosine color palette function from Inigo Quilez
vec3 getColor(float amount) {
  vec3 color = vec3(0.4, 0.4, 0.9) + vec3(0.5) * cos(6.2831 * (vec3(0.00, 0.15, 0.20) + amount * vec3(1.0, 0.7, 0.4	)));
  return color * amount;
}

vec3 repeat(vec3 p, float c) {
  return mod(p,c)-0.5*c;
}

float sdSphere(vec3 p, float radius) {
    return length(p) - radius;
}

float scene(vec3 p) {
  vec3 s = repeat(p - vec3(0.0, 0.0, -5.0), 4.0);
  float sphereDist = length(s) - 0.5;

  float distance = sphereDist;

  return distance;
}

float raymarch(vec3 ro, vec3 rd) {
  float dO = 0.0;
  vec3 color = vec3(0.0);

  for(int i = 0; i < MAX_STEPS; i++) {
    vec3 p = ro + rd * dO;
    float dS = scene(p);

    dO += dS;

    if(dO > MAX_DIST || dS < SURFACE_DIST) {
        break;
    }
  }
  return dO;
}

vec3 getNormal(vec3 p) {
  vec2 e = vec2(.01, 0);

  vec3 n = scene(p) - vec3(
    scene(p-e.xyy),
    scene(p-e.yxy),
    scene(p-e.yyx));

  return normalize(n);
}

void main() {
  vec2 uv = gl_FragCoord.xy/uResolution.xy;
  uv -= 0.5;
  uv.x *= uResolution.x / uResolution.y;

  // Light Position
  vec3 lightPosition = vec3(-100.0 * cos(uTime * 0.2), 100.0 * sin(uTime * 0.5), 100.0 * cos(-uTime * 0.5));

  vec3 ro = vec3(0.0, 0.0, 5.0 - uTime * 2.0);
  vec3 rd = rotate(normalize(vec3(uv, -1.0)), vec3(0.0, 1.0, 0.0), -uTime * 0.1);

  float d = raymarch(ro, rd);
  vec3 p = ro + rd * d;

  vec3 color = vec3(0.0);

  if(d<MAX_DIST) {
    vec3 normal = getNormal(p);
    vec3 lightDirection = normalize(lightPosition - p);
    
    float diffuse = max(dot(normal, lightDirection), 0.0);
    color = vec3(1.0, 1.0, 1.0) * getColor(diffuse);
  }

  gl_FragColor = vec4(color, 1.0);
}
///////////////////////////////////////////////////////////////////////////////////////////////

// uniform float uTime;
// uniform vec2 uResolution;

// #define MAX_STEPS 50
// #define MAX_DIST 100.0
// #define SURFACE_DIST 0.001
// #define inf 1e10

// // I recommend setting up your codebase with glsify so you can import these functions
// // This function comes from glsl-rotate https://github.com/dmnsgn/glsl-rotate/blob/main/rotation-3d.glsl
// mat4 rotation3d(vec3 axis, float angle) {
//   axis = normalize(axis);
//   float s = sin(angle);
//   float c = cos(angle);
//   float oc = 1.0 - c;

//   return mat4(
//     oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
//     oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
//     oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
//     0.0,                                0.0,                                0.0,                                1.0
//   );
// }

// vec3 rotate(vec3 v, vec3 axis, float angle) {
//   mat4 m = rotation3d(axis, angle);
//   return (m * vec4(v, 1.0)).xyz;
// }

// // Tweaked Cosine color palette function from Inigo Quilez
// vec3 getColor(float amount) {
//   vec3 color = vec3(0.3, 0.5, 0.9) +vec3(0.9, 0.4, 0.2) * cos(6.2831 * (vec3(0.30, 0.20, 0.20) + amount * vec3(1.0)));
//   return color * amount;
// }

// float smin(float a, float b, float k) {
//   float h = clamp(0.5 + 0.5 * (b-a)/k, 0.0, 1.0);
//   return mix(b, a, h) - k * h * (1.0 - h);
// }

// float sdSphere(vec3 p, float radius) {
//   return length(p) - radius;
// }

// float sdBox(vec3 p, vec3 b) {
//   vec3 q = abs(p) - b;
//   return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
// }

// // The SDF of this cross is 3 box stretched to infinity along all 3 axis
// float sdCross( in vec3 p ) {
//   float da = sdBox(p.xyz,vec3(inf,1.0,1.0));
//   float db = sdBox(p.yzx,vec3(1.0,inf,1.0));
//   float dc = sdBox(p.zxy,vec3(1.0,1.0,inf));
//   return min(da,min(db,dc));
// }

// float scene(vec3 p) {
//   vec3 p1 = rotate(p, vec3(1.0, 1.0, sin(uTime * 0.4)), uTime * 0.3);
//   float d = sdBox(p1,vec3(6.0));
//   float scale = 1.0;

//   for( int m=0; m<4; m++ ) {
//       vec3 a = mod( p1 * scale, 2.0 ) - 1.0;
//       scale *= 2.0;
//       vec3 r = 1.0 - 3.0 * abs(a);
//       float c = sdCross(r)/scale;

//       d = max(d,c);
//   }
//   return d;
// }

// float raymarch(vec3 ro, vec3 rd) {
//   float dO = 0.0;
//   vec3 color = vec3(0.0);

//   for(int i = 0; i < MAX_STEPS; i++) {
//     vec3 p = ro + rd * dO;
//     float dS = scene(p);

//     dO += dS;

//     if(dO > MAX_DIST || dS < SURFACE_DIST) {
//         break;
//     }
//   }
//   return dO;
// }

// vec3 getNormal(vec3 p) {
//   vec2 e = vec2(.01, 0);

//   vec3 n = scene(p) - vec3(
//     scene(p-e.xyy),
//     scene(p-e.yxy),
//     scene(p-e.yyx));

//   return normalize(n);
// }

// float softShadows(vec3 ro, vec3 rd, float mint, float maxt, float k ) {
//   float resultingShadowColor = 1.0;
//   float t = mint;
//   for(int i = 0; i < 50 && t < maxt; i++) {
//       float h = scene(ro + rd*t);
//       if( h < 0.001 )
//           return 0.0;
//       resultingShadowColor = min(resultingShadowColor, k*h/t );
//       t += h;
//   }
//   return resultingShadowColor ;
// }

// void main() {
//   vec2 uv = gl_FragCoord.xy/uResolution.xy;
//   uv -= 0.5;
//   uv.x *= uResolution.x / uResolution.y;

//   // Light Position
//   vec3 lightPosition = vec3(-1.0, 20.0, 20.0);

//   vec3 ro = vec3(0.0, 0.0, 25.0);
//   vec3 rd = normalize(vec3(uv, -1.0));

//   float d = raymarch(ro, rd);
//   vec3 p = ro + rd * d;

//   vec3 color = vec3(0.0);

//   if(d<MAX_DIST) {
//     vec3 normal = getNormal(p);
//     vec3 lightDirection = normalize(lightPosition - p);
    
//     float diffuse = max(dot(normal, lightDirection), 0.0);
//     float shadows = softShadows(p, lightDirection, 0.1, 5.0, 64.0);
//     color = vec3(1.0, 1.0, 1.0) * getColor(diffuse * shadows);
//   }

//   gl_FragColor = vec4(color, 1.0);
// }


/////////////////////////////////////////////////////////////////////////////////////////////////////

// Inspired by the work of @stormoid               
// uniform float uTime;
// uniform vec2 uResolution;
// uniform sampler2D uTexture;

// #define MAX_STEPS 100
// #define MAX_DIST 250.0
// #define SURFACE_DIST 0.001
// #define MAX_OCTAVES 5

// float linstep(float mn, float mx, float x){
//   return clamp((x-mn)/(mx-mn),0.,1.);
// }

// vec3 noised(vec2 x){
//   vec2 p=floor(x);
//   vec2 f=fract(x);
//   vec2 u=f*f*(3.-2.*f);

//   float a=textureLod(uTexture,(p+vec2(.0,.0))/256.,0.).x;
//   float b=textureLod(uTexture,(p+vec2(1.0,.0))/256.,0.).x;
//   float c=textureLod(uTexture,(p+vec2(.0,1.0))/256.,0.).x;
//   float d=textureLod(uTexture,(p+vec2(1.0,1.0))/256.,0.).x;
 
//   float noiseValue = a+(b-a)*u.x+(c-a)*u.y+(a-b-c+d)*u.x*u.y;
//   vec2 noiseDerivative = 6.*f*(1.-f)*(vec2(b-a,c-a)+(a-b-c+d)*u.yx);

//   return vec3(noiseValue,noiseDerivative);
// }

// mat2 m=mat2(.8,-.6,.6,.8);

// float terrain(vec2 p){
//   vec2 p1 = p * 0.06;
//   float a = -0.1;
//   float b = 1.9;
//   vec2 d = vec2(0.0);
//   float scl = 2.95;

//   for( int i=0; i<MAX_OCTAVES; i++ ) {
//     vec3 n = noised(p1);
//     d+=n.yz;
//     a += b*n.x/(dot(d,d) + 1.0);
//     b *= -0.4;
//     a *= .85;
//     p1 = m*p1*scl;
//   }
  
//   return a*3.0;
// }

// float scene(vec3 p) {
//   float d = p.y - terrain(p.xz);
//   return d;
// }

// float raymarch(vec3 ro, vec3 rd) {
//   float dO = 0.0;
//   vec3 color = vec3(0.0);

//   for(int i = 0; i < MAX_STEPS; i++) {
//     vec3 p = ro + rd * dO;
//     float dS = scene(p);

//     dO += dS;

//     if(dO > MAX_DIST || dS < SURFACE_DIST) {
//         break;
//     }
//   }
//   return dO;
// }

// vec3 lightPosition = vec3(-1.0, 0.0, 0.5);

// // This fog is presented in Inigo Quilez's article
// // It's a version of the fog function that keeps the "fog" at the
// // bottom of the scene, and doesn't let it go above the horizon/mountains
// vec3 fog(vec3 ro,vec3 rd,vec3 col,float d){
//   vec3 pos=ro+rd*d;
//   float sunAmount = max(dot(rd,lightPosition),0.0);
  
//   const float b=1.3;
//   // Applying exponential decay to fog based on distance
//   float fogAmount = .2*exp(-ro.y*b) * (1.-exp(-d*rd.y*b))/rd.y;
//   vec3 fogColor = mix(vec3(0.5,0.2,0.15), vec3(1.1,0.6,0.45), pow(sunAmount,2.0));

//   return mix(col, fogColor, clamp(fogAmount,0.0,1.0));
// }

// // This function comes from @stormoid's work and is used to add
// // a fake atmospherical scattering effect at the horizon line
// vec3 scatter(vec3 ro, vec3 rd) {
//   float sunAmount = max(dot(rd,lightPosition) * 0.5 + 0.5, 0.0);
//   float depth = 1.0 - (ro + rd * (MAX_DIST)).y * 10.0;
//   float hori = (linstep(-400.0 ,0.0 ,depth) - linstep(0.0, 400.0, depth)) * 1.04;
//   hori *= pow(sunAmount, 0.04);
  
//   vec3 col = vec3(0);
//   col += pow(hori, 100.0) * vec3(1.0 , 0.7, 0.5);
//   col += pow(hori, 25.0) * vec3(1.0, 0.5, 0.25) * 1.2;
//   col += pow(hori, 7.0) * vec3(1.0, 0.4, 0.25) * 1.8;
  
//   return col;
// }


// vec3 getNormal(vec3 p) {
//   vec2 e = vec2(.01, 0);

//   vec3 n = scene(p) - vec3(
//     scene(p-e.xyy),
//     scene(p-e.yxy),
//     scene(p-e.yyx));

//   return normalize(n);
// }

// float softShadows(vec3 ro, vec3 rd, float mint, float maxt, float k ) {
//   float resultingShadowColor = 1.0;
//   float t = mint;
//   for(int i = 0; i < 50 && t < maxt; i++) {
//       float h = scene(ro + rd*t);
//       if( h < 0.001 )
//           return 0.0;
//       resultingShadowColor = min(resultingShadowColor, k*h/t );
//       t += h;
//   }
//   return resultingShadowColor ;
// }

// void main() {
//   vec2 uv = gl_FragCoord.xy/uResolution.xy;
//   uv -= 0.5;
//   uv.x *= uResolution.x / uResolution.y;

//   vec3 ro = vec3(0.0, 18.0, 5.0 - uTime * 10.0);
//   vec3 rd = normalize(vec3(uv, -1.0));

//   float d = raymarch(ro, rd);
//   vec3 p = ro + rd * d;

//   vec3 color = vec3(0.0);

//   if(d<MAX_DIST) {
//     vec3 normal = getNormal(p);
//     vec3 lightDirection = normalize(lightPosition - p);
    
//     float ambient = clamp(0.5 + .5*normal.y, 0.0, 1.0);
//     float diffuse = max(dot(normal, lightDirection), 0.0);
//     float shadows = softShadows(p, lightDirection, 0.1, 5.0, 64.0);
//     color=vec3(0.25,0.25,0.3) * (vec3(0.10,0.11,0.12) * ambient + 2.0 * vec3(0.9,0.4,0.25) * diffuse) * shadows;
//   }

//   color = fog(ro, rd, color, d) + scatter(ro, rd);
//   gl_FragColor = vec4(color, 1.0);
// }
