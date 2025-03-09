using TensorQEC

using Random
Random.seed!(1234)

function threshold(pvec,rounds)
    logical_errors = Vector{Float64}[]

    decoder = IPDecoder()
    for d in [3,5,7,9]
        @show d
        st = stabilizers(SurfaceCode(d, d))
        tannerxz = CSSTannerGraph(st)
        logical_errors_vec = Float64[]
        for p in pvec
            error_model = DepolarizingError(p)
            res = multi_round_qec(tannerxz,decoder,error_model;rounds)
            push!(logical_errors_vec, res.logical_error_rate)
        end
        push!(logical_errors,logical_errors_vec)
    end
    logical_errors
end


# pvec = 0.08:0.002:0.10
# pvec = 0.08:0.01:0.2
pvec = 0.05:0.002:0.07
rounds = 10000
logical_errors = threshold(pvec,rounds)

pvec = pvec *3

using CairoMakie

pvec = (0.05:0.002:0.07)*3
logical_errors = [[0.2001, 0.22, 0.2212, 0.2453, 0.2466, 0.2678, 0.2857, 0.2856, 0.2987, 0.3239, 0.3239],
[0.1974, 0.2084, 0.219, 0.2506, 0.2603, 0.2729, 0.2956, 0.3038, 0.327, 0.3493, 0.3563],
[0.1795, 0.1977, 0.2163, 0.2285, 0.2654, 0.277, 0.3025, 0.3229, 0.3482, 0.3651, 0.3878],
[0.1614, 0.1825, 0.2019, 0.2218, 0.249, 0.2691, 0.2993, 0.339, 0.3515, 0.3858, 0.4111]]
# fig =lines(pvec,pvec,color = :red, label = "d=1")
fig = lines(pvec,logical_errors[1], color = :orange, label = "d=3")
lines!(fig.axis, pvec,logical_errors[2], color = :green, label = "d=5")
lines!(fig.axis, pvec,logical_errors[3], color = :blue, label = "d=7")
lines!(fig.axis, pvec,logical_errors[4],color = :black, label = "d=9")
axislegend(fig.axis; position = :rb, labelsize = 15)
vlines!(fig.axis, 0.189)
fig
