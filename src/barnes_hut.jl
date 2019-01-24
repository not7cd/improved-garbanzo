import Base.push!
using LinearAlgebra

mutable struct Body
    r::Vector{Float64}
    v::Vector{Float64}
    m::Float64
end

struct Quad
    xb::Float64
    yb::Float64
    xt::Float64
    yt::Float64
end

mutable struct BHtree
    r::Vector{Float64}
    m::Float64

    quad::Quad
    nw::Union{BHtree, Body, Nothing}
    ne::Union{BHtree, Body, Nothing}
    sw::Union{BHtree, Body, Nothing}
    se::Union{BHtree, Body, Nothing}

    function BHtree(quad::Quad)
        new([0, 0],
            0,
            quad,
            nothing,
            nothing,
            nothing,
            nothing)
    end
end

BHnode = Union{BHtree, Body, Nothing}

function init_tree(quad=Quad(-10, -10, 10, 10))
    BHtree(quad)
end

function build_tree(ensemble)
    root = init_tree()
    for particle in ensemble
        try
            push!(root, particle)
        catch exc
            @debug "skipping body" exc
        end
    end
    return root
end

function balance_center_of_mass!(t::BHnode)
    if t isa BHtree
        t.m = 0
        leafs = [t.nw, t.ne, t.sw, t.se]
        for l in leafs
            if l != nothing
                t.r = (t.r * t.m + l.r * l.m) / (t.m + l.m)
                t.m = t.m + l.m
            end
        end
    end
end

function push!(t::BHtree, b::Body)

    quad_symbol = fit(t.quad, b.r)
    leaf = getproperty(t, quad_symbol)
    if leaf isa Nothing
        setproperty!(t, quad_symbol, b)
    elseif leaf isa BHtree
        push!(leaf, b)
    elseif leaf isa Body
        b2 = leaf
        child = BHtree(
            quadrant_from_symbol(t.quad, quad_symbol)
        )
        setproperty!(t, quad_symbol, child)
        push!(child, b2)
        push!(child, b)
    end

    balance_center_of_mass!(t)
end

function quadrant_from_symbol(parent::Quad, symbol::Symbol)
    mid_x = (parent.xt + parent.xb) / 2
    mid_y = (parent.yt + parent.yb) / 2
    if symbol == :nw
        Quad(mid_x, mid_y, parent.xt, parent.yt)
    elseif symbol == :ne
        Quad(mid_x, parent.yb, parent.xt, mid_y)
    elseif symbol == :sw
        Quad(parent.xb, mid_y, mid_x, parent.yt)
    elseif symbol == :se
        Quad(parent.xb, parent.yb, mid_x, mid_y)
    end
end

function fit(quad::Quad, point)
    x = point[1]
    y = point[2]
    mid_x = (quad.xt + quad.xb) / 2
    mid_y = (quad.yt + quad.yb) / 2
    if !(quad.xb <= x < quad.xt
        && quad.yb <= y < quad.yt)
        throw(DomainError(point, "outside quadrant"))
    elseif mid_x < x && mid_y < y
        :nw
    elseif mid_x < x && mid_y >= y
        :ne
    elseif mid_x >= x && mid_y < y
        :sw
    elseif mid_x >= x && mid_y >= y
        :se
    else
        error("no quad")
    end
end

using Plots

function rectangle_from_coords(xb,yb,xt,yt)
    [
        xb yb
        xt yb
        xt yt
        xb yt
        xb yb
        NaN NaN
    ]
end

rect(q::Quad) = Shape([q.xb, q.xt, q.xt, q.xb], [q.yb, q.yb, q.yt, q.yt])
@recipe f(::Type{Quad}, q::Quad) = rect(q)
# @recipe f(::Type{Array{Body}}, e::Array{Body}) =
# @recipe f(::Type{Body}, b::Body) = (b.r[1], b.r[2])

@recipe function f(::Type{Val{:body_distribution}}, x, y, z)
    p = map(b -> (b.r[1], b.r[2]), y)
    a, b = zip(p)
    println(p)
    seriestype := :scatter
    x := a
    y := b

    ()
end


function width(q::Quad)
    abs(q.xt - q.xb)
end

