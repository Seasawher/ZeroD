import SciLean
open SciLean

/- 
Build me with: `alectryon --lake ../lakefile.lean differentiation_in_scilean.lean
-/ 

/-!
=================================================
Symbolic and Automatic Differentiation in SciLean
=================================================

The backbone of any numerical/scientific software is a automatic and/or
symbolic differentiation. In SciLean, automatic and symbolic differentiation
is build on top of two operators:

1. Differential `∂ : (X → Y) → (X → X → Y)` 

2. Adjoint `†: (X → Y) → (Y → X)`

The differential `∂` tells you how much does the function `f : X → Y`
changes in the direction `dx : X` at the point `x : X`. The usual 
mathematical definition is:

.. math:: 

  \partial \texttt{f x dx} := \lim_{h \rightarrow 0} \frac{f(x + dx) - f(x)}{h}

.. 

Because mathlib is not yet ported to Lean 4 this definition is not used
in SciLean. Right now, the differential `∂` is just postulated to exist.


The adjoint `†` is just well known matrix transposition. Thus for real
valued matrix `A`

.. math:: (A^\dagger)_{ij} = A_{ji}

.. 

For a general linear map `A : X → Y` between two Hilbert spaces `X` and `Y`, 
the adjoint is defined via

.. math :: \langle A x, y \rangle = \langle x, A^\dagger y \rangle  \qquad \, \forall x \in X, \,y \in Y

-/ 

/-!

We will show that these two operators give a rise to a whole zoo of operators

1. Differential `∂ : (X → Y) → (X → X → Y)` 

2. Adjoint `†: (X → Y) → (Y → X)`

3. Adjoint Differantial `∂† : (X → Y) → (X → Y → X)` 

4. Derivative `ⅆ : (ℝ → X) → (ℝ → X)` 

5. Gradient `∇ : (X → ℝ) → (X → X)`

6. Divergence `∇· : (X → X) → (X → ℝ)`

7. Forward Mode AD `fwdDiff : (X → Y) → (X → X×(X → Y))`

8. Reverse Mode AD `revDiff : (X → Y) → (X → X×(Y → X))`

9. Dual Number AD `dualDiff : (X → Y) → (X×X → Y×Y)`

 -/

/-!

Differential
============

Let's have a closer look at the differential `∂`. First of all, we will
be working in the context of vector spaces, so we declare few of them

 -/

section Differential

/-!

The simples possible example: What is the differential of identity function?

 -/ 

  #check (∂ λ x : ℝ => x) rewrite_by (simp; trace_state /- .unfold -/ )

/-!

As expected the change of identity function is just `dx` and it does not depend
on the position `x`.


(Note: The SciLean's custom notation `x:term rewrite_by t:convSeq` 
applies tactic `t` on the term `x`. This notation confuses the `#check` 
command. To see the actual result it is better to use the `trace_state` 
tactic. TODO: Add a document explaining the technical detail of `rewrite_by`
notation.)

Another way to check that the differential is computed correctly

 -/

 example : (∂ λ x : ℝ => x) = (λ x dx => dx) := by simp

/-!

This has the disadvantages that we need to know the result beforehand.


Few more basic derivatives: of a constant, quadratic function, sine

 -/

  #check (∂ λ x : ℝ => (1 : ℝ)) rewrite_by (simp; trace_state /- .unfold -/ )

  #check (∂ λ x : ℝ => x * x) rewrite_by (simp; trace_state /- .unfold -/ )

  #check (∂ λ x : ℝ => Math.sin x) rewrite_by (simp; trace_state /- .unfold -/ )


/-!

The result `fun x dx => dx * x + x * dx` is slightly undesirable. We 
would like to get `fun x dx => 2 * dx * x`. Such algebraic manipulation
is within the scope of mathlib's tactics so we will wait for mathlib
port to Lean 4.

 -/

/-!

Let's introduce few generic functions  to demonstrate some general differentiation 
results

 -/
  variable {X Y Z : Type} [Vec X] [Vec Y] [Vec Z]
  variable (f : Y → Z) [IsSmooth f]
  variable (g : X → Y) [IsSmooth g]

