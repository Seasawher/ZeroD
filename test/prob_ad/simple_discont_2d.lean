import SciLean.Core.Integral.HasParamDerivWithJumps
import SciLean.Core.Integral.HasParamFwdDerivWithJumps
import SciLean.Core.Integral.HasParamRevDerivWithJumps
import SciLean.Core.Integral.HasParamDerivWithJumpsCommon
import SciLean.Tactic.LSimp
import SciLean.Tactic.LFunTrans
import SciLean.Core.Integral.SurfaceIntegral

open SciLean MeasureTheory Set Scalar

variable
  {R : Type} [RealScalar R] [MeasureSpace R] [BorelSpace R] [PlainDataType R]

set_default_scalar R


example (w : R) :
    (fderiv R (fun w' =>
      ∫ xy in Icc (0:R) 1 ×ˢ (Icc (0 : R) 1),
        if xy.1 + xy.2 ≤ w' then xy.1*xy.2*w' else xy.1+xy.2+w') w 1)
    =
    sorry := by

  conv =>
    lhs

    rw[fderiv_under_integral_over_set
           (hf:= by gtrans
                      (disch:=first | fun_prop_no_ifs | assume_almost_disjoint)
                      (norm:=lsimp only [ftrans_simp]))
                      (hA := by assume_almost_disjoint)]

    lautodiff (disch:=first | fun_prop | gtrans (disch:=fun_prop))

    conv in (∫ x in _, _ ∂μH[_]) =>

      lsimp (disch:=gtrans (disch:=fun_prop)) only
        [surface_integral_parametrization_inter R]
      lautodiff (disch:=gtrans (disch:=fun_prop))
        [integral_over_bounding_ball (R:=R)]

    lsimp only

  sorry_proof



example (w : R) :
    (fwdFDeriv R (fun w' =>
      ∫ xy in Icc (0:R) 1 ×ˢ (Icc (0 : R) 1),
        if xy.1 + xy.2 ≤ w' then xy.1*xy.2*w' else xy.1+xy.2+w') w 1)
    =
    let interior :=
      ∫ (x : R × R) in Icc 0 1 ×ˢ Icc 0 1,
        let ydy := x.1 * x.2;
        if x.1 + x.2 ≤ w then (ydy * w, ydy) else (x.1 + x.2 + w, 1);
    let dec := planeDecomposition (1, 1);
    let a := w / Scalar.sqrt 2;
    let center := dec.symm (1 / 2, 1 / 2);
    let s :=
      ∫ (x : R^[1]) in closedBall₂ center.2 (sqrt (sqrt (1 / 2) ^ 2 - (center.1 - a) ^ 2)),
        let x_1 := dec (a, x);
        let vals := x_1.1 * x_1.2 * w;
        let vals_1 := x_1.1 + x_1.2 + w;
        if dec (a, x) ∈ Icc 0 1 ×ˢ Icc 0 1 then (sqrt (2:R))⁻¹ * (vals - vals_1) else 0;
    (interior.1, interior.2 + s) := by

  conv =>
    lhs

    rw[fwdFDeriv_under_integral_over_set
           (hf:= by gtrans
                      (disch:=first | fun_prop_no_ifs | assume_almost_disjoint)
                      (norm:=lsimp only [ftrans_simp]))
                      (hA := by assume_almost_disjoint)]

    lautodiff (disch:=first | fun_prop | gtrans (disch:=fun_prop))

    conv in (∫ x in _, _ ∂μH[_]) =>

      lsimp (disch:=gtrans (disch:=fun_prop)) only
        [surface_integral_parametrization_inter R]
      lautodiff (disch:=gtrans (disch:=fun_prop))
        [integral_over_bounding_ball (R:=R)]

    lsimp only

  sorry_proof


open Scalar

example (w : R) :
    (fgradient (fun w' =>
      ∫ xy in Icc (0:R) 1 ×ˢ (Icc (0 : R) 1),
        if xy.1 + xy.2 ≤ w' then xy.1*xy.2*w' else xy.1+xy.2+w') w)
    =
    let interior :=
      ∫ (x : R × R) in Icc 0 1 ×ˢ Icc 0 1,
        let ydf := x.1 * x.2;
        if x.1 + x.2 ≤ w then ydf else 1;
    let dec := planeDecomposition (1, 1);
    let a := w / Scalar.sqrt 2;
    let center := dec.symm (1 / 2, 1 / 2);
    let s :=
      ∫ (x : R^[1]) in closedBall₂ center.2 (sqrt (sqrt (1 / 2) ^ 2 - (center.1 - a) ^ 2)),
        let x_1 := dec (a, x);
        let vals := x_1.1 * x_1.2 * w;
        let vals_1 := x_1.1 + x_1.2 + w;
        if dec (a, x) ∈ Icc 0 1 ×ˢ Icc 0 1 then
          (vals - vals_1) * (sqrt (2:R))⁻¹
        else 0;
    interior + s := by

  conv =>
    lhs
    unfold fgradient
    rw[revFDeriv_under_integral_over_set
           (hf:= by gtrans
                      (disch:=first | fun_prop_no_ifs | assume_almost_disjoint)
                      (norm:=lsimp only [ftrans_simp]))
                      (hA := by assume_almost_disjoint)]

    lautodiff (disch:=first | fun_prop | gtrans (disch:=fun_prop)) [frontierGrad]

    conv in (∫ x in _, _ ∂μH[_]) =>

      lsimp (disch:=gtrans (disch:=fun_prop)) only
        [surface_integral_parametrization_inter R]
      lautodiff (disch:=gtrans (disch:=fun_prop))
        [integral_over_bounding_ball (R:=R)]

    lsimp only
