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
= Monte Carlo based QEC
_Zhongyi Ni_, _Jinguo Liu_
]

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
== Simple Markov Chain Monte Carlo
#figure(canvas({
  import draw: *
  surface_code((0, 0), 5, 5,color1: aqua,color2:yellow)
  surface_code_label((7,3))
  circle((1.5, 0.5), radius: 0.1, fill: red, stroke: none)
  circle((3.5, 2.5), radius: 0.1, fill: red, stroke: none)
}), caption: [Surface code with code distance 5. The red dots are the error syndrome.]) <fig:lattice-surgery>

Let $cal(S) = {s_1, s_2, dots, s_m}$ be the set of stabilizers, $cal(Q) = {q_1, q_2, dots, q_n}$ be the set of logical $X$ and $Z$ operators for qubits.
1. Create a random error configuration $sigma$ that associates the error syndrome to logic state $0$.
2. Update the error configuration $sigma$ by applying one of the following update rules on it:
   - $R_1$: applying a stabilizer $s_i in cal(S)$ to the qubits. It does not change the logic state or syndrome.
   - $R_2$: flipping a logical qubit $q_j in cal(Q)$. It changes the logic state, without changing the syndrome.

  Let us denote the updated error configuration by $sigma'$. The acceptance probability of the update is given by
  $
    min ( 1, e^(-E(sigma') + E(sigma)))
  $
  where $E(sigma)$ is the "energy" of the error configuration $sigma$ given by the error model. The energy is defined as the log of the probability of the error configuration $sigma$ given by the error model.
3. $p_0\/p_1$ could be estimated by the ratio of the number of logical state 0 and 1 in the simulation.

== Parallel Tempering for free energy estimation

The problem of the simple Markov Chain Monte Carlo is that the acceptance ratio is very low, because the logical state 0 and 1 are highly nonlocal. Changing the logical state from 0 to 1 is very unlikely.

We adopt the free energy estimator proposed in @Lyubartsev1992, which is based on multiple replicas of the system at different temperatures.

We modifty ensemble with the partition function,
$
  sum_(m=1)^M Z= Z_m e^(eta_m)
$
where $Z_m$ is the partition function of the system at temperature $beta_m$, and $eta_m$ is a parameter to be determined.

#figure(canvas({
  import draw: *
  line((0, 0), (0, 5), stroke: black, mark: (end: "straight"))
  content((-0.8, 0), [$beta_L = 1$])
  content((-1.0, 5), [$beta_H arrow 1/T_H$])
  circle((1.5, 0.5), radius: 0.3, fill: none, stroke: black, name: "low")
  circle((1.5, 4.5), radius: 0.3, fill: none, stroke: black, name: "high")
  bezier("high.east", "high.north", (rel: (1, 0.5), to: "high"), (rel: (0.5, 1), to: "high"), mark: (end: "straight"))
  content((3.5, 5), [Regular update])
  bezier("low.east", "low.south", (rel: (1, -0.5), to: "low"), (rel: (0.5, -1), to: "low"), mark: (end: "straight"))
  content((3.5, 1), [Regular update])
  line("low", "high", mark: (end: "straight", start: "straight"))
  content((2.5, 2.5), [$beta_L arrow.l.r beta_H$])
}), caption: [Two types of updates (regular and $beta$-swap) in parallel tempering scheme for free energy estimation.]) <fig:lattice-surgery>

The $beta$-swap update rule is defined as
- $R_3$: $(sigma, beta) arrow (sigma, beta')$ with probability
  $
    min ( 1, e^(-(beta' - beta) E(sigma) + (eta' - eta)))
  $
  where $E(sigma)$ is the energy of the error configuration $sigma$ and $eta$ is the inverse temperature.

The $p_0\/p_1$ could be estimated by the ratio of the number of logical state 0 and 1 in the simulation when $beta = beta_L$.

=== Decide $eta_m$ (for temperature $beta_m$) with the free energy

In the course of the MC procedure we calculate (for each "$m$") $n_m$-the numbers of MC steps for which the
temperature holds equal to $1\/beta_m$ As a result the estimation of the probability for the state with this temperature is obtained: $p_m ~ n_m\/n$ ($n$-total length of the MC chain).
We have
$ p_m = Z_m e^(eta^m)\/Z $
and hence
$
p_m/(p_k) =  Z_m/Z_k e^(eta_m -eta_k)  = e^(- beta_m F_m + beta_k F_k + eta_m - eta_k)
$ <eq:free-energy-relation>
Thus we can obtain difference of free energies for any arbitrary pair of temperatures.
The case $beta = 0$ corresponds to the ideal gas (since the interaction is switched off) and the partition function is known exactly (the case ofthe hard core will be discussed later).


A good choice of $eta_m$ should allow free transition between different temperatures, which is satisfied by $eta_m$ = $beta_m F_m$.
It can be determined by running a few MC steps and estimate $F_m$ with @eq:free-energy-relation.

== An empirical parameter setup

- The proposal rate of update rules:
  - $R_1$: $0.9|cal(S)|\/(|cal(S)|+|cal(Q)|)$
  - $R_2$: $0.9|cal(Q)|\/(|cal(S)|+|cal(Q)|)$
  - $R_3$: $0.1$
- The number of replicas:
  - $N_beta = 2$, $(beta_1, eta_1) = (1, 0)$, $(beta_2, eta_2) = (0.1, 3.0)$
- The number of sweeps:
  - $N = 10000$

#bibliography("refs.bib")