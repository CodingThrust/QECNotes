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
#align(center, text(20pt)[Flag Fault-Tolerant Quantum Error Correction])
#align(center)[#today.display(), Zhongyi Ni]  // use the default format: year-month-day 

= Why?
Site from the qec zoo(https://errorcorrectionzoo.org/list/quantum_decoders#defterm-Effective_20Xdistance_20Xand_20Xhook_20Xerrors):

"*Effective distance and hook errors:* Decoders are characterized by an effective distance (a.k.a. circuit-level distance), the minimum number of faulty operations during syndrome measurement that is required to make an undetectable error. A code is distance-preserving if it admits a decoder whose circuit-level distance is equal to the code distance. A particularly dangerous class of syndrome measurement circuit faults are hook errors, which are ancilla faults that cause more than one data-qubit error. Hook errors occur at specific places in a syndrome extraction circuit and can sometimes be removed by re-ordering the gates of the circuit. If not, the use of flag qubits to detect hook errors may be necessary to yield fault-tolerant decoders."

*Questions:* 
- How to determine the effective distance of a quantum error correction code? 
- How to re-ordering the gates of the circuit to remove hook errors?
- A decoder with both stabilizer and flag qubits?
= How?
- Flag fault-tolerant error correction for any stabilizer code.@chao2020flag

- Optimization Tools for Distance-Preserving Flag Fault-Tolerant Error Correction.@pato2024optimization
#bibliography("refs.bib")