/-!

The most crucial tool when computing derivatives is the chain rule, as a proof

 -/ 

  example : (∂ λ x => f (g x)) = (λ x dx => ∂ f (g x) (∂ g x dx)) := 
    by simp

/-!

Or as a symbolic computation

 -/

  #check (∂ λ x => f (g x)) rewrite_by (simp; trace_state /- .unfold -/)


/-!

The second most common rule is the product rule

 -/ 

  variable (ϕ ψ : ℝ → ℝ) [IsSmooth ϕ] [IsSmooth ψ]

  #check (∂ λ x => ϕ x * ψ x) rewrite_by (simp; trace_state /- .unfold -/)

/-!

Debugging Derivatives
---------------------

Sometimes the differentiation is not doing what we expect. It is crucial
to know how to figure out what went wrong.

To demonstrate this, let's introduce a function `h` but without the smoothenss
proof i.e. we do introduce `[IsSmooth h]`

 -/

  variable (h : X → Y)

/-!

Now the chain rule for `f` and `h` fails

 -/

  example : (∂ λ x => f (h x)) = (λ x dx => ∂ f (h x) (∂ h x dx)) := 
    by simp; admit

/-!

We have to use the `admit` tactic to close the goal as `simp` is unable 
to do it right now.

The problem is that `simp` can't apply chain rule because it is missing
the proof of smoothenss of `h`. To figure this out, we turn on the option
`trace.Meta.Tactic.simp.discharge`

 -/

  set_option trace.Meta.Tactic.simp.discharge true in
  example : (∂ λ x => f (h x)) = (λ x dx => ∂ f (h x) (∂ h x dx)) := 
    by simp; admit

/-!

If you click on `simp`, one of the messages will be

::

  [Meta.Tactic.simp.discharge] SciLean.diff_of_comp, failed to synthesize instance
      SciLean.IsSmooth fun x => h x

(TODO: currently there is tons of crap that should not be there)

If we provide the smoothenss proof we can observe all rewrites by turning on
`trace.Meta.Tactic.simp.rewrite`

-/

  variable [IsSmooth h]

  set_option trace.Meta.Tactic.simp.rewrite true in
  example : (∂ λ x => f (h x)) = (λ x dx => ∂ f (h x) (∂ h x dx)) := 
    by simp

/-!

Now `simp` shows the application of the chain rule

::

  [Meta.Tactic.simp.rewrite] SciLean.diff_of_comp:99, ∂fun x =>
        f (h x) ==> fun x dx => SciLean.differential f (h x) (SciLean.differential (fun x => h x) x dx)


A bit more complicated computation

 -/

  set_option trace.Meta.Tactic.simp.rewrite true in
  #check (∂ λ x : ℝ => x * Math.exp (x*x) + x) 
           rewrite_by (simp; trace_state /- .unfold -/)

/-!

Clicking on `simp` reveals fairly long list of rewrites.

We will worry

 -/ 

/-! 

To indicate smoothenss(or any other properties) we use typeclasses. 
`IsSmooth f` is a typeclass containing a proof that the function `f` 
is smooth. The typeclass system is fairly powerfull and can automatically 
prove smoothness of more complicated function. 

Composition of smooth function is a smooth function

 -/ 

example : IsSmooth (λ x => f (g x)) := by infer_instance

/-!

The tactic `infer_instance` invokes typeclass system

 -/

end Differential



/-!

Defining Differentiable Function
================================

Sometimes we want to define our own differentiable functions

 -/

def square (x : ℝ) := x * x

/-!

We might be surprized that differentiating this function does not work 

 -/

example : (∂ square) = (λ x dx => dx * x + x * dx) :=
by 
  simp  -- this does nothing as we know nothing about `square`
  unfold square  -- unfold definition of `square`
  simp  -- now it works

/-!

Manually unfolding every definition can get tedious. To circumvent that, 
you have to anotate the definition of `square` to indicate that it is 
differentiable.

 -/ 

