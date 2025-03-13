#show link: set text(blue)
#import "@preview/cetz:0.2.2": canvas, draw, tree
#import "@preview/quill:0.6.0": *
#set math.equation(numbering: "(1)")

#set heading(numbering: "1.")

#let zy(it) = {
  text(orange, [[ZY: #it]])
}

#let jinguo(it) = {
  text(red, [[JG: #it]])
}

#align(center)[
= Quantum Error Correction with Spatially Correlated Errors
_Zhongyi Ni_, _Jinguo Liu_
]

== Introduction
Traditional QEC schemes, such as the surface code and stabilizer formalism, predominantly assume independent error models, where qubit errors occur uncorrelated in space and time. These models underpin the theoretical promise of thresholds and code distances, ensuring protection against a fixed number of errors@gottesman1997stabilizer. However, real-world quantum hardware—including superconducting circuits@gambetta2012characterization, trapped ions@ballance2016high, and photonic systems@kok2007linear—exhibits correlated errors that defy these assumptions. Examples include crosstalk between adjacent qubits during simultaneous gate operations@krinner2019engineering, spatially correlated noise in lattices@grondalski1999spatial, and joint errors following entangling gates like CNOT@erhard2019characterizing. Such correlations degrade the performance of conventional decoders, which are ill-equipped to handle complex error syndromes arising from these dependencies.  

We propose two key innovations to address this challenge:
- Learning device-specific error models from experimental data 
Tensor network methods provide a powerful framework for modeling correlated error channels in quantum circuits by leveraging their ability to efficiently represent high-dimensional quantum processes with structured correlations@torlai2023quantum. To train the model, the loss function is defined as the negative log-likelihood of the experimental data. Automatic differentiation@peterUnderPeterOMEinsumjl2025 and gradient descent@FluxMLOptimisersjl2025 are then employed to iteratively update the tensor network parameters, efficiently navigating the high-dimensional parameter space. 
- Designing efficient decoders for these correlated models. 
Once the error model is learned, these models demand decoding algorithms that account for multi-qubit correlations. We can formulate the decoding problem as a constrained optimization problem maximizing error likelihoods under syndrome constraints. Mixed-integer programming (MIP), a combinatorial optimization framework, emerges as a powerful candidate. The optimization problem can be reduced to a MIP problem@landahl2011fault@cain2024correlated and solved using state-of-the-art solvers.
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
where $(p_(i j))_(i,j=0)^3$ are the error probabilities. 

*Remark.* Why this channel?
- It is directly related to the physical error distribution in the quantum hardware.
- Any quantum channel can be converted into a sum of Pauli errors with pauli twirling@hashim2020randomized.
- Error model related deocder is hard to design for more general channels.

Hence, for a general $n$-qubit error channel, we can parameterize it with $4^n$ parameters. This parameterization is does not characterize all the possible error channels, e.g. it does not include coherent errors. A complete parameterization requires $4^n (4^n-1)$ parameters.
Here, for simplicity, we only consider the Pauli errors.

== From channels to tensor networks
In the straight-forward to convert any quantum circuit into a tensor network. For channels, we must go to the representation of superoperators. Let us denote the circuit in @fig:correlated-errors as $cal(C)$. The tensor network for representing the output probability $p(psi) = tr(cal(C)(rho) |psi angle.r angle.l psi|)$ is shown in @fig:tensor-network.

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
    content((rel: (0.5, 0), to: "tao" + str(j)), [$angle.l psi_#(j+1)|$])
    circle((6 * dx, -j * dy - DY), radius: 0.1, name: "tao'" + str(j))
    content((rel: (0.5, 0), to: "tao'" + str(j)), [$|psi_#(j+1) angle.r$])
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



== Informationally complete measurements
How many measurements and what kind of measurements are needed to estimate the state of a quantum system? Suppose we have a depolaring channel $cal(E)_bold(p)$ parameterized by a vector $bold(p)$. The input state and the measurement state are $rho_"in"$ and $rho_"out"$, respectively. The output probability is 
$
p = tr(cal(E)_bold(p)(rho_"in") rho_"out")
$ 
We have the following tensor network representation of this channel.
#figure(canvas({
  import draw: *
  circle((0, 0), radius: 0.5, name: "rhoin")
  content("rhoin", [$rho_"in"$])
  circle((4,0),radius: 0.5, name: "rhoout")
  content("rhoout", [$rho_"out"$])
  content((2,0), box(stroke: black, inset: 12pt, [$A$]), name: "PA" )
  circle((2,1.5),radius: 0.5, name: "p",stroke:red)
  content("p", [$bold(p)$])
  line("rhoin", "PA")
  line("PA", "rhoout")
  line("p", "PA", stroke: red)
})) 
For different input and measurement states, we have linear constants on $bold(p)$. As long as we have enough linearly independent measurements, we can determine the value of $bold(p)$. The number of linearly independent measurements is the number of parameters in $bold(p)$.
For systems that can be measured in more than two basis, we can use the following circuit to estimate $bold(p)$.
#figure(canvas({
  import draw: *
  let s(it) = text(11pt, it)
  content((0, 0), quantum-circuit(
    lstick($|0〉$),  $U$,2,meter()
  ))
  circle((0.45, 0), radius: 0.1, fill: red, stroke: none, name: "E_1")
  content((rel: (0, 0.3), to: "E_1"), s[$cal(E)_1$])
})) 
Here random unitaries can generate different input states. We perform the input and measurement under 3 different basis. We will have 3 linearly independent measurements to estimate $bold(p)$.

However, for systems that can only be measured under $|0 angle.r$ and $|1 angle.r$, we need to apply another unitary before the measurement. But this unitary will introduce error into the system, too. The circuit is as follows
#figure(canvas({
  import draw: *
  let s(it) = text(11pt, it)
  content((0, 0), quantum-circuit(
    lstick($|0〉$),  $U_1$,2,$U_2$,2,meter()
  ))
  circle((1.45, 0), radius: 0.1, fill: red, stroke: none, name: "E_1")
  circle((-0.45, 0), radius: 0.1, fill: red, stroke: none, name: "E_12")
  content((rel: (0, 0.3), to: "E_1"), s[$cal(E)_1$])
  content((rel: (0, 0.3), to: "E_12"), s[$cal(E)_1$])
})) 
The tensor network representation of this circuit is
#figure(canvas({
  import draw: *
  circle((0, 0), radius: 0.7, name: "rhoin")
  content("rhoin", [$|0 angle.r angle.l 0|$])
  circle((10,0),radius: 0.7, name: "rhoout")
  content("rhoout", [$|0 angle.r angle.l 0|$])
  line((10.5,-1), (11.5,1), stroke: black)
    circle((12,0),radius: 0.7, name: "rhoout2")
  content("rhoout2", [$|1 angle.r angle.l 1|$])
  content((2,0), box(stroke: black, inset: 12pt, [$U_1$]), name: "U1" )
  content((4,0), box(stroke: black, inset: 12pt, [$cal(E)_1$]), name: "E1" )
  content((6,0), box(stroke: black, inset: 12pt, [$U_2$]), name: "U2" )
  content((8,0), box(stroke: black, inset: 12pt, [$cal(E)_2$]), name: "E2" )
  circle((6,2),radius: 0.5, name: "p",stroke:red)
  content("p", [$bold(p)$])
  line("rhoin", "U1")
  line("U1", "E1")
  line("E1", "U2")
  line("U2", "E2")
  line("E2", "rhoout")
  line("E1", (rel: (0, 1), to: "E1"),(rel: (0, 1), to: "E2"),"E2", stroke: red,name: "line1")
  line("p", "line1.mid", stroke: red)
})) 
== Gradient-based optimization
In @fig:tensor-network, $p$ and $p_2$ are the trainable parameters in the tensor network. We denote them as $theta$ and the channel parameterize by them as $cal(C)_theta$. Suppose we perform this circuit $N$ times and each time we get a measurement result $|psi_i angle.r$. The data set is $psi = {|psi_1 angle.r, |psi_2 angle.r, ..., |psi_N angle.r}$. Wwe are trying to minimize the negative log-likelihood of the output probabilities $p(psi_i)$ with respect to the parameters $theta$.
$ 
  min_theta L(psi; theta) = min_theta -sum_i log p(psi_i) = min_theta -sum_i log tr(cal(C)_theta (rho) |psi_i angle.r angle.l psi_i|)
