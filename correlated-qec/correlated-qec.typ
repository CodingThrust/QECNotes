#show link: set text(blue)
#import "@preview/cetz:0.2.2": canvas, draw, tree
#import "@preview/quill:0.6.0": *
#set math.equation(numbering: "(1)")

#let zy(it) = {
  text(orange, [[ZY: #it]])
}

#let jinguo(it) = {
  text(red, [[JG: #it]])
}

#align(center)[
= Quantum Error Correction with Spatially Correlated Errors
_Jinguo Liu_
]

#zy[add more refs]
== Introduction
Traditional QEC schemes, such as the surface code and stabilizer formalism, predominantly assume independent error models, where qubit errors occur uncorrelated in space and time. These models underpin the theoretical promise of thresholds and code distances, ensuring protection against a fixed number of errors. However, real-world quantum hardware—including superconducting circuits, trapped ions, and photonic systems—exhibits correlated errors that defy these assumptions. Examples include crosstalk between adjacent qubits during simultaneous gate operations, spatially correlated noise in lattices, and joint errors following entangling gates like CNOT. Such correlations degrade the performance of conventional decoders, which are ill-equipped to handle complex error syndromes arising from these dependencies.  

We propose two key innovations to address this challenge:
- Learning device-specific error models from experimental data 
Tensor network methods provide a powerful framework for modeling correlated error channels in quantum circuits by leveraging their ability to efficiently represent high-dimensional quantum processes with structured correlations. To train the model, the loss function is defined as the negative log-likelihood of the experimental data. Automatic differentiation and gradient descent are then employed to iteratively update the tensor network parameters, efficiently navigating the high-dimensional parameter space. 
- Designing efficient decoders for these correlated models. 
Once the error model is learned, these models demand decoding algorithms that account for multi-qubit correlations. We can formulate the decoding problem as a constrained optimization problem maximizing error likelihoods under syndrome constraints. Mixed-integer programming (MIP), a combinatorial optimization framework, emerges as a powerful candidate. The optimization problem can be reduced to a MIP problem and solved using state-of-the-art solvers.
== Correlated quantum channels

We consider an error model where the errors are spatially correlated, often caused by the cross-talk between neighboring qubits.

#figure(canvas({
  import draw: *
  let s(it) = text(11pt, it)
  content((0, 0), quantum-circuit(
    lstick($|0〉$), 1, 1, 1, 1, [\ ],
    lstick($|0〉$), 1, $H$, ctrl(1), rstick($(|00〉+|11〉)/√2$, n: 2), [\ ],
    lstick($|0〉$), 1, 1, targ(), 1
  ))
  circle((-1.2, 0), radius: 0.1, fill: red, stroke: none, name: "E_1")
  circle((-0.1, 0.5), radius: (0.1, 0.7), fill: red, stroke: none, name: "E_2")
  circle((-0.1, -0.95), radius: 0.1, fill: red, stroke: none, name: "E_3")
  content((rel: (0, 0.3), to: "E_1"), s[$cal(E)_1$])
  content((rel: (0.3, 0), to: "E_2"), s[$cal(E)_(1 2)$])
  content((rel: (0, 0.3), to: "E_3"), s[$$])
}), 
caption: [
  The error model of spatially correlated errors. The red dots (ellipses) represent the (correlated) errors.
]) <fig:correlated-errors>

We parameterize the single-qubit error channel as
$
cal(E)_1(rho) = sum_(i=0)^3 p_(i) sigma_i rho sigma_i,
$
where $p_i$ is the probability of the error and $(sigma_i)_(i=0)^3$ are the Pauli matrices $(I, X, Y, Z)$.
Similarly, the two-qubit error channel can be written as
$
cal(E)_(1 2)(rho) = sum_(i,j=0)^3 p_(i j) (sigma_i times.circle sigma_j) rho (sigma_i times.circle sigma_j),
$
where $(p_(i j))_(i,j=0)^3$ are the error probabilities. #jinguo[Why this channel is complete?]