def square_v1 (x : ℝ) : ℝ := x * x
argument x
  isSmooth, diff

/-!

(TODO: When using `def` with annotations, you **have** explicitely specify 
the return type. Remove this limitation or add a warrning when the
return type is missing.)

The `argument x` specifies that everything that follows concerns the 
argument `x`. The `isSmooth` generates proof that `square_v1` is 
smooth in the argument `x` and `diff` defines a new function 
`square_v1.arg_x.diff` that is the function's differential.

There are few variants that are usefull when full automation fails or
produces undesirable results.

 -/ 

def square_v2 (x : ℝ) : ℝ := x * x
argument x
  -- specify how to prove smoothenss
  isSmooth := by unfold square_v2; infer_instance,
  -- specify what the differential is and how to prove it
  diff := 2 * dx * x by simp[diff, square_v2]; funext x dx; ring

def square_v3 (x : ℝ) : ℝ := x * x
argument x
  -- proof is done automatically
  isSmooth,
  -- specify how to compute differential
  diff by simp[square_v3]

/-! 

Defining a new function, `square_v1.arg_x.diff` for the differential 
can be undesirable. Sometimes we want `∂ square` to directly simplify
to `λ x dx => dx * x + x * dx`. To achieve this, we use `diff_simp`
instead of `diff`.

 -/ 

def square_v4 (x : ℝ) : ℝ := x * x
argument x
  isSmooth,
  diff_simp by simp[square_v4]

/-!

The `diff_simp` annotation allows the same variants as `diff`.

Proof that the second derivative is `2`. We have to do manual unfolding 
when working with `square_v3` but with `square_v4` the proof is immediate

 -/

example : (λ x => ∂ ∂ square_v2 x 1 1) = (λ x => 2) := 
by 
  simp  -- simp gets stopped on `square_v3.arg_x.diff`
  unfold square_v2.arg_x.diff -- manually unfold definition
  simp  -- we can continue with computation

example : (λ x => ∂ ∂ square_v4 x 1 1) = (λ x => 2) := by simp


/-!

We missed our chance to add annotations to the original function `square`.
We can add additional annotations later on with `function_properties`. 

-/

function_properties square (x : ℝ) : ℝ  
argument x
  isSmooth, diff_simp

-- now we can differentiate `square`
example : ∂ square = λ x dx => dx * x + x * dx := by simp

/-!

The keyword `function_properties` works exactly like `def` with annotations
but you do not provide the function definition `:= ...`. Argument types 
and order have to match exactly the original definition but the argument 
names do not have to be the same.

 -/

/-!

Multiple Arguments
------------------

(TODO: Explain how annotations work with multiple arguments. The current
behavior is a bit limiting, so I should rewrite how they work before 
I write this section.)

 -/

/-!

How Do Annotations Work?
------------------------

The `isSmooth` and `diff` annotations might appear misterious but they
are simple macros.

This definition 
 -/

def cube (x : ℝ) : ℝ := x * x * x
argument x
  isSmooth := by unfold cube; infer_instance,
  diff := 3 * dx * x * x by simp[diff,cube]; funext x dx; ring

/-!

Is unfolded to (we have to use a new identifier `cube_v1` as `cube` is 
already defined)

 -/

def cube_v1 (x : ℝ) : ℝ := x * x * x

-- proof of smoothness
instance cube_v1.arg_x.isSmooth : IsSmooth (λ x => cube_v1 x) := 
by unfold cube_v1; infer_instance

-- differential definition
def cube_v1.arg_x.diff (x dx : ℝ) : ℝ := 3 * dx * x * x

-- simplifier rule
@[simp]
theorem cube_v1.arg_x.diff_simp 
  : ∂ cube_v1 = cube_v1.arg_x.diff :=
by simp[diff,cube_v1]; funext x dx; ring

/-! 

Using `diff_simp` annotation does not define `cube_v1.arg_x.diff` and 
the simp theorem states directly `∂ cube_v1 = λ x dx => 3 * dx * x * x`.

 -/

