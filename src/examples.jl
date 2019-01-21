
"""
INITIAL POSITIONS: (-1,0), (1,0), (0,0)
INITIAL VELOCITIES: (p1,p2), (p1,p2), (-2p1,-2p2)
"""
function generate_example_3body(p1, p2)
    [
        Particle([1., 0., 0.], [p1, p2, 0.], 1.),
        Particle([-1., 0., 0.], [p1, p2, 0.], 1.),
        Particle([-0., 0., 0.], [-2p1, -2p2, 0.])
    ]
end

function generate_example_Nbody(N)
    e = [Particle(
            2rand(Float32, 3) .- 1.,
            2rand(Float32, 3) .- 1.
            )
        for i=1:N]
end

example_figure_8 = generate_example_3body(0.347111, 0.532728)
example_seq_I_2_A = generate_example_3body(0.306893, 0.125507)

example_2body = [
    Particle([1., 0., 0.], [0., .5, 0.], 1.),
    Particle([0., 0., 0.], [0., -.5, 0.], 1.),
]
