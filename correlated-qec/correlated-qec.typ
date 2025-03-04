#show link: set text(blue)
#import "@preview/cetz:0.2.2": canvas, draw, tree
#import "@preview/quill:0.6.0": *
#set math.equation(numbering: "(1)")

#align(center)[
= Quantum Error Correction with Spatially Correlated Errors
_Jinguo Liu_
]

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
    content((dx, -j * DY), box(stroke: red, inset: 3pt, [$Sigma_1$]), name: "PA" + str(j))
    content((2*dx, -j * DY), box(stroke: black, inset: 3pt, [$H$]), name: "H" + str(j))
    content((3*dx, -j * DY - 0.5 * dy), align(horizon, box(stroke: red, inset: 3pt, height: dy * 1.7cm, [$Sigma_2$])), name: "PB" + str(j))
    content((4*dx, -j * DY - 2 * dy), box(stroke: red, inset: 3pt, [$Sigma_1$]), name: "PC" + str(j))
    content((5*dx, -j * DY - 2 * dy), box(stroke: black, inset: 3pt, [$xor$]), name: "xor" + str(j))
  }
  line("rho0", "PA0")
  line("PA0", "H0")
  line("H0", (rel: (0, dy/2), to: "PB0.west"))
  line("rho1", (rel: (0, -dy/2), to: "PB0.west"))
  line("rho2", "PC0")
  line("PC0", "xor0")
  line((rel: (0, dy/2), to: "PB0.east"), "tao0")
  line((rel: (0, -dy/2), to: "PB0.east"), "tao1")
  line("xor0", "tao2")
  line("xor0", (rel: (0, dy), to: "xor0"))

  line("rho'0", "PA1")
  line("PA1", "H1")
  line("H1", (rel: (0, dy/2), to: "PB1.west"))
  line("rho'1", (rel: (0, -dy/2), to: "PB1.west"))
  line("rho'2", "PC1")
  line("PC1", "xor1")
  line((rel: (0, dy/2), to: "PB1.east"), "tao'0")
  line((rel: (0, -dy/2), to: "PB1.east"), "tao'1")
  line("xor1", "tao'2")
  line("xor1", (rel: (0, dy), to: "xor1"))

  circle((rel: (-dx/2, -2.8 * dy), to: "PA0"), radius: 0.25, stroke: red, name: "pA")
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


