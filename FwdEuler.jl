using Plots
using LinearAlgebra
using ProgressMeter
gr()
theme(:solarized_light)

dt = 0.00001
m1 = 0.6
m2 = 1 - m1

mutable struct Particle
    r::Vector{Float64}
    v::Vector{Float64}
end

function step!(p::Particle)
    len_r2 = dot(p.r, p.r)
    len_r3 = len_r2 * sqrt(len_r2)
    a = - (p.r / len_r3);
    p.r += p.v .* dt
    p.v += a .* dt
end

p1 = Particle([1., 0., 0.], [0, .5, 0])

# initialize a 3D plot with 1 empty series
err_plt = plot(1, title= "Error")
plt = plot(1, xlim=(-1.2,1.2), ylim=(-1.2,1.2),
                title = "PJP <3", size = (800, 800),
                m = (:cross, 3, stroke(0)))

n = 300
prog = Progress(n,1)
# build an animated gif by pushing new points to the plot, saving every 10th frame
for i=1:n
    for j=1:5000
        step!(p1)
    end
    push!(err_plt, dot(p1.r, p1.r) - 1)
    push!(plt, p1.r[1], p1.r[2])
    next!(prog)
end

plot(plt, err_plt, layout= grid(2, 1, heights=[0.7,0.3]), size = (500, 700))
