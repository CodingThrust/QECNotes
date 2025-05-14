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

== Simulated Annealing Decoding
Here we introduce the basic setting of simulated annealing decoding@takeuchi2023comparative. Let $cal(S) = {s_1, s_2, dots, s_m}$ be the set of stabilizers, $cal(Q) = {q_1, q_2, dots, q_n}$ be the set of logical $X$ and $Z$ operators. The simulated annealing decoding is described as follows:
1. Create an error configuration $sigma_0$ that associates the error syndrome by guassian eliminations.
2. For each temperature $T$, update the error configuration $sigma$ by applying one of the following update rules on it:
   - $R_1$: applying a stabilizer $s_i in cal(S)$ to the qubits. It does not change the logic state or syndrome.
   - $R_2$: flipping a logical qubit $q_j in cal(Q)$. It changes the logic state, without changing the syndrome.

  Let us denote the updated error configuration by $sigma'$. The acceptance probability of the update is given by
  $
    min ( 1, e^(-E(sigma') + E(sigma)))
  $
  where $E(sigma)$ is the "energy" of the error configuration $sigma$ given by the error model. The energy is defined as the log of the probability of the error configuration $sigma$. When dealing with different error models, we only needs to adjust the energy function. For example, we assume that the error model is a depolarizing noise model, $p_(x i)$ is the probablity that there is an $X$ error on the $i$-th qubit, $p_(y i)$ is the probablity that there is a $Y$ error on the $i$-th qubit, and $p_(z i)$ is the probablity that there is a $Z$ error on the $i$-th qubit. The energy is the log of the probability of the error configuration $sigma = (sigma_x, sigma_z)$.
  $
    E(sigma)  & = - log p(sigma) \ 
    & = - sum_i (1 - sigma_(x i))(1 - sigma_(z i))log (1 - p_(x i) - p_(y i) - p_(z i)) - sum_i  sigma_(x i)(1 - sigma_(z i))log (p_(x i)) \   
    & - sum_i sigma_(x i)sigma_(z i) log (p_(y i)) - sum_i (1 - sigma_(x i))sigma_(z i) log (p_(z i))
  $

  For a general error model, 
  $
  p(sigma) = product_alpha p_(alpha)(sigma_I_alpha)
  $
  where $I_alpha$ is the set of bits that are acted by the $alpha$-th term. The energy term becomes
  $
    E(sigma) = - sum_(alpha) log p_(alpha)(sigma_I_alpha)
  $
3. The probability of each logic sector is estimated by the ratio of the number of copies in each logic sector at temperature $T = 1$.

#figure(canvas(length: 0.9cm, {
  import draw: *
  surface_code((0, 0), 5, 5,color1: silver,color2:white)
  surface_code_label((7,3),color1: white,color2:silver)
  rect((1, 4), (2, 3), stroke:(paint: red, thickness: 2pt))
  content((1.5, 3.5), text(14pt, red)[$R_1$])
  line((4, 4), (4, 0), stroke:(paint: green, thickness: 2pt))

  line((1,1),(1, 2), (3, 2), stroke:(paint: purple, thickness: 2pt))
  content((1.5, 1.5), text(14pt, purple)[$sigma_1$])

  circle((2,0), radius: 0.1, fill: aqua, stroke: none, name: "q2")
  line((3, 3), (3, 4), stroke:(paint: aqua, thickness: 2pt))
  content((3.5, 3.5), text(14pt, aqua)[$sigma_2$])
  content((2.3, -0.3), text(14pt, aqua)[$sigma_2$])

  content((4.7, 2.2), text(14pt, green)[$R_2$])
  circle((1.5, 0.5), radius: 0.1, fill: red, stroke: none)
  circle((3.5, 2.5), radius: 0.1, fill: red, stroke: none)
}), caption: [Surface code with code distance 5. The red dots are the error syndrome. The purple and blue paths are two possible error configurations $sigma_1$ and $sigma_2$. They correspond to different logic state sectors.
The red square is the update rule that does not change the logic state, while the green line is the update rule that changes the logic state.
]) <fig:lattice-surgery2>

Another way to understand this simulated annealing progress is to denote whether applying a logical operator or a stabilizer as a spin. $S_j = -1$ denote we apply a the $j$-th operator, and $S_j = 1$ denote we do not apply it. 

