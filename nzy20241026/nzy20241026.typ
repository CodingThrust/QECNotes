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

= Measurement-free, scalable and fault-tolerant universal quantum computing @Butt_Locher_Brechtelsbauer_Büchler_Müller_2024

*Abstract*: Reliable execution of large-scale quantum algorithms requires robust underlying operations and this challenge is addressed by quantum error correction (QEC). Most modern QEC protocols rely on measurements and feed-forward operations, which are experimentally demanding, and often slow and prone to high error rates. Additionally, no single error-correcting code intrinsically supports the full set of logical operations required for universal quantum computing, resulting in an increased operational overhead. In this work, we present a complete toolbox for fault-tolerant universal quantum computing without the need for measurements during algorithm execution by combining the strategies of code switching and concatenation. To this end, we develop new fault-tolerant, measurement-free protocols to transfer encoded information between 2D and 3D color codes, which offer complementary and in combination universal sets of robust logical gates. We identify experimentally realistic regimes where these protocols surpass state-of-the-art measurement-based approaches. Moreover, we extend the scheme to higher-distance codes by concatenating the 2D color code with itself and by integrating code switching for operations that lack a natively fault-tolerant implementation. Our measurement-free approach thereby provides a practical and scalable pathway for universal quantum computing on state-of-the-art quantum processors.

*Highlights*
- Code switching to perform transversal logical operations. $[[15,1,3]]$ code with transversal T gate and $[[7,1,3]]$ code.
- Code switching is after the sydrome extraction. Switching and error correction are done in the same time.
- Concatenation is still hard.


= High-threshold and low-overhead fault-tolerant quantum memory@Bravyi_Cross_Gambetta_Maslov_Rall_Yoder_2024

*Abstract*: The accumulation of physical errors prevents the execution of large-scale algorithms in current quantum computers. Quantum error correction promises a solution by encoding k logical qubits onto a larger number n of physical qubits, such that the physical errors are suppressed enough to allow running a desired computation with tolerable fidelity. Quantum error correction becomes practically realizable once the physical error rate is below a threshold value that depends on the choice of quantum code, syndrome measurement circuit and decoding algorithm. We present an end-to-end quantum error correction protocol that implements fault-tolerant memory on the basis of a family of low-density parity-check codes. Our approach achieves an error threshold of 0.7% for the standard circuit-based noise model, on par with the surface code that for 20 years was the leading code in terms of error threshold. The syndrome measurement cycle for a length-n code in our family requires n ancillary qubits and a depth-8 circuit with CNOT gates, qubit initializations and measurements. The required qubit connectivity is a degree-6 graph composed of two edge-disjoint planar subgraphs. In particular, we show that 12 logical qubits can be preserved for nearly 1 million syndrome cycles using 288 physical qubits in total, assuming the physical error rate of 0.1%, whereas the surface code would require nearly 3,000 physical qubits to achieve said performance. Our findings bring demonstrations of a low-overhead fault-tolerant quantum memory within the reach of near-term quantum processors.

*Highlights*
- QLDPC code construction.
- $[[144,12,12]]$ code as an example.


#bibliography("refs.bib")