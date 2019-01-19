include("common.jl")

using .common
using Plots
using LinearAlgebra
using ProgressMeter
gr()
theme(:solarized_light)

dt = 0.00001
m1 = 0.6
m2 = 1 - m1

function rk2!(p::Particle, a, h)
    k1_v = a
    k1_r = p.v

    k2_v = k1_r * h
    k2_r = k1_v * h

    p.r += k1_r * h
    p.v += k1_v * h
end

function rk4!(p::Particle, a, h)
    k1_v = a
    k1_r = p.v

    k2_v = a .* (k1_r*h/2)
    k2_r = p.v .* k1_v*h/2

    k3_v = a .* (k2_r*h/2)
    k3_r = p.v .* k2_v*h/2

    k4_v = a .* (k3_r*h)
    k4_r = p.v .* k3_v*h

    p.r += h/6 * (k1_r + 2*k2_r + 2*k3_r + k4_r)
    p.v += h/6 * (k1_v + 2*k2_v + 2*k3_v + k4_v)
end


p1 = Particle([1., 0., 0.], [0, 1., 0])

# initialize a 3D plot with 1 empty series
err_plt = plot(1, title= "Error")
plt = plot(1,  ylim=(-1.2, 1.2), xlim=(-1.2,1.2),
                title = "PJP <3", size = (800, 800),
                m = (:cross, 3, stroke(0)))



function step!(p::Particle)
    len_r2 = dot(p.r, p.r)
    len_r3 = len_r2 * sqrt(len_r2)
    a = - (p.r / len_r3);

    rk4!(p, a, dt)
end

n = 45
prog = Progress(n,1)
# build an animated gif by pushing new points to the plot, saving every 10th frame
for i=1:n
    for j=1:100000
        step!(p1)
    end
    push!(err_plt, dot(p1.r, p1.r) - 1)

    push!(plt, p1.r[1], p1.r[2])
    next!(prog)
end

plot(plt, err_plt, layout= grid(2, 1, heights=[0.7,0.3]), size = (500, 700))
