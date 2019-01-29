
mutable struct Body
    r::Vector{Float64}
    v::Vector{Float64}
    m::Float64
end

Base.rand(rng::AbstractRNG, ::Random.SamplerType{Body}) = Body(
    rand(rng, Float32, 2),
    rand(rng, Float32, 2),
    1.)

Base.randn(rng::AbstractRNG, ::Random.SamplerType{Body}) = Body(
    randn(rng, Float32, 2),
    randn(rng, Float32, 2),
    1.)
