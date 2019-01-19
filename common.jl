module common

mutable struct Particle
    r::Vector{Float64}
    v::Vector{Float64}
    m::Float64
end

export Particle
end
