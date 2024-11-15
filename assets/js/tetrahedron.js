(async () => {
    const url = (lib) => `https://cdn.jsdelivr.net/npm/${lib}/+esm`;
    const datGui = await import(url('dat.gui'));
    const THREE = await import(url('three'));
    const { default: CameraControls } = await import(url('camera-controls'));

    const container = document.querySelector('.w');

    // Initialize renderer before using in CameraControls
    const renderer = new THREE.WebGLRenderer();

    const clientWidth = 640;
    const clientHeight = 640;

    // Resize renderer to fit container
    renderer.setSize(clientWidth, clientHeight);
    renderer.setClearColor(0xffffff);

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, 1.0, 0.1, 1000);
    camera.position.set(1, 1, 1);
    camera.lookAt(scene.position);

    CameraControls.install({ THREE: THREE });
    const cameraControls = new CameraControls(camera, renderer.domElement);

    const clock = new THREE.Clock(); // Declare clock instance for animate function

    // Define cube vertices
    const vertices = [
        [0, 0, 0], [0, 1, 0], [1, 1, 0], [1, 0, 0],
        [0, 0, 1], [0, 1, 1], [1, 1, 1], [1, 0, 1]
    ].map(v => new THREE.Vector3(...v.map(e => e - 0.5)));

    // Define cube edges (pairs of vertex indices)
    const cubeEdges = [
        [0, 1], [1, 5], [5, 4], [4, 0],
        [0, 3], [3, 2], [2, 6], [6, 7], [7, 3],
        [1, 2], [5, 6], [4, 7]
    ];

    // Tetrahedron sets (as per input choice)
    const tetrahedronSets = {
        'bourke': [
            [1, 5, 7, 8], [1, 4, 7, 8], [1, 2, 6, 7],
            [1, 2, 3, 7], [1, 3, 4, 7], [1, 5, 6, 7]
        ],
        'legacy': [
            [1, 3, 4, 8], [1, 3, 7, 8], [1, 5, 7, 8],
            [1, 7, 2, 3], [1, 7, 2, 5], [6, 7, 2, 5]
        ],
        'minimal': [
            [1, 4, 3, 8], [3, 6, 7, 8], [1, 6, 5, 8],
            [1, 3, 6, 8], [1, 2, 3, 6]
        ]
    };

    // Fixed colors for each tetrahedron
    const tetrahedronColors = [
        0xFF5733,  // Orange
        0x33FF57,  // Green
        0x3357FF,  // Blue
        0xFF33A1,  // Pink
        0xF0F033,  // Yellow
        0x33F0FF   // Cyan
    ];

    // Function to create a solid tetrahedron (mesh)
    function createTetrahedron(vtxIndices, color, separation, solid) {
        const geometry = new THREE.BufferGeometry();
        const points = vtxIndices.map(idx => {
            const originalVertex = vertices[idx - 1].clone();
            return originalVertex;
        });

        // Calculate centroid of the tetrahedron
        const centroid = computeCentroid(vtxIndices);

        // Apply separation factor
        const separatedPoints = points.map((point) => {
            const direction = new THREE.Vector3().subVectors(point, centroid).normalize();
            return point.add(direction.multiplyScalar(separation));
        });

        // Set up geometry vertices
        const positions = [];
        separatedPoints.forEach(point => {
            positions.push(point.x, point.y, point.z);
        });

        // Set the positions to the geometry
        geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));

        // Define the faces (two triangles for each tetrahedron)
        const indices = [
            0, 1, 2,
            0, 1, 3,
            0, 2, 3,
            1, 2, 3
        ];

        // Set the indices to the geometry
        geometry.setIndex(indices);

        // Create a material
        const material = new THREE.MeshBasicMaterial({
            color: color,
            wireframe: !solid, // Set wireframe to true if not solid
            transparent: !solid, // Make transparent if not solid
            opacity: solid ? 1 : 0.5, // Set opacity based on solid
            side: THREE.DoubleSide // Disable backface culling
        });


        // Create the mesh for the tetrahedron
        const tetrahedron = new THREE.Mesh(geometry, material);

        // Now create the edges of the tetrahedron
        const edgesGeometry = new THREE.EdgesGeometry(geometry);
        const edgesMaterial = new THREE.LineBasicMaterial({
            color: 0x000000,  // Color of the edges (black or any color you prefer)
            linewidth: 10      // Line width of the edges
        });

        const edges = new THREE.LineSegments(edgesGeometry, edgesMaterial);

        // Return both the tetrahedron (solid faces) and the edges (borders)
        return [tetrahedron, edges];
    }

    // Function to compute centroid of a tetrahedron
    function computeCentroid(vtxIndices) {
        const centroid = new THREE.Vector3();
        vtxIndices.forEach(idx => centroid.add(vertices[idx - 1]));
        return centroid.divideScalar(vtxIndices.length);
    }

    // Function to clear all tetrahedrons from scene
    function clearTetrahedrons() {
        for (let i = scene.children.length - 1; i >= 0; i--) {
            scene.remove(scene.children[i]);
        }
    }

    // GUI for switching datasets and controlling separation
    const gui = new datGui.GUI({ autoPlace: false });

    const params = {
        dataset: 'legacy', // Default dataset
        separation: -0.09,   // Default separation factor
        solid: true // Default solid state
    };

    const selectedTetrahedrons = tetrahedronSets[params.dataset];
    selectedTetrahedrons.forEach((tetra, index) => {
        const color = tetrahedronColors[index % tetrahedronColors.length];  // Use a color from the array
        const [tetrahedron, edges] = createTetrahedron(tetra, color, params.separation, params.solid);
        scene.add(tetrahedron);
        scene.add(edges);
    });

    gui.add(params, 'dataset', ['bourke', 'legacy', 'minimal']).onChange(value => {
        clearTetrahedrons(); // Clear existing tetrahedrons
        const selectedTetrahedrons = tetrahedronSets[value];
        selectedTetrahedrons.forEach((tetra, index) => {
            const color = tetrahedronColors[index % tetrahedronColors.length];  // Use a color from the array
            const [tetrahedron, edges] = createTetrahedron(tetra, color, params.separation, params.solid);
            scene.add(tetrahedron);
            scene.add(edges);
        });
    });

    gui.add(params, 'separation', -1.0, 1.0).step(0.01).onChange(value => {
        clearTetrahedrons(); // Clear and re-render tetrahedrons on separation change
        const selectedTetrahedrons = tetrahedronSets[params.dataset];
        selectedTetrahedrons.forEach((tetra, index) => {
            const color = tetrahedronColors[index % tetrahedronColors.length];  // Use a color from the array
            const [tetrahedron, edges] = createTetrahedron(tetra, color, value, params.solid);
            scene.add(tetrahedron);
            scene.add(edges);
        });
    });

    gui.add(params, 'solid').onChange(value => {
        clearTetrahedrons(); // Clear and re-render tetrahedrons on solid state change
        const selectedTetrahedrons = tetrahedronSets[params.dataset];
        selectedTetrahedrons.forEach((tetra, index) => {
            const color = tetrahedronColors[index % tetrahedronColors.length];  // Use a color from the array
            const [tetrahedron, edges] = createTetrahedron(tetra, color, params.separation, value);
            scene.add(tetrahedron);
            scene.add(edges);
        });
    });

    window.addEventListener('resize', onWindowResize, false);

    function onWindowResize() {
        camera.aspect = 1.0;
        camera.updateProjectionMatrix();
        renderer.setSize(clientWidth, clientHeight);
    }

    // Render function
    function animate() {
        const delta = clock.getDelta();
        const hasControlsUpdated = cameraControls.update(delta);
        requestAnimationFrame(animate);
        renderer.render(scene, camera);
    }

    container.appendChild(gui.domElement);
    container.appendChild(renderer.domElement);
    animate();
})();