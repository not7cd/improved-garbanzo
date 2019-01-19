# N-body integrator with stupid name
include("common.jl")

using .common
using Plots
using LinearAlgebra
using ProgressMeter

ε = 0.0001

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

function step!(ensemble, h)
    for p1 in ensemble
        a = [0.,0.,0.]
        for p2 in ensemble
            if p1 == p2
                continue
            end
            dr = p1.r - p2.r
            r2 = dot(dr, dr)
            r3 = r2 * √r2 + ε
            a -= (dr / r3)
        end
        rk4!(p1, a, h)
    end
end

function perform(n, ensemble::Vector{Particle}, output, h=0.0001)
    hidden_n = 1000
    output_n = Integer(n / hidden_n)

    println(stderr, "Performing simulation")
    prog = Progress(output_n, 1, "Computing...")
    @gif for i=1:output_n
        for j=1:hidden_n
            step!(ensemble, h)
        end
        output(ensemble)
        next!(prog)
    end
end

e = [
    Particle([1., 0., 0.], [0., .5, 0.], 1.),
    Particle([0., 0., 0.], [0., -.5, 0.], 1.),
    Particle([-1., 0., 0.], [0., -.1, 0.], 1.)
    ]

plt = scatter(1, m = (:cross, 3, stroke(0)),
            ylim=(-1.2, 1.2), xlim=(-1.2,1.2))

plt_p = [scatter!(1, m = (:cross, 3, stroke(0))) for i=2:10]

function print_out(ensemble::Vector{Particle})
    println(stderr, ensemble[1])
end

function plot_out(ensemble::Vector{Particle})
    for (i, p) in enumerate(ensemble)
        push!(plt.series_list[i], p.r[1], p.r[2])
    end
end

function ex_3body_figure8()
    p1 = 0.347111
    p2 = 0.532728
    e = [
    Particle([1., 0., 0.], [p1, p2, 0.], 1.),
    Particle([-1., 0., 0.], [p1, p2, 0.], 1.),
    Particle([-0., 0., 0.], [-2p1, -2p2, 0.], 1.)
    ]
    perform(1500000, e, plot_out)
end

function ex_random_10()
    e = [Particle(
            -rand(Float32, 3),
            -rand(Float32, 3),
            1.)
        for i=1:10]
    perform(15000, e, plot_out)
end

# perform(150000, e, plot_out)
ex_random_10()
plot(plt, size = (500, 500))