$
We can use the gradient-based optimization to train the parameters. The gradient of the loss function with respect to the parameters is achieved by automatic differentiation of tensor networks.

== Correlated Quantum Decoder <sec:co_decoder>
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
"s.t." quad & H_x (bold(y+ z)) = s_x + 2 bold(k)\
& H_z (bold(x+ y)) = s_z + 2bold(l)\
& bold(x)_j + bold(y)_j + bold(z)_j <= 1, quad j=1,...,n\
& bold(x),bold(y),bold(z) in {0,1}^n\
& bold(k) in bb(Z)^(m_x), bold(l) in bb(Z)^(m_z)\
$ <eq:p2>
where $bold(k)$ and $bold(l)$ are auxiliary variables to convert the modulo operation into linear constraints.

If the error distributions on different qubits are independent to each other, we can wirte the log-likelihood of the total error probability as
$
L = log p(e) & = log product p_i (bold(x)_i, bold(y)_i, bold(z)_i)\
& = sum_i log p_i (bold(x)_i, bold(y)_i, bold(z)_i)\
& = sum_i (bold(x)_i log p_(x i) + bold(y)_i log p_(y i) + bold(z)_i log p_(z i) + (1-bold(x)_i-bold(y)_i-bold(z)_i) log (1-p_(x i)-p_(y i)-p_(z i)))\ 
$
with $p_(sigma i)$ denoting the probability of the $i$-th qubit being flipped by an error of type $sigma in {x,y,z}$. Now the objective function in @eq:p2 becomes a linear function of the error vectors $bold(x),bold(y),bold(z)$ with real coefficients. And the constraints are linear as well. This is a mixed-integer programming problem, which can be solved with state-of-the-art solvers.

