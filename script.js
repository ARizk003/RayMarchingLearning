let scene, camera, renderer;
let geometry, material, mesh;

// Function to load GLSL shader files
function loadShader(url) {
    return new Promise((resolve, reject) => {
        fetch(url)
            .then(response => response.text())
            .then(data => resolve(data))
            .catch(err => reject(err));
    });
}

async function init() {
    // Scene setup
    scene = new THREE.Scene();
    
    // Camera setup (perspective)
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.001, 1000);
    camera.position.z = 5;

    // Renderer setup
    renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth , window.innerHeight );
    document.getElementById('webgl-container').appendChild(renderer.domElement);

    // Load shaders
    const vertexShader = await loadShader('vertex.glsl');
    const fragmentShader = await loadShader('fragment.glsl');

    // Example light setup
    const light = new THREE.PointLight(0xffffff, 1, 100);
    light.position.set(10, 10, 10);
    scene.add(light);

    // Create ShaderMaterial with proper uniforms
    material = new THREE.ShaderMaterial({
        vertexShader: vertexShader,
        fragmentShader: fragmentShader,
        uniforms: {
            uResolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) }, // Updated uniform name
            uTime: { value: 0.0 } // Added time uniform
        },
        side: THREE.DoubleSide, // Ensure both sides of the plane are rendered
    });

    // Create geometry (just a plane to hold the shader)
    geometry = new THREE.PlaneGeometry(14, 8);

    mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);

    // Start animation loop
    animate();
}

// Animation loop
function animate() {
    requestAnimationFrame(animate);

    // Update time uniform
    material.uniforms.uTime.value += 0.01;

    renderer.render(scene, camera);
}

// Initialize the scene
init();

// Adjust the resolution when the window is resized
window.addEventListener('resize', () => {
    const width = window.innerWidth;
    const height = window.innerHeight;

    // Update renderer size
    renderer.setSize(width, height);

    // Update camera aspect ratio
    camera.aspect = width / height;
    camera.updateProjectionMatrix();

    // Update shader uniform for resolution
    material.uniforms.uResolution.value.set(width, height);
});
