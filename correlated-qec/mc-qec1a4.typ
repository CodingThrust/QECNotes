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
= Monte Carlo based QEC Decoder
_Zhongyi Ni_ and _Jinguo Liu_
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

== Task description

The task is to decode a distance $d$ surface code shown below, where qubits are placed on the dots. The code has $(d^2-1)/2$ Z-stabilizers (white) and $(d^2-1)/2$ X-stabilizers (gray) respectively. We denote the $X$ stabilizers as ${S^X_1, S^X_2, ..., S^X_((d^2-1)/2)}$ and the $Z$ stabilizers as ${S^Z_1, S^Z_2, ..., S^Z_((d^2-1)/2)}$.
If no error occurs and the quantum state is within the code space, these stabilizers produce outcome $+1$ when being measured.
Otherwise, they will produce a syndrome $s$ that contains some $-1$ entries.
We use $s^X_i = (1-S^X_i)/2$ and $s^Z_i = (1-S^Z_i)/2$ to transfer $1$ and $-1$ to $0$ and $1$.
Given the syndrome $bold(s) = {s^X_1, s^X_2, ..., s^X_((d^2-1)/2), s^Z_1, s^Z_2, ..., s^Z_((d^2-1)/2)}$, the goal of the decoder is to find the most likely error $bold(e) = {e_1^Z, e_2^Z, ..., e^Z_(d^2), e_1^X, e_2^X, ..., e^X_(d^2)}$ that is consistent with the syndrome. Each $e_i^(X\/Z)$ has value $1$ or $0$, representing whether the $i$-th qubit has X/Z type error or not.
The value of $e$ and $s$ are all $0$ and $1$. The arithmetic of them are modulo $2$, i.e. $0+0=0, 0+1=1, 1+0=1, 1+1=0$. The multiplication remains the same as the normal multiplication.

#figure(canvas(length: 0.9cm, {
  import draw: *
  surface_code((0, 0), 5, 5,color1: silver,color2:white)
  surface_code_label((7,3),color1: white,color2:silver)
  // line((4, 4), (4, 0), stroke:(paint: green, thickness: 2pt))
  // content((4.7, 2.2), text(14pt, green)[$l_x$])

  // line((4, 4), (0, 4), stroke:(paint: red, thickness: 2pt))
  // content((2, 4.7), text(14pt, red)[$l_z$])
}))

Parity check matrix is a compact way to represent a quantum code. It is a $m times 2n$ matrix, where $m$ is the number of stabilizers and $n$ is the number of qubits. Each row of the matrix is a stabilizer, and first $n$ columns of the matrix stands for whether the stabilizer contains pauli $X$ on each qubit, and the last $n$ columns stands for whether the stabilizer contains pauli $Z$ on each qubit. For example, a stabilizer $X_1Z_2X_4Y_5$ on a system of 5 qubits is the following row of the parity check matrix.
$
  [1, 0, 0, 1, 1, 0, 1, 0, 0, 1]
$

== Model
- Each qubit is assocated with a prior error probability that characterized by a triple $(p_i^X, p_i^Z, p_i^Y)$, meaning how likely it is to have X, Z or Y type error. By having an X type error, we mean that an unwanted Pauli $X$ is applied to this qubit by accident.
- The syndrome is associated with errors in qubits in the following way:
  - For syndromes $s_i^X$ associated with X-stabilizers, it is $1$ if odd number of qubits in the stabilizer have $Z$ or $Y$ type error.
  - For syndromes $s_i^Z$ associated with Z-stabilizers, it is $1$ if odd number of qubits in the stabilizer have $X$ or $Y$ type error.

Set $s = {s^X,s^Z}$, we can get the syndrome with the parity check matrix $H$ as follows:
$
  s = H e
$

Hence, we construct the following formal description of the decoding problem:
$
  &max_(bold(e)) p(bold(e))\
  &"s.t." H e = s
$ <eq:decoding-problem>
Again, the sum is modulo $2$.
The error probability is given by
$
  p(bold(e)) = product_(e_i^X = 1\ e_i^Z = 0) p_i^X product_(e_i^Z = 1 \ e_i^X = 0) p_i^Z product_(e_i^X = 1 \ e_i^Z = 1) p_i^Y product_(e_i^X = 0\ e_i^Z = 0) (1 - p_i^X - p_i^Y - p_i^Z)
$
Note here, if a qubit has both X and Z type error, it is counted as a Y type error. We can define the negative log likelihood as the energy of the error pattern.
$
  E(bold(e)) = -log p(bold(e))
$


