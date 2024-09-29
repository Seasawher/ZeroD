import SciLean.Data.DataArray

/- # 3 章 ニューラルネットワーク -/

/- ### 3.2.2 ステップ関数の実装 -/

def stepFunction (x : Float) : Float :=
  if x > 0 then 1.0 else 0.0

/- ### 3.2.3 ステップ関数のグラフ -/

#eval sizeOf 3.01
#eval sizeOf 5.01
#eval sizeOf 15.01

#check Float.floor

/-- List.arange が返すリストの長さを決定する関数 -/
def List.arange_length (start stop step : ℚ) : Nat :=
  (stop - start) / step |>.floor.natAbs

open Lean Meta in
/-- List.arange_length の引数にメタ変数が存在しない場合に simp タクティクで値まで簡約できるようにする

infer_var は標準では norm_num によって簡約を試みるが、
それだと中途半端なところで計算が止まって具体的な値が取れなかったので、
具体的な値になるまで簡約できるタクティクが必要だった
-/
simproc reduceArangeLength (List.arange_length _ _ _) := fun e => do
  if e.hasExprMVar then return .done (.mk e none false)

  let reduced ← withTransparency .all $ reduce e
  let rflCst : Expr := .const ``Eq.refl [1]
  let eqProof : Expr := mkApp2 rflCst (.const ``Nat []) reduced
  return .done (.mk reduced eqProof true)

/-- step が 0 のとき、 arange_length の結果は 0 になる -/
theorem List.arange_length_step_zero_eq_zero (start stop : ℚ)
  : arange_length start stop 0 = 0 := by
  unfold arange_length
  rw [Rat.div_def']
  rfl

/-- numpy の np.arange のような関数を List への関数として実現したもの

停止性の証明を避けるために頑張っている。
for 文を使うなどしてもいいかも
-/
def List.arange (start stop step : ℚ) : List Float :=
  let n : Nat := arange_length start stop step
  aux n start
  where
    aux : Nat → ℚ → List Float
      | 0, _ => []
      | n + 1, v => v :: aux n (v + step)

/-- List.arange が返すリストの長さは List.arange_length の値と同じになる -/
theorem List.arange_len_eq (start stop step : ℚ)
  : (arange start stop step).length = arange_length start stop step := by
  unfold arange
  set len := arange_length start stop step
  induction len generalizing start stop step
  case zero => rfl
  case succ len' ih =>
    unfold arange.aux
    simp only [length_cons, add_left_inj]
    rw [ih (stop := start + step)]

#eval 1.0 / 0.0
-- #eval 0.0 / 0.0 |> List.arange.toNat
#eval List.arange (-5.0) 5.0 0.0
#eval List.arange (-5.0) 5.0 0.1
#eval (List.arange (-5.0) 5.0 0.1 |>.head!) = -5.0

/-
Python の numpy.arange がバグるとされているコード

for i in np.arange(3.0, 4.4, 0.1):
  print(i)
-/
#eval List.arange 3.0 4.4 0.1
#eval (List.arange 3.0 4.4 0.1).contains 3.0
#eval (List.arange 3.0 4.4 0.1).contains 4.2
#eval (List.arange 3.0 4.4 0.1).contains 4.3
#eval (List.arange 3.0 4.4 0.1).getLast? |>.get!
#eval ((List.arange 3.0 4.4 0.1).getLast? |>.get!) != 4.4
#eval (List.arange 3.0 4.4 0.1).getLast?.get! = 4.3

#check Float.toString

#eval ToString.toString ((List.arange 3.0 4.4 0.1).getLast? |>.get!)
#check Float

#check List.last'

-- 4.4 が入ってることを検証するコード
#eval (List.arange 3.0 4.4 0.1) |>.filter (fun x => x > 4.3) |> (fun xs => xs.isEmpty)

#check List.isEmpty_nil

open SciLean DataArrayN DataArray

#check DataArray.push
#check DataArray.intro
#check DataArrayN.mk

/-- numpy の np.arange のような関数を DataArray に対して実装したもの -/
def SciLean.DataArray.arange (start stop step : ℚ) : DataArray Float :=
  let list := List.arange start stop step
  intro list.get

/-- numpy の np.arange のような関数を DataArrayN に対して実装したもの -/
def SciLean.DataArrayN.arange
  (start stop step : ℚ)
  {len : Nat} (_len_eq : len = List.arange_length start stop step := by infer_var (norm:=simp) (disch:=rfl))
  : Float^[len] := ⟨DataArray.arange start stop step, sorry_proof⟩

#eval DataArray.arange 3.0 4.4 0.1
#eval DataArray.arange (-5.0) 5.0 0.1

/-- info: DataArrayN.arange 3.0 4.4 0.1 ⋯ : Float^[14] -/
#guard_msgs in
  #check DataArrayN.arange 3.0 4.4 0.1

/- start, stop, step から作るのではなくて、
start, (個数 : Nat), step で作れば IndexType は誤差がなくなる
-/

-- /-- numpy の np.arange のような関数を DataArrayN に対して実装したもの -/
-- def SciLean.DataArrayN.arange {I : Type} [IndexType I]
--     (start stop step : Float) (hk : ((stop - start) / step).floor = size I) : DataArrayN Float I := Id.run do
--   let mut dataArray := []
--   sorry