=== Simulation results
We test the simulated annealing decoder for a distance $d = 3$ surface code. As shown in @fig:sa-decoder (a), there is a single $Z$ error happened on one of the physical qubits. We suppose the error model is a simple depolarizing noise model.
$
cal(E)_1(rho) = 0.7 rho + 0.1 X rho X + 0.1 Y rho Y + 0.1 Z rho Z
$
We can use tensor works to calculate the exact likelihood probability for different logical sectors. As shown in @fig:sa-decoder (b), these likelihoods can be well approximated by simulated annealing.
#figure(canvas({
  import draw: *
  content((7.5,0.8), image("images/saplot.svg", width:340pt))
  surface_code((-2.5, 1), 3, 3,size: 1.6,color1: aqua,color2:yellow)
  surface_code_label((-1,-0.5))

  circle((0.7, 4.2), radius: 0.2, fill: white, stroke: red,name:"q3")
  content("q3", text(red)[$Z$])

  // circle((calc.sqrt(3)*1.5, - 1.5), radius: 0.2, fill: red, stroke: none)
  // circle((-calc.sqrt(3)*1.5, - 1.5), radius: 0.2, fill: red, stroke: none)
  content((-3,5),[(a)])
  content((2,5),[(b)])
  }
  ),caption: [
  (a) A physical $Z$ error happened on one of the physical qubits. (b) Simulated annealing progress. The x-axis is the inverse temperature $beta$ going from $0$ to $1$ and the y-axis is the sample frequency of four different logical sectors. At the beginning, the temperature is high and the system equilibrates to all four logical sectors after a short time of thermalization. As the temperature decreases, the sample frequency of the logical sectors converge to the exact likelihood probability. Here the step number of $beta$ and the sample number are both $10000$.
])<fig:sa-decoder>

The problem of the simple Markov Chain Monte Carlo is that the acceptance ratio is very low, because the logical states are highly nonlocal. Changing the logical state from one to another is very unlikely.

== Paper Review
1. Statistical mechanical models for quantum codes with correlated noise@chubb2021statistical
- "Complementing this, we show that the mapping also allows us to utilise any algorithm which can calculate/approximate partition functions of classical  statistical mechanical models to perform optimal/approximately optimal decoding."
- Error correction threshold $arrow.l.r$ Phase transition.
- Phase diagram. Nishimori condition.
2. Comparative study of decoding the surface code using simulated annealing under depolarizing noise@takeuchi2023comparative
- Restrict to Ising model. Map many-body term to two-body term with qubo.
- Compare between soft and hard constraints of sa decoder.
- Only surface code, code capacity noise.
- CPLEX for MIP, OpenJij for SA. Sa is slightly slower than MIP. Error rate is higher than MIP.
- ML? MP?
- Simple algorithm to find a error pattern satisfies the constraint for surface code.
- iid error model. Minimize the number of errors. 

3. Ising model formulation for highly accurate topological color codes decoding@takada2024ising
- $d = 3,5,7,11$ color code. Bit-flip, depolarizing and phenomenological noise. Code capacity noise.
- Similar setting as@takeuchi2023comparative.
- Comparing with MIP, SA is faster and has a similar error rate.