== Logical operators and decoding success check
The logical operator is the operator that acts directly on the encoded logical qubits (the protected quantum information) while preserving the code space. These operators are crucial for performing computations on encoded data without compromising error correction. The logical operators for surface code $l_x$ and $l_z$ are shown below.
#figure(canvas(length: 0.9cm, {
  import draw: *
  surface_code((0, 0), 5, 5,color1: silver,color2:white)
  surface_code_label((7,3),color1: white,color2:silver)
  line((4, 4), (4, 0), stroke:(paint: green, thickness: 2pt))
  content((4.7, 2.2), text(14pt, green)[$l_x$])

  line((4, 4), (0, 4), stroke:(paint: red, thickness: 2pt))
  content((2, 4.7), text(14pt, red)[$l_z$])
}))
$l_(x\/z)$ is a series of pauli $X\/Z$ actingon a line of qubits. They commute with all the stabilizers, and thus preserve the code space. 

Now we introduce how to check whether a decoding result is successful. Given a real error pattern $bold(e)$, apply any stabilizer on it will not change the syndrome. So if our decoding result $bold(e')$ is different from $bold(e)$ with some stabilizer applied on it, we will treat this decoding result also as successful. However, the logical operators also commute with all the stabilizers, so if the decoding result $bold(e')$ is different from $bold(e)$ with some logical operator applied on it, we will get a same syndrome. But the logical information is different. So we treat this decoding result as failed. Since the logical $X$ and $Z$ operators are anti-commute to each other, if a logical operator is applied by $bold(e') - bold(e)$, there must exist a logical operator that anti-commute to it.Now we can define the decoding success as follows:
1. Syndrome check: $H(e - e') = 0$ 
2. Logical operator check: $l_x (e - e') = 0$ and $l_z (e - e') = 0$ for all logical operators $l_x$ and $l_z$.

== Monte Carlo update

The following strategy can ensure the constraints in @eq:decoding-problem are satisfied during the update.

- *Initialization*: compute an arbitrary error $bold(e)$ that is consistent with the syndrome, which can be done by using Gaussian elimination to solve the linear equations (check the dataset below).
- *Update*: pick a stabilizer $s^X_i$/$s^Z_i$ or a logical operator $l_x$/$l_z$ randomly, apply it to $bold(e)$, and produce a new error pattern $bold(e')$ that is consistent with the syndrome. Note applying a stabilizer or a logical operator to $bold(e)$ does not change the syndrome, since stabilizers commute with the logical operators.

== Description of dataset

- Parity check matrices for $d=9, 21$ surface codes and $[[144,12,12]]$ BBCode@bravyi2024high in four separate folders. In each folder, there are:
  - Parity check matrix $H$ recording in the file `pcm.txt`.
  - Logical operators $l_x$ and $l_z$ recording in the file `logical_x.txt` and `logical_z.txt`.
  - 10000 random samples of error pattern $bold(e)$, with $p_i^X = p_i^Z = p_i^Y = 0.01$, recording in the file `actual_error.txt`. Each line corresponds to a sample. The error is placed in order of $bold(e) = {e_1^Z, e_2^Z, ..., e^Z_(n), e_1^X, e_2^X, ..., e^X_(n)}$.
  - The corresponding syndrome $bold(s)$ recording in the file `syndrome.txt`. Each line corresponds to a sample. The syndrome is placed in order of $bold(s) = {s^X_1, s^X_2, ..., s^X_(m/2), s^Z_1, s^Z_2, ..., s^Z_(m/2)}$.
  - Random initial error pattern within the correct error syndrome, recording in the file `initial_error.txt`. Each line corresponds to a sample. The error is placed in order of $bold(e) = {e_1^Z, e_2^Z, ..., e^Z_(n), e_1^X, e_2^X, ..., e^X_(n)}$.



== Maximum likelihood decoder

The task problem, also known as the min-weight decoding problem, is not the most desired decoding problem. The maximum likelihood decoder is the most accurate decoder, it adds up error probabilities of all possible error patterns that are consistent with the syndrome in different logical sectors, and compares them to find the most likely error pattern.
Here we take surface code as an example. There are 4 logical sectors, $l_x e = plus.minus 1$, $l_z e = plus.minus 1$. 

$
  p_1 = sum_(l_x bold(e) = 0\ l_z bold(e) = 0) p(bold(e)), quad
  p_2 = sum_(l_x bold(e) = 0\ l_z bold(e) = 1) p(bold(e))\
  p_3 = sum_(l_x bold(e) = 1\ l_z bold(e) = 0) p(bold(e)), quad
  p_4 = sum_(l_x bold(e) = 1\ l_z bold(e) = 1) p(bold(e))
$
We compare this four probabilities to find the maximum one and randomly pick an error pattern from that sector as the decoding result.
During the Monte Carlo update, we can record the number of states in each logical sector as an estimate of the above probabilities. Generally, we can use tensor networks to compute the probabilities exactly in small systems.



#bibliography("refs.bib")