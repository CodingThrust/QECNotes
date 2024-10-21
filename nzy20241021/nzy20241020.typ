#import "@preview/cetz:0.2.2": canvas, draw, tree
#import "@preview/suiji:0.3.0": *
#show link: set text(blue)

#set math.equation(numbering: "(1)")


#let today = datetime.today()

// The ASM template also provides a theorem function.
#let definition(title, body, numbered: true) = figure(
  body,
  kind: "theorem",
  supplement: [Definition (#title)],
  numbering: if numbered { "1" },
)
#align(center, text(20pt)[Weekly Quantum Error Correction Research Highlights])
#align(center)[#today.display(), Zhongyi Ni]  // use the default format: year-month-day 

= Non-Clifford and parallelizable fault-tolerant logical gates on constant and almost-constant rate homological quantum LDPC codes via higher symmetries @Zhu_Sikander_Portnoy_Cross_Brown_2023

*Abstract*: We study parallel fault-tolerant quantum computing for families of homological quantum low-density parity-check (LDPC) codes defined on 3-manifolds with constant or almost-constant encoding rate. We derive generic formula for a transversal T gate of color codes on general 3-manifolds, which acts as collective non-Clifford logical CCZ gates on any triplet of logical qubits with their logical-X membranes having a ℤ2 triple intersection at a single point. The triple intersection number is a topological invariant, which also arises in the path integral of the emergent higher symmetry operator in a topological quantum field theory: the ℤ32 gauge theory. Moreover, the transversal S gate of the color code corresponds to a higher-form symmetry supported on a codimension-1 submanifold, giving rise to exponentially many addressable and parallelizable logical CZ gates. We have developed a generic formalism to compute the triple intersection invariants for 3-manifolds and also study the scaling of the Betti number and systoles with volume for various 3-manifolds, which translates to the encoding rate and distance. We further develop three types of LDPC codes supporting such logical gates: (1) A quasi-hyperbolic code from the product of 2D hyperbolic surface and a circle, with almost-constant rate k/n=O(1/log(n)) and O(log(n)) distance; (2) A homological fibre bundle code with O(1/log12(n)) rate and O(log12(n)) distance; (3) A specific family of 3D hyperbolic codes: the Torelli mapping torus code, constructed from mapping tori of a pseudo-Anosov element in the Torelli subgroup, which has constant rate while the distance scaling is currently unknown. We then show a generic constant-overhead scheme for applying a parallelizable universal gate set with the aid of logical-X measurements.

*Highlights*
This paper studies the method of implementing fault-tolerant quantum computation on constant or near-constant rate homological quantum low-density parity-check (LDPC) codes. The authors propose a universal formula that can implement non-Clifford collective logical CCZ gates on color codes of arbitrary 3D manifolds. 
The authors also propose three LDPC codes that support such logical gates:
- A quasi-hyperbolic code, derived from the product of a 2D hyperbolic surface and a circle, $[[n,Theta(n/log(n)),Theta(log(n))]]$

- A homological fiber bundle code, with $[[n,Theta(n/sqrt(log(n))),Theta(sqrt(log(n)))]]$

- A special 3D hyperbolic code: the Torelli mapping rotation code, constructed from pseudo-Anosov elements in the Torelli subgroup, with a constant encoding rate, but the scaling of the distance is still unclear.

Finally, the authors propose a universal constant-overhead scheme using logical X measurements to implement a universal gate set in parallel.

= Lowering Connectivity Requirements For Bivariate Bicycle Codes Using Morphing Circuits @Shaw_Terhal_2024
*Abstract*: In Ref. @Bravyi_Cross_Gambetta_Maslov_Rall_Yoder_2024, Bravyi et al. found examples of Bivariate Bicycle (BB) codes with similar logical performance to the surface code but with an improved encoding rate. In this work, we generalize a novel parity-check circuit design principle called morphing circuits and apply it to BB codes. We define a new family of BB codes whose parity check circuits require a qubit connectivity of degree five instead of six while maintaining their numerical performance. Logical input/output to an ancillary surface code is also possible in a biplanar layout. Finally, we develop a general framework for designing morphing circuits and present a sufficient condition for its applicability to two-block group algebra codes.

Talk on bb code: https://www.youtube.com/watch?v=ZbeeoJrGXPE

*Highlights*
The key contribution is the development of "morphing circuits" that can reduce the qubit connectivity requirements for implementing BB codes from six to five qubits per qubit, while maintaining the same numerical performance.

= Complexity and order in approximate quantum error-correcting codes @Yi_Ye_Gottesman_Liu_2024
*Abstract*: 
Some form of quantum error correction is necessary to produce large-scale fault-tolerant quantum computers and finds broad relevance in physics. Most studies customarily assume exact correction. However, codes that may only enable approximate quantum error correction (AQEC) could be useful and intrinsically important in many practical and physical contexts. Here we establish rigorous connections between quantum circuit complexity and AQEC capability. Our analysis covers systems with both all-to-all connectivity and geometric scenarios like lattice systems. To this end, we introduce a type of code parameter that we call subsystem variance, which is closely related to the optimal AQEC precision. For a code encoding k logical qubits in n physical qubits, we find that if the subsystem variance is below an O(k/n) threshold, then any state in the code subspace must obey certain circuit complexity lower bounds, which identify non-trivial phases of codes. This theory of AQEC provides a versatile framework for understanding quantum complexity and order in many-body quantum systems, generating new insights for wide-ranging important physical scenarios such as topological order and critical quantum systems. Our results suggest that O(1/n) represents a common, physically profound scaling threshold of subsystem variance for features associated with non-trivial quantum order.

Talk on this paper: https://www.youtube.com/watch?v=s7uVJCXAqOI

*Highlights*
Why necessary: 
1. practical deviations: imperfects system preparation,defect, disorder...
2. physical: codes from physical systems can have inexactness that fundamentally originates from their physics.
3.Fundamental incompatibility with sysmmetry.

#bibliography("refs.bib")