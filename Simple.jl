using Plots
using LinearAlgebra
using ProgressMeter

dt = 0.01

mutable struct Particle
    r::Array{Float64, 1}
    v::Array{Float64, 1}
end

p1 = Particle([1., 0., 0.], [0, 1., 0])

function step!(p::Particle)
    # len_r2 =
    len_r2 = dot(p.r, p.r)
    len_r3 = len_r2 * sqrt(len_r2)
    a = - (p.r / len_r3);
    p.r += p.v .* dt
    p.v += a .* dt
end

# initialize a 3D plot with 1 empty series
plt = plot(1, xlim=(-3,3), ylim=(-3,3),
                title = "PJP <3", marker = 0)
err_plt = plot(2)

# err1 = dot(p1.r, p1.r)
# println(p1, err1)
# step!(p1)
# err2 = dot(p1.r, p1.r)
# println(p1, err2)

# println("Error ", err2/err1 - 1, "%")

n = 1000
prog = Progress(n,1)
# build an animated gif by pushing new points to the plot, saving every 10th frame
@gif for i=1:n
    step!(p1)
    push!(err_plt, dot(p1.r, p1.r) - 1)
    push!(plt, p1.r[1], p1.r[2])
    next!(prog)
    plt
end every 10

plot(plt, err_plt, layout= grid(2, 1, heights=[0.7,0.3]))
