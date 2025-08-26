using TensorQEC
using DelimitedFiles
using Random
function generate_data(code,num_samples,filename)
    mkpath(filename)
    tanner = CSSTannerGraph(code)
    bimat = TensorQEC.stabilizers2bimatrix(stabilizers(code)).matrix
    writedlm(filename*"pcm.txt", Int.(bimat))
    lx,lz = logical_operator(tanner)

    writedlm(filename*"logical_x.txt",Int.(lx))
    writedlm(filename*"logical_z.txt",Int.(lz))
    qubit_number = size(bimat,2) ÷ 2
    em = iid_error(0.01,0.01,0.01,qubit_number)

    data = zeros(Bool,num_samples,2*qubit_number)
    data2 = zeros(Bool,num_samples,2*qubit_number)
    Random.seed!(110)
    for i in 1:num_samples
        @show i
        error_qubits = random_error_qubits(em)
        data[i,:] .= (getfield.(error_qubits.zerror,:x)...,getfield.(error_qubits.xerror,:x)...)
        syn = syndrome_extraction(error_qubits,tanner)
        ex,ez = TensorQEC._mixed_integer_programming_for_one_solution(tanner,syn)
        data2[i,:] .= (getfield.(ez,:x)...,getfield.(ex,:x)...)
    end
    writedlm(filename*"actual_error.txt", Int.(data))
    writedlm(filename*"initial_error.txt", Int.(data2))

    s = Mod2.(bimat) * Mod2.(data')
    writedlm(filename*"syndrome.txt", Int.(s'))
end
num_samples = 10000
generate_data(SurfaceCode(9,9),num_samples,"extemp/data/surface_code9/")
generate_data(SurfaceCode(21,21),num_samples,"extemp/data/surface_code21/")

bbcode = BivariateBicycleCode(6,12, ((3,0),(0,1),(0,2)), ((0,3),(1,0),(2,0)))
generate_data(bbcode,num_samples,"extemp/data/bb144/")