If the error distributions on different qubits are not independent, suppose that the error distribution of qubit $1$ and $2$ is a joint distribution $p_(1 2)$. Then we use 16 variables $v_(sigma tau) in {0,1}, sigma, tau in {X,Y,Z,I}$ to represent the joint error distribution. This term in log-likelihood of the total error probability becomes
$
  log p_(1 2) = sum_( sigma, tau in {X,Y,Z,I}) v_(sigma tau) log p_(sigma tau)
$
with the following constraint to ensure that there is excatly one of them is true
$
  sum_(sigma, tau in {X,Y,Z,I}) v_(sigma tau) = 1
$

For joint probability distributions on more qubits, the number of variables of this same technique will increase exponentially. Here we only foucs on the two-qubit case.

== Simlation Results
#figure(canvas({
  import draw: *
  let s(it) = text(11pt, it)
  content((0, 0), quantum-circuit(
    lstick($|0〉$),  $U$,2,meter()
  ))
    content((5, 0), quantum-circuit(
    lstick($|0〉$), mqgate($U$, n:2),1,1,meter(),[\ ],
    lstick($|0〉$),3,meter(),
  ))
  circle((0.45, 0), radius: 0.1, fill: red, stroke: none, name: "E_1")
  circle((5.4, 0), radius: (0.1, 0.7), fill: red, stroke: none, name: "E_2")
  content((rel: (0, 0.3), to: "E_1"), s[$cal(E)_1$])
  content((rel: (0.3, 0), to: "E_2"), s[$cal(E)_(1 2)$])
}), 
caption: [
  #zy[Caption]
]) 

