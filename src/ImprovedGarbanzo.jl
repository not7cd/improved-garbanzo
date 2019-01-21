# N-body integrator with stupid name
module ImprovedGarbanzo
include("common.jl")

using .common
using Plots
using LinearAlgebra
using ProgressMeter
pyplot()

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
            a -= (dr / r3) * 0.5
        end
        rk4!(p1, a, h)
    end
end


"""
Performs full simulation during `n` steps.
it calls `output` function every  `output_n` steps,
where `output_n` = `n` / `1000`
"""
function perform!(n, ensemble::Vector{Particle}, output, h=0.0001)
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

function prep_plot(ensemble)
    lim = (-2, 2)
    marker = (:cross, 3, stroke(0))
    global plt = scatter3d(1, m = marker,
        ylim=lim, xlim=lim, zlim=lim)

    for i=2:length(ensemble)
        scatter3d!(1, m = marker)
    end
end

function print_out(ensemble::Vector{Particle})
    println(stderr, ensemble[1])
end

"""
Adds subsequent postitions of particles in the system
to draw trajectory trails.
"""
function plot_trajectory_out(ensemble::Vector{Particle})
    for (i, p) in enumerate(ensemble)
        push!(plt.series_list[i], p.r[1], p.r[2], p.r[3])
    end
end

"""
Every time it creates new plot to present
only current position of particles in the system.
"""
function plot_distribution_out(ensemble::Vector{Particle})
    lim = (-2, 2)
    marker = (:cross, 3, stroke(0))
    global plt = scatter3d(1, m = marker,
            ylim=lim, xlim=lim, zlim=lim)
    for (i, p) in enumerate(ensemble)
        push!(plt, p.r[1], p.r[2], p.r[3])
    end
end

"""
_Example_
Solves system of two similar bodies orbiting each other
"""
function ex_2body()
    e = [
        Particle([1., 0., 0.], [0., .5, 0.], 1.),
        Particle([0., 0., 0.], [0., -.5, 0.], 1.),
    ]
    prep_plot(e)
    perform!(1000000, e, plot_trajectory_out)
end

"""
_Example_
Most known solution to 3 body problem
"""
function ex_3body_figure8()
    p1 = 0.347111
    p2 = 0.532728
    e = [
        Particle([1., 0., 0.], [p1, p2, 0.], 1.),
        Particle([-1., 0., 0.], [p1, p2, 0.], 1.),
        Particle([-0., 0., 0.], [-2p1, -2p2, 0.], 1.)
    ]
    prep_plot(e)
    perform!(150000, e, plot_trajectory_out)
end

"""
_Example_
Solves system for `N` random bodies
"""
function ex_random(N)
    e = [Particle(
            2rand(Float32, 3) .- 1.,
            (2rand(Float32, 3) .- 1.)*4,
            1.)
        for i=1:N]

    perform!(15000, e, plot_distribution_out, 0.0001)
end

"""
_Example_
Solves system for 10 random bodies
"""
function ex_random_10()
    ex_random(10)
end

# perform!(150000, e, plot_trajectory_out)
# ex_random(100)
# plot(plt, size = (500, 500))

end

doc = """ImprovedGarbanzo
Simple N-body simulator

Usage:
  ImprovedGarbanzo.jl perform <N>
  ImprovedGarbanzo.jl -h | --help
  ImprovedGarbanzo.jl --version

Options:
  -h --help     Show this screen.
  --version     Show version.
  --euler
  --rk4

"""
using DocOpt  # import docopt function

function cli()

  arguments = docopt(doc, version=v"1.0.0")

  aliases = Dict(
    "p" => "perform",
  )

  for (key, value) in arguments
    if value != true ; continue ; end

    if haskey(aliases, key)
      key = aliases[key]
    end
  end

  if haskey(arguments, "perform")
      println(arguments)
      N = parse(Int ,arguments["<N>"])
      ImprovedGarbanzo.ex_random(N)
      return
  end

  error("Invalid cli input.")

end

cli()
