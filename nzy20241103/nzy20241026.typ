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

= Cups and Gates I: Cohomology invariants and logical quantum operations@breuckmann2024cups

*Abstract*: We take initial steps towards a general framework for constructing logical gates in general
quantum CSS codes. Viewing CSS codes as cochain complexes, we observe that cohomology
invariants naturally give rise to diagonal logical gates. We show that such invariants exist
if the quantum code has a structure that relaxes certain properties of a differential graded
algebra. We show how to equip quantum codes with such a structure by defining cup
products on CSS codes. The logical gates obtained from this approach can be implemented
by a constant-depth unitary circuit. In particular, we construct a Λ-fold cup product that
can produce a logical operator in the Λ-th level of the Clifford hierarchy on Λ copies
of the same quantum code, which we call the copy-cup gate. For any desired Λ, we can
construct several families of quantum codes that support gates in the Λ-th level with
various asymptotic code parameters.

*Highlights*
- Code construction with cohomology invariants.
- Mathmetical method generalizes the Toric code. Looks very interesting to me.

= Locality vs Quantum Codes@dai2024locality

*Abstract*: Please check the paper for details.

*Highlights*
- Theorem 1.2 gives an upper bound of long range interactions needed in 2D-embeddings of a $[[n,k,d]]$ stabilizer code.
- Table 1 shows how theorem 1.2 applied to well-known families of codes.


#bibliography("refs.bib")