#figure(canvas({
  import draw: *
  let s(it) = text(11pt, it)
  content((0, 0), quantum-circuit(
    lstick($|0〉$),  $U_1$,2,$U_2$,2,meter()
  ))
    content((7, 0), quantum-circuit(
    lstick($|0〉$), mqgate($U_1$, n:2),2, mqgate($U_2$, n:2),2,meter(),[\ ],
    lstick($|0〉$),6,meter(),
  ))
  circle((1.45, 0), radius: 0.1, fill: red, stroke: none, name: "E_1")
  circle((-0.45, 0), radius: 0.1, fill: red, stroke: none, name: "E_12")
  circle((6.5, 0), radius: (0.1, 0.7), fill: red, stroke: none, name: "E_2")
  circle((8.5, 0), radius: (0.1, 0.7), fill: red, stroke: none, name: "E_22")
  content((rel: (0, 0.3), to: "E_1"), s[$cal(E)_1$])
  content((rel: (0, 0.3), to: "E_12"), s[$cal(E)_1$])
  content((rel: (0.3, 0), to: "E_2"), s[$cal(E)_(1 2)$])
    content((rel: (0.3, 0), to: "E_22"), s[$cal(E)_(1 2)$])
}), 
caption: [
  #zy[Caption]
]) 
Here we consider two surface codes with code distance $d$. The CNOT gate between them can be achieved by lattice surgery, which consists of CNOT gates on the boundary qubits. @fig:lattice-surgery shows an example for $d = 5$ surface code.
#let surface_code(loc, m, n, size:1, color1:yellow, color2:aqua,number_tag:false,type_tag:true) = {
  import draw: *
  for i in range(m){
    for j in range(n){
      let x = loc.at(0) + i * size
      let y = loc.at(1) + j * size
      if (i != m - 1) and (j != n - 1){
        if (calc.rem(i + j, 2) == 0){
          if type_tag{
           if (i == 0){
            bezier((x, y), (x, y + size), (x - size * 0.7, y + size/2), fill: color2, stroke: black)
          }
          if (i == m - 2){
            bezier((x + size, y), (x + size, y + size), (x + size * 1.7, y + size/2), fill: color2, stroke: black)
          }
          }else{
                      if (j == 0){
            bezier((x, y), (x + size, y), (x + size/2, y - size * 0.7), fill: color2, stroke: black)
          }
          if (j == n - 2){
            bezier((x, y + size), (x + size, y + size), (x + size/2, y + size * 1.7), fill: color2, stroke: black)
          }
          }
          rect((x, y), (x + size, y + size), fill: color1, stroke: black)
        } else {
                if type_tag{
          if (j == 0){
            bezier((x, y), (x + size, y), (x + size/2, y - size * 0.7), fill: color1, stroke: black)
          }
          if (j == n - 2){
            bezier((x, y + size), (x + size, y + size), (x + size/2, y + size * 1.7), fill: color1, stroke: black)
          }
            }else{
               if (i == 0){
            bezier((x, y), (x, y + size), (x - size * 0.7, y + size/2), fill: color1, stroke: black)
          }
          if (i == m - 2){
            bezier((x + size, y), (x + size, y + size), (x + size * 1.7, y + size/2), fill: color1, stroke: black)
          }
            }
          rect((x, y), (x + size, y + size), fill: color2, stroke: black)
        }
      }
      circle((x, y), radius: 0.08 * size, fill: black, stroke: none)
      if number_tag{
      content((x + 0.2*size, y - 0.2*size), [#(i+(n - j - 1)*m+1)])
    }
    }
  }
}
#let surface_code_label(loc,size:1,color1:yellow, color2:aqua) = {
  import draw: *
  let x = loc.at(0)
  let y = loc.at(1)
  content((x, y), box(stroke: black, inset: 10pt, [$X$ stabilizers],fill: color2, radius: 4pt))
  content((x, y - 1.5*size), box(stroke: black, inset: 10pt, [$Z$ stabilizers],fill: color1, radius: 4pt))
}
#figure(canvas({
  import draw: *
  surface_code((0, 0), 5, 5,color1: aqua,color2:yellow)
  surface_code((5, 0), 5, 5,color1: aqua,color2:yellow)
  surface_code_label((12,3))
  for i in range(5){
    circle((4, i), radius: 0.1, fill: red, stroke: none, name: "control" + str(i))
    circle((5, i), radius: 0.2, fill: none , stroke: red, name: "not" + str(i))
    line("control" + str(i), "not" + str(i), stroke: red)
    line((5-0.2, i), (5+0.2, i), stroke: red)
    line((5, i - 0.2), (5, i + 0.2), stroke: red)
  }
}),caption: [
  CNOT gate between two surface codes with code distance $d = 5$.
]) <fig:lattice-surgery>
We assume the error model for the CNOT-operated qubit pairs is highly correlated: with probability $1-p$ and with error probability $p/3$ the error manifests as $X_1X_2$, $Y_1Y_2$, or $Z_1Z_2$. The error channel can be written as
$
cal(E)_(1 2)(rho) = (1-p) rho + p/3 X_1X_2 rho X_2X_1 + p/3 Y_1Y_2 rho Y_2Y_1 + p/3 Z_1Z_2 rho Z_2Z_1
$
For the qubits that are not acted by the CNOT gates, we assume that the error models of them are independent and the error probability is slightly lower than the qubit pairs that are acted by the CNOT gates. The error channel can be written as
$
cal(E)_1(rho) = (1-(3p)/5) rho + p/5 X rho X + p/5 Y rho Y + p/5 Z rho Z
$
We test this error model for two mixed-integer programming decoders: a conventional one with independent error models and a correlated one described in @sec:co_decoder. The results are shown in @fig:correlated. 

