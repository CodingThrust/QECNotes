using TensorQEC

surface_code_stabilizers = stabilizers(SurfaceCode(3, 3))
tannerxz = CSSTannerGraph(surface_code_stabilizers);

using Random
Random.seed!(10)
error_model = FlipError(0.1)
error_qubits = random_error_qubits(9, error_model)

sydrome = sydrome_extraction(error_qubits, tannerxz.stgz)
decoder = BPOSD(100)
res = decode(decoder, tannerxz.stgz, 0.1, sydrome)
res.success_tag
res.error_qubits
check_logical_error(error_qubits,res.error_qubits, tannerxz.stgx.H)

multi_round_qec(tannerxz.stgx,decoder,error_model,tannerxz.stgz;rounds = 1000)

pvec = 0.08:0.002:0.10
rounds = 100000
logical_errors = Vector{Float64}[]
for d in [3,5,7]
    @show d
    st = stabilizers(SurfaceCode(d, d))
    tannerxz = CSSTannerGraph(st)
    logical_errors_vec = Float64[]
    for p in pvec
        error_model = FlipError(p)
        res = multi_round_qec(tannerxz.stgx,decoder,error_model,tannerxz.stgz;rounds)
        push!(logical_errors_vec, res.logical_error_rate)
    end
    push!(logical_errors,logical_errors_vec)
end

using CairoMakie
fig =lines(pvec,pvec,color = :red, label = "d=1")
lines!(fig.axis, pvec,logical_errors[1], color = :orange, label = "d=3")
lines!(fig.axis, pvec,logical_errors[2], color = :green, label = "d=5")
lines!(fig.axis, pvec,logical_errors[3], color = :blue, label = "d=7")
axislegend(fig.axis; position = :rb, labelsize = 15)
fig


using CairoMakie
logical_errors =[
 [0.08312, 0.08721, 0.09023, 0.09299, 0.09776, 0.09984, 0.10462, 0.10773, 0.11142, 0.11501, 0.12],
 [0.07645, 0.08139, 0.08617, 0.09, 0.09372, 0.09986, 0.1065, 0.10898, 0.11618, 0.11878, 0.12271],
 [0.07132, 0.07527, 0.08075, 0.08754, 0.09009, 0.09652, 0.10289, 0.10802, 0.11434, 0.11985, 0.12717]]
 pvec = 0.08:0.002:0.10
#  fig =lines(pvec,pvec,color = :red, label = "d=1")
 fig = Figure()
# Create an axis with title and labels
ax = Axis(fig[1, 1],  xlabel = "Physical Error Rate", ylabel = "Logical Error Rate")
# Create a line plot, set color and label
lines!(ax, pvec,logical_errors[1], color = :orange, label = "d=3")
lines!(ax, pvec,logical_errors[2], color = :green, label = "d=5")
lines!(ax, pvec,logical_errors[3], color = :blue, label = "d=7")
scatter!(ax,0.1,0.12,marker = :xcross,markersize = 20, color = :red)
axislegend(ax; position = :rb, labelsize = 15)
fig
save("extemp/threshold.svg", fig)
