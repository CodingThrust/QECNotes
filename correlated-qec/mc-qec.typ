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
#figure(canvas(length: 0.9cm, {
  import draw: *
  surface_code((0, 0), 5, 5,color1: aqua,color2:yellow)
  surface_code_label((7,3))
  rect((1, 1), (2, 2), stroke:(paint: red.darken(30%), thickness: 2pt))
  content((1.5, 1.5), text(14pt, red)[$R_1$])
  line((0, 4), (4, 0), stroke:(paint: blue.darken(30%), thickness: 2pt))
  content((1.7, 2.7), text(14pt, blue)[$R_2$])
  circle((1.5, 0.5), radius: 0.1, fill: red, stroke: none)
  circle((3.5, 2.5), radius: 0.1, fill: red, stroke: none)
}), caption: [Surface code with code distance 5. The red dots are the error syndrome.
The red lines are the update rules that does not change the logic state, while the blue lines are the update rules that changes the logic state.
]) <fig:lattice-surgery>

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

== The $beta$-swap update

The problem of the simple Markov Chain Monte Carlo is that the acceptance ratio is very low, because the logical state 0 and 1 are highly nonlocal. Changing the logical state from 0 to 1 is very unlikely.
We adopt the free energy estimator proposed in @Lyubartsev1992, which is based on evolving the system at different temperatures.
In this scheme, we modifty the ensemble with the partition function,
$
  sum_(m=1)^M Z= Z_m e^(eta_m)
$
where $Z_m$ is the partition function of the system at temperature $beta_m$, and $eta_m$ is a parameter to be determined.

#figure(canvas({
  import draw: *
  content((0.2, 0.5), [$beta_L = 1$])
  content((0.0, 4.5), [$beta_H = 0.1$])
  for (dx, state) in ((0, "0"), (3, "1")){
    let lname = "low" + state
    let hname = "high" + state
    circle((1.5 + dx, 0.5), radius: 0.3, fill: none, stroke: black, name: lname)
    circle((1.5 + dx, 4.5), radius: 0.3, fill: none, stroke: black, name: hname)
    bezier(hname + ".east", hname + ".north", (rel: (1, 0.5), to: hname), (rel: (0.5, 1), to: hname), mark: (end: "straight"))
    bezier(lname + ".east", lname + ".south", (rel: (1, -0.5), to: lname), (rel: (0.5, -1), to: lname), mark: (end: "straight"))
    line(lname, hname, mark: (end: "straight", start: "straight"))
  }
  content((5.5, 5), [$R_1$])
  content((5.5, 0), [$R_1$])
  line("low0", "low1", mark: (end: "straight", start: "straight"), stroke: (dash: "dashed"), name: "ll")
  line("high0", "high1", mark: (end: "straight", start: "straight"), name: "lh")
  content((rel: (0, 0.3), to:"ll.mid"), [small rate])
  content((rel: (0, -0.3), to:"lh.mid"), [$R_2$])
  content((5.5, 2.5), [$beta_L arrow.l.r beta_H$])
}), caption: [Three types of updates in scheme of free energy estimation.
$R_1$ is the transition inside the same logic sector, $R_2$ is the transition between different logic sectors, and $R_3$ is the $beta$-swap update that changes the temperature of the system.
The $beta_L$ and $beta_H$ are the inverse temperatures of the low and high temperature, respectively.
]) <fig:lattice-surgery>

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
The case $beta = 0$ corresponds to the ideal gas (since the interaction is switched off) and the partition function is known exactly.
A good choice of $eta_m$ should allow free transition between different temperatures, which is satisfied by
$ eta_m = beta_m F_m, $ <eq:eta-m>
which can be determined by running a few MC steps and estimate $F_m$ with @eq:free-energy-relation.

== An empirical parameter setup

- The proposal rate of update rules:
  - $R_1$: $0.9|cal(S)|\/(|cal(S)|+|cal(Q)|)$
  - $R_2$: $0.9|cal(Q)|\/(|cal(S)|+|cal(Q)|)$
  - $R_3$: $0.1$
- The number of temperature levels:
  - $N_beta = 2$, $beta_1 = 1$, $beta_2 = 0.1$, $eta$ is set automatically with @eq:eta-m
- The number of sweeps:
  - $N = 10000$

#bibliography("refs.bib")