4. Near-optimal decoding algorithm for color codes using Population Annealing@martinez2024near
- Population annealing.
- Color code with $d$ up to 19. Bit-flip, depolarizing and phenomenological noise. Code capacity noise.
- No comparison with other decoder?

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
  let dy = 4
  content((0.2, 0.5), [$beta_L = 1$])
  content((0.0, dy - 0.5), [$beta_H = 0.5$])
  for (dx, state) in ((0, "0"), (3, "1")){
    let lname = "low" + state
    let hname = "high" + state
    circle((1.5 + dx, 0.5), radius: 0.3, fill: none, stroke: black, name: lname)
    circle((1.5 + dx, dy - 0.5), radius: 0.3, fill: none, stroke: black, name: hname)
    bezier(hname + ".east", hname + ".south", (rel: (1, -0.5), to: hname), (rel: (0.5, -1), to: hname), mark: (end: "straight"))
    bezier(lname + ".east", lname + ".south", (rel: (1, -0.5), to: lname), (rel: (0.5, -1), to: lname), mark: (end: "straight"))
    line(lname, hname, mark: (end: "straight", start: "straight"))
    line(hname, (rel: (0, 1.5), to: hname), stroke: (dash: "dashed"))
    content((dx + 1.5, -0.5), [Logic state: #state])
  }
  content((5.5, dy - 1), [$R_1$])
  content((5.5, 0), [$R_1$])
  line("low0", "low1", mark: (end: "straight", start: "straight"), stroke: (dash: "dashed"), name: "ll")
  line("high0", "high1", mark: (end: "straight", start: "straight"), name: "lh")
  content((rel: (0, 0.3), to:"ll.mid"), [small rate])
  content((rel: (0, -0.3), to:"lh.mid"), [$R_2$])
  content((6, dy/2), [$R_3: beta_L arrow.l.r beta_H$])
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
$ p_m = Z_m e^(eta_m)\/Z $
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
  - $N_beta = 2$, $beta = 1, 0.5, 0$, and $eta$ is set automatically with @eq:eta-m
- The number of sweeps:
  - $N = 10000$

== Free energy machine@shen2025free
In qubit configuration, the energy function can be written as
  $
    E(sigma) = - sum_(alpha) log p_(alpha)(sigma_I_alpha)
  $
In spin glass model of operators, the energy function can be written as
$
  E(S) = - sum_alpha sum_(n=1)^(2^(|alpha|)) log p_(alpha n) product_(i in I_alpha) ("readbit"(n,i) == "count"(S_j ==  -1, S_j "flips" i) +_(2) sigma_(o i) )
$
In free energy machine, we need to relax the constraint that $S_j$ is a binary variable. Here we use $v_j in [0, 1]$ to denote the probability that the $j$-th operator is applied. And we use $w_i$ to denote the probability that the $i$-th qubit is 0. Here we relax the constraint and assume the qubits are independent to each other. The energy function can be written as
$
  E(sigma) = - sum_(alpha) sum_(n=1)^(2^(|alpha|)) (w_(i_1)(1- w_(i_2))...) log p_(alpha n)
$
To calculate $w_i$, we again assume the $v_j$ are independent to each other.
$
  w_i = sum_(A in A_i \ |A| +_2 sigma_(0i) = 0) product_(j in A) v_j  product_(j' in A_i \\ A) (1 - v_j')
$
where $A_i$ is the set of all operators that act on the $i$-th qubit. This formula can be easily calculated by dynamic programming when $v_j$ are given.

Now we can define the process of free energy machine. Like a simulated annealing process, we start from a high temperature and then gradually decrease it. At each temperature, we update the configuration $v_j$ by gradient descent with respect to the free energy function.
$
  F = E - T S
$
where $E$ is the energy function defined above and $S$ is the entropy function.
$
  S = - sum_(j) (v_j log v_j + (1 - v_j) log (1 - v_j))
$
== Population annealing
Population annealing is a Monte Carlo technique for sampling equilibrium distributions and optimizing complex systems, particularly in statistical physics. It evolves a population of $N$ replicas through a decreasing temperature schedule. At each temperature, replicas are resampled according to Boltzmann weights 
$
w_i = e^(-(beta_(k+1) - beta_k)E_i)
$
where $E_i$ is the energy of replica $i$. The population is stochastically replicated or pruned such that the expected number of copies of replica $i$ is $R_i = w_i/(angle.l w angle.r)$, where 
$angle.l w angle.r = 1/N sum_i w_i$, preserving detailed balance. After resampling, each replica undergoes Markov chain Monte Carlo (MCMC) steps at $beta_(k+1)$ to equilibrate. This dual process of resampling and thermalization allows efficient exploration of energy landscapes, with parallelizability and adaptability near phase transitions. The method minimizes population degeneracy via controlled cooling rates, ensuring convergence to equilibrium states, and is widely applied to spin glasses, polymers, and NP-hard optimization problems.

== Parallel tempering
Parallel tempering (PT), also known as replica exchange Monte Carlo, is a computational method for efficiently sampling complex energy landscapes by simulating multiple replicas of a system in parallel at different temperatures. Each replica $i$ operates at an inverse temperature $beta_i = 1/(k_B T_i)$, with a predefined temperature ladder $beta_1 < beta_2 < dots < beta_M$. During the simulation, replicas undergo local updates (e.g., Metropolis-Hastings steps) at their assigned temperatures. Periodically, adjacent replicas $i$ and $j = i+1$ attempt to swap configurations with an acceptance probability derived from detailed balance:  
$
P_("swap") = min(1, e^((beta_i - beta_j)(E_i - E_j)))
$
where $E_i$ and $E_j$ are the energies of the two configurations. High-temperature replicas ($beta_i$) explore broad regions of phase space, while low-temperature ones ($beta_j$) refine low-energy states. Swaps allow trapped configurations to escape local minima, enhancing equilibration. This method is widely used in studying spin glasses, biomolecules, and other systems with rugged free-energy landscapes.

#bibliography("refs.bib")