Hence, for a general $n$-qubit error channel, we can parameterize it with $4^n$ parameters. This parameterization is does not characterize all the possible error channels, e.g. it does not include coherent errors. A complete parameterization requires $4^n (4^n-1)$ parameters.
Here, for simplicity, we only consider the Pauli errors.

== From channels to tensor networks
In the straight-forward to convert any quantum circuit into a tensor network. For channels, we must go to the representation of superoperators. Let us denote the circuit in @fig:correlated-errors as $cal(C)$. The tensor network for representing the output probability $p(bold(s)) = tr(cal(C)(rho) |bold(s)angle.r angle.l bold(s)|)$ is shown in @fig:tensor-network.

#figure(canvas(length: 1cm, {
  import draw: *
  let dx = 0.8
  let dy = 0.8
  let DY = 3.0
  for j in (0,1,2){
    circle((0, -j * dy), radius: 0.1, name: "rho" + str(j))
    content((rel: (-0.4, 0), to: "rho" + str(j)), [$|0angle.r$])
    circle((0, -j * dy - DY), radius: 0.1, name: "rho'" + str(j))
    content((rel: (-0.4, 0), to: "rho'" + str(j)), [$angle.l 0|$])

    circle((6 * dx, -j * dy), radius: 0.1, name: "tao" + str(j))
    content((rel: (0.5, 0), to: "tao" + str(j)), [$angle.l s_#(j+1)|$])
    circle((6 * dx, -j * dy - DY), radius: 0.1, name: "tao'" + str(j))
    content((rel: (0.5, 0), to: "tao'" + str(j)), [$|s_#(j+1) angle.r$])
  }
  for j in (0,1) {
    content((dx, -j * DY - dy), box(stroke: red, inset: 3pt, [$Sigma_1$]), name: "PA" + str(j))
    content((2*dx, -j * DY - dy), box(stroke: black, inset: 3pt, [$H$]), name: "H" + str(j))
    content((3*dx, -j * DY - 0.5 * dy), align(horizon, box(stroke: red, inset: 3pt, height: dy * 1.7cm, [$Sigma_2$])), name: "PB" + str(j))
    content((4*dx, -j * DY - 2 * dy), box(stroke: red, inset: 3pt, [$Sigma_1$]), name: "PC" + str(j))
    content((5*dx, -j * DY - 2 * dy), box(stroke: black, inset: 3pt, [$xor$]), name: "xor" + str(j))
  }
  line("rho1", "PA0")
  line("PA0", "H0")
  line("rho0", (rel: (0, dy/2), to: "PB0.west"))
  line("H0", (rel: (0, -dy/2), to: "PB0.west"))
  line("rho2", "PC0")
  line("PC0", "xor0")
  line((rel: (0, dy/2), to: "PB0.east"), "tao0")
  line((rel: (0, -dy/2), to: "PB0.east"), "tao1")
  line("xor0", "tao2")
  line("xor0", (rel: (0, dy), to: "xor0"))

  line("rho'1", "PA1")
  line("PA1", "H1")
  line("rho'0", (rel: (0, dy/2), to: "PB1.west"))
  line("H1", (rel: (0, -dy/2), to: "PB1.west"))
  line("rho'2", "PC1")
  line("PC1", "xor1")
  line((rel: (0, dy/2), to: "PB1.east"), "tao'0")
  line((rel: (0, -dy/2), to: "PB1.east"), "tao'1")
  line("xor1", "tao'2")
  line("xor1", (rel: (0, dy), to: "xor1"))

  circle((rel: (-dx/2, -1.8 * dy), to: "PA0"), radius: 0.25, stroke: red, name: "pA")
  circle((rel: (-dx/2, -2.3 * dy), to: "PB0"), radius: 0.25, stroke: red, name: "pB")
  circle((rel: (-dx/2, -0.8 * dy), to: "PC0"), radius: 0.25, stroke: red, name: "pC")
  content("pA", [$p$])
  content("pB", [$p_2$])
  content("pC", [$p$])
  line("PA0", "PA1", stroke: red)
  line("PB0", "PB1", stroke: red)
  line("PC0", "PC1", stroke: red)
  line("pA", (rel: (dx/2, 0), to: "pA"), stroke: red)
  line("pB", (rel: (dx/2, 0), to: "pB"), stroke: red)
  line("pC", (rel: (dx/2, 0), to: "pC"), stroke: red)
}),
caption: [Tensor network representation of a quantum channel. The gates in the bottom are the conjugate of the gates in the top. The red circles are the trainable parameters representing the error probabilities.]
) <fig:tensor-network>

== Gradient-based optimization
In @fig:tensor-network, $p$ and $p_2$ are the trainable parameters in the tensor network. And the loss function is the negative log-likelihood of the output probability $p(bold(s))$. We can use the gradient-based optimization to train the parameters.

== Correlated Quantum Decoder
Suppose we have the error distribution $p(e)$ and the syndrome $s$ measured from the quantum circuit. The goal is to find the most likely error $e$ that causes the syndrome $s$.
This can be formulated as the following optimization problem
$
max quad &p(e)\
"s.t." quad & s(e) = s\
$ <eq:p1>
where $s(e)$ is the syndrome of the error $e$. 

Suppose the parity check matrices of a CSS quantum code are $H_x in bb(F)_2^(m_x times n)$ and $H_z in bb(F)_2^(m_z times n)$, where $m_x$ and $m_z$ are the number of $X$ and $Z$ stabilizers, respectively. And we denote the error $e = (bold(x),bold(y), bold(z))$, where $bold(x),bold(y),bold(z) in bb(F)_2^n$ are the error vectors. The $j$-th element of $bold(sigma)$ is $1$ if the $j$-th qubit is flipped by an $sigma$ error, and $0$ otherwise, for $sigma in {x,y,z}$. Here we assume that there is at most one error per qubit, i.e., $bold(x)_j + bold(y)_j + bold(z)_j <= 1$. The syndrome of $X$-stabilizers and $Z$-stabilizers are $H_x (bold(y)+bold(z)) = s_x in bb(F)_2^(m_x)$ and $H_z (bold(x)+bold(y)) = s_z in bb(F)_2^(m_z)$. Now we can rewrite the optimization problem in @eq:p1 as
$
max quad &log p(e)\
"s.t." quad & H_x (bold(y+ z)) = s_x\
& H_z (bold(x+ y)) = s_z\
& bold(x),bold(y),bold(z) in {0,1}^n\
& bold(x)_j + bold(y)_j + bold(z)_j <= 1, quad j=1,...,n\
$ <eq:p2>
If the error distributions on different qubits are independent to each other, we can wirte the log-likelihood of the total error probability as
$
L = log p(e) & = log product p_i (bold(x)_i, bold(y)_i, bold(z)_i)\
& = sum_i log p_i (bold(x)_i, bold(y)_i, bold(z)_i)\
$
== Simlation Results

== Experimental Proposal
#zy[bullet points 12345678]

// # # Mixed-Integer Programming for Decoding
// # ## Problem Statement
// # The parity-check matrices of a CSS quantum code are $H_x \in \mathbb{F}^{m_x \times n}_2$ and $H_z \in \mathbb{F}^{m_z \times n}_2$ where $\mathbb{F}_2$ is the finite field with two elements, $n$ is the number of qubits, $m_x$ is the number of $X$-stabilizers, and $m_z$ is the number of $Z$-stabilizers. We can use [`CSSTannerGraph`](@ref) to generate a tanner graph for a CSS quantum code.
// using TensorQEC
// tanner = CSSTannerGraph(SteaneCode());
// # And the parity-check matrix of $X$-stabilizers of the Steane code is
// tanner.stgx.H

// # The error vectors $\mathbf{x,y,z} \in \mathbb{F}^n_2$ are binary vectors. The $j$-th element of $\mathbf{x}$ is $1$ if the $j$-th qubit is flipped by an $X$-error, and $0$ otherwise. There is at most one error per qubit, i.e., $\mathbf{x}_j + \mathbf{y}_j + \mathbf{z}_j \leq 1$. [`random_error_qubits`](@ref) can be used to generate a random error pattern for a given number of qubits and an error model.
// using Random; Random.seed!(110)
// error_pattern = random_error_qubits(7, DepolarizingError(0.1))
// # Here we decompose $Y$ errors into $X$ and $Z$ errors. The error pattern is $Y_4X_6 =iX_4X_6Z_4$.

// # The syndrome of $X$-stabilizers and $Z$-stabilizers are $H_x(\mathbf{y}+\mathbf{z}) = s_x \in \mathbb{F}^{m_x}_2$ and $H_z (\mathbf{x}+\mathbf{y}) = s_z \in \mathbb{F}^{m_z}_2$. We can use [`syndrome_extraction`](@ref) to extract the syndrome of a given error pattern.
// syndrome = syndrome_extraction(error_pattern,tanner)
// # The goal is to find the most-likely error $\mathbf{x},\mathbf{y},\mathbf{z} \in \mathbb{F}^n_2$ given the syndrome $s_x$ and $s_z$.

// # Suppose that the error distributions on different qubits are independent to each other. And we use $p_{\sigma j}$ to denote the probability of the $j$-th qubit being flipped by an error of type $\sigma \in \{x,y,z\}$. Then the logarithm of the total error probability is 
// # ```math
// # L(\mathbf{x,y,z}) = \sum_{j=1}^n (\mathbf{x}_j \log p_{xj} + \mathbf{y}_j \log p_{yj} + \mathbf{z}_j \log p_{zj} + (1-\mathbf{x}_j-\mathbf{y}_j-\mathbf{z}_j) \log (1-p_{xj}-p_{yj}-p_{zj})).
// # ```
// # The resulting mixed-integer program can be summarized as:
// # ```math
// # \begin{aligned}
// # \text{maximize} \quad & L(\mathbf{x,y,z}) \\
// # \text{subject to} \quad & H_x (\mathbf{y+z}) = s_x, \\
// # & H_z (\mathbf{x+y}) = s_z, \\
// # & \mathbf{x,y,z} \in \{0,1\}^n, \\
// # & \mathbf{x}_j + \mathbf{y}_j + \mathbf{z}_j \leq 1, \quad j=1,\ldots,n.
// # \end{aligned}
// # ```

// # ## Mixed-Integer Programming
// # Since $H_x (\mathbf{y+z}) = s_x$ in $\mathbb{F}_2$ is equivalent to $H_x (\mathbf{y+z}) = s_x \mod 2$ in $\mathbb{Z}$, we can convert above programming problem into a mixed-integer programming problem as follows:
// # ```math
// # \begin{aligned}
// # \text{maximize} \quad & L(\mathbf{x,y,z}) \\
// # \text{subject to} \quad & H_x (\mathbf{y+z}) = s_x + 2\mathbf{k}, \\
// # & H_z (\mathbf{x+y}) = s_z + 2\mathbf{l}, \\
// # & \mathbf{x,y,z} \in \{0,1\}^n, \\
// # & \mathbf{x}_j + \mathbf{y}_j + \mathbf{z}_j \leq 1, \quad j=1,\ldots,n.\\
// # & \mathbf{k} \in \mathbb{Z}^{m_x}, \mathbf{l} \in \mathbb{Z}^{m_z}.
// # \end{aligned}
// # ```
// # Here $\mathbf{k}$ and $\mathbf{l}$ are auxiliary variables to convert the modulo operation into linear constraints.

// # We implement the above mixed-integer programming problem in [`IPDecoder`](@ref) and solve it with [JuMP.jl](https://github.com/jump-dev/JuMP.jl) and [HiGHS.jl](https://github.com/jump-dev/HiGHS.jl). We can use [`decode`](@ref) to decode the syndrome with this integer programming decoder.
// decoder = IPDecoder()
// decode(decoder, tanner, syndrome)

// # Here we get a different error pattern $X_2Z_4$. That is because the default error probability is $0.05$ for each qubit and each error type. And this error pattern has the same syndrome as the previous one. If we slightly increase the $X$ and $Y$ error probability, we can get the correct error pattern $Y_4X_6$.
// decode(decoder, tanner, syndrome, fill(DepolarizingError(0.06, 0.06, 0.05),7))