using Plots

dt = 0.001

mutable struct Particle
    x; y; z; vx; vy; vz
end

function len2(x, y, z)
    return (x^2 + y^2 + z^2)
end

p1 = Particle(1, 0, 0, 0, 0.5, 0)

function step!(p::Particle)
    r2 = len2(p.x, p.y, p.z)
    r3 = r2 * sqrt(r2)
    ax = - p.x / r3; ay = -p.y / r3; az = -p.z;
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.z += p.vz * dt
    p.vx += ax * dt
    p.vy += ay * dt
    p.vz += az * dt
end

# initialize a 3D plot with 1 empty series
plt = plot(1, xlim=(-2,2), ylim=(-2,2),
                title = "Hey", marker = 2)

# build an animated gif by pushing new points to the plot, saving every 10th frame
@gif for i=1:10000
    step!(p1)
    push!(plt, p1.x, p1.y)
end every 1000