#figure(image("images/correlated.svg", width: 70%),caption: [
  Comparison of the conventional and correlated decoders for different code distance surface code. The x-axis is the physical error probability $p$ and the y-axis is the logical error rate. The solid line is the conventional decoder and the dashed line is the correlated decoder. 
]) <fig:correlated>
== Experimental Proposal
#zy[bullet points 12345678]

== questions 
- same p in different palce and time
- p only depends on the operation
- charactorise  error in calibration routine
- atom loss

#bibliography("refs.bib")

// clear page
#pagebreak()
== Appendix.A Surface code drawer
#figure(canvas({
  import draw: *
  surface_code((10, 0),size:0.5, 15, 7)
}))
#figure(canvas({
  import draw: *
  surface_code((0, 0), 5, 7)
}))
#figure(canvas({
  import draw: *
  surface_code((0, 0), 5, 5,color1: green,color2:red)
    surface_code((5, 0), 5, 5,number_tag: true)
}))
#figure(canvas({
  import draw: *
  surface_code((0, 0), 5, 5)
    surface_code((5, 0), 5, 5,type_tag: false)
}))

== Appendix.B General Informationally complete measurements@d2004informationally
Informationally complete measurements on a quantum system are those that allow us to estimate the state of the system with the measurement outcomes. Generally, a positive operator-valued measure (POVM) of Hillbert space $cal(H)$ is defined by a set of positive operators ${M_i}_(i=1)^n$ that satisfy the completeness relation $sum_i M_i = I$. The expectation value of any operator $A$ of state $rho$ is
$
angle.l A angle.r = tr(rho A).
$
Since the POVM is complete, we can write the expectation value of $A$ as the sum of the expectation values of $M_i$ 
$
angle.l A angle.r = sum_i f_i (A) tr(rho M_i),
$ <eq:expec>
where $f_i (A)$ are functions of $A$. @eq:expec holds for any operator $A$ and any state $rho$, therefore,
$
A = sum_i f_i (A) M_i.
$
This means that the set of POVM elements ${M_i}_(i=1)^n$ is spans the operator space of $cal(H)$.