import SciLean
import SciLean.Util.Profile
import SciLean.Tactic.LetNormalize
import SciLean.Util.RewriteBy

import SciLean.Core.Simp.Sum

open SciLean

variable 
  {K : Type _} [RealScalar K]
  {X : Type _} [SemiInnerProductSpace K X]
  {Y : Type _} [SemiInnerProductSpace K Y]
  {Z : Type _} [SemiInnerProductSpace K Z]
  {ι : Type _} [EnumType ι]
  {E : ι → Type _} [∀ i, SemiInnerProductSpace K (E i)]

set_default_scalar K 

example 
  : (∇ (x : Fin 10 → K), fun i => x i)
    =
    fun x dx => dx :=
by 
  (conv => lhs; autodiff)

example
  : (∇ (x : Fin 10 → K), ∑ i, x i)
    =
    fun x i => 1 :=
by 
  (conv => lhs; autodiff)

example
  : (∇ (x : Fin 10 → K), ∑ i, ‖x i‖₂²)
    =
    fun x i => 2 * (x i) :=
by
  (conv => lhs; autodiff)

example (A : Fin 5 → Fin 10 → K)
  : (∇ (x : Fin 10 → K), fun i => ∑ j, A i j * x j)
    =
    fun _ dy j => ∑ i, A i j * dy i := 
by 
  (conv => lhs; autodiff)

variable [PlainDataType K]

example 
  : (∇ (x : K ^ Idx 10), fun i => x[i])
    =
    fun _ x => ⊞ i => x i :=
by 
  (conv => lhs; autodiff)

example
  : (∇ (x : K ^ Idx 10), ⊞ i => x[i])
    =
    fun _ x => x :=
by 
  (conv => lhs; autodiff)

example
  : (∇ (x : Fin 10 → K), ∑ i, x i)
    =
    fun x i => 1 :=
by 
  (conv => lhs; autodiff)

example
  : (∇ (x : K ^ Idx 10), ∑ i, x[i])
    =
    fun x => ⊞ _ => (1:K) :=
by 
  (conv => lhs; unfold scalarGradient; ftrans only; autodiff)

example
  : (∇ (x : Fin 10 → K), ∑ i, ‖x i‖₂²)
    =
    fun x i => 2 * (x i) :=
by
  (conv => lhs; autodiff)

set_option trace.Meta.Tactic.simp.rewrite true in
example (A : Idx 5 → Idx 10 → K)
  : (∇ (x : K ^ Idx 10), fun i => ∑ j, A i j * x[j])
    =
    fun _ dy => ⊞ j => ∑ i, A i j * dy i := 
by 
  (conv => 
    lhs
    unfold gradient
    ftrans only)


example 
  : (∇ (x : Fin 10 → K), fun i => x i)
    =
    fun _ dx => dx :=
by
  (conv => lhs; autodiff)
  

example 
  : (∇ (x : Fin 5 → Fin 10 → K), fun i j => x i j)
    =
    fun _ dx => dx :=
by
  (conv => lhs; autodiff)


example
  : (∇ (x : Fin 5 → Fin 10 → Fin 15→ K), fun i j k => x i j k)
    =
    fun _ dx => dx :=
by
  (conv => lhs; autodiff)


example
  : (∇ (x : Fin 5 → Fin 10 → Fin 15→ K), fun k i j => x i j k)
    =
    fun _ dx i j k => dx k i j :=
by
  (conv => lhs; autodiff)


-- TODO remove `hf'` assumption, is should be automatically deduced from `hf` once #23 is resolved
example (f : X → Fin 5 → Fin 10 → Fin 15→ K) (hf : ∀ i j k, HasAdjDiff K (f · i j k))
  (hf' : HasAdjDiff K f)
  : (∇ (x : X), fun k i j => f x i j k)
    =
    fun x dy => 
      let ydf := <∂ f x
      ydf.2 fun i j k => dy k i j :=
by
  (conv => lhs; autodiff)



set_option trace.Meta.Tactic.simp.rewrite true in
example 
  : (<∂ (x : K ^ Idx 10), fun (ij : Idx 5 × Idx 10) => x[ij.snd])
    =
    0 := 
by
  conv => 
    lhs
    ftrans only
    let_normalize


set_option trace.Meta.Tactic.simp.rewrite
example 
  : (∇ (x : K ^ Idx 10), fun i => x[i])
    =
    fun _ dx => ⊞ i => dx i :=
by
  (conv => lhs; unfold gradient; ftrans only)
  

example 
  : (∇ (x : K ^ (Idx 10 × Idx 5)), fun i j => x[(i,j)])
    =
    fun _ dx => ⊞ ij => dx ij.1 ij.2 :=
by
  (conv => lhs; autodiff)


example
  : (∇ (x : K ^ (Idx 5 × Idx 10 × Idx 15)), fun i j k => x[(k,i,j)])
    =
    fun _ dx => ⊞ kij => dx kij.2.1 kij.2.2 kij.1 :=
by
  (conv => lhs; autodiff)


example
  : (∇ (x : Fin 5 → Fin 10 → Fin 15→ K), fun k i j => x i j k)
    =
    fun _ dx i j k => dx k i j :=
by
  (conv => lhs; autodiff)