function plot_bhnode!(my_plt, n::BHnode)
    if n isa BHtree
        r = rect(n.quad)
        v = collect(zip(r.x, r.y))
        for (x, y) in v
            push!(my_plt, x, y)
        end
        push!(my_plt, v[1][1], v[1][2])
        push!(my_plt, NaN, NaN)
        plot_bhnode!(my_plt, n.nw)
        plot_bhnode!(my_plt, n.ne)
        plot_bhnode!(my_plt, n.sw)
        plot_bhnode!(my_plt, n.se)
    end
    my_plt
end

function plot_bodies!(my_plt, ensemble::Vector{Body})

    for (i, p) in enumerate(ensemble)
        push!(my_plt, p.r[1], p.r[2])
    end
    my_plt
end

function generate_example_Nbody(N)
    e = [Body(
            2rand(Float32, 2) .- 1.,
            2rand(Float32, 2) .- 1.,
            1.)
        for i=1:N]
end

ensemble = [
    Body([0.563299, -0.135254, 0.115279], [-0.547044, 0.256697, -0.648452], 1.0),
    Body([-0.062891, -0.501245, -0.568135], [0.816119, 0.143996, 0.753906], 1.0),
    Body([0.473176, -0.5876, 0.56664], [0.793547, 0.510543, 0.0547936], 1.0),
    Body([-0.734561, 0.354197, 0.980844], [0.674463, -0.435813, 0.622977], 1.0),
    Body([-0.401376, 0.382082, 0.86666], [-0.929288, -0.407342, 0.513163], 1.0),
    Body([0.843067, -0.417499, -0.334527], [-0.924203, -0.216044, 0.111438], 1.0),
    Body([0.445615, -0.936267, 0.417503], [0.753769, 0.551013, -0.629933], 1.0),
    Body([-0.249496, -0.753273, 0.935374], [-0.43562, -0.366953, -0.764842], 1.0),
    Body([0.150283, 0.119875, -0.659424], [0.239267, 0.316603, -0.244475], 1.0),
    Body([0.802724, -0.429913, 0.527407], [0.216259, 0.724374, 0.795849], 1.0)]



θ = 0.5
ε = 0.0001
dt = 0.001

function rk4!(p::Body, a, h)
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

function leapfrog!(p::Body, a, h)
    p.r += 0.5h * p.v
    p.v += h * a
    p.r += 0.5h * p.v
end

function calculate_force(body, node::BHnode, θ=0.5)
    f = [0., 0.]
    for child in [node.nw, node.ne, node.sw, node.se]
        if child isa Body && body != child
            dr = body.r - child.r
            r2 = dot(dr, dr)
            r3 = r2 * √r2 + ε
            f -= (dr / r3) * node.m
        elseif child isa BHtree
            s = width(child.quad)
            dr = body.r - child.r
            r2 = dot(dr, dr)
            d = abs2(r2)

            if s/d < θ
                r3 = r2 * √r2 + ε
                f -= (dr / r3) * node.m
            else
                f -= calculate_force(body, child)
            end
        end
    end
    return f
end

function step!(ensemble, tree, h)
    for p1 in ensemble
        f = calculate_force(p1, tree)
        rk4!(p1, f, h)
    end
end

using ProgressMeter

ensemble = generate_example_Nbody(100)
lim = (-2, 2)
marker = (:cross, 3)

function perform!(n, ensemble::Vector{Body}, h=0.0001)
    hidden_n = 10
    output_n = Integer(n / hidden_n)

    println(stderr, "Performing simulation")
    prog = Progress(output_n, 1, "Computing...")
    tree = undef
    plt_quads = undef
    anim = Animation()
    for i=1:output_n
        for j=1:hidden_n
            tree = build_tree(ensemble)
            step!(ensemble, tree, h)
        end
        plt_quads = plot(1, framestyle=:zerolines, fill=false, c=false, linecolor=:blue)
        plot_bhnode!(plt_quads, tree)
        plt_scatter = scatter!(y=ensemble, m = marker,
            xlim=lim, ylim=lim, title="step $(i*hidden_n)", t=:body_distribution)

        frame(anim, plt_quads)
        next!(prog)
    end
    display(plt_quads)
    gif(anim)
end

perform!(100, ensemble)
