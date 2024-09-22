import SciLean.Data.DataArray

/- # 3 章 ニューラルネットワーク -/

/- ### 3.2.2 ステップ関数の実装 -/

def stepFunction (x : Float) : Float :=
  if x > 0 then 1.0 else 0.0

/- ### 3.2.3 ステップ関数のグラフ -/

#eval sizeOf 3.01
#eval sizeOf 5.01
#eval sizeOf 15.01

/-- numpy の np.arrange のような関数を List への関数として実現したもの -/
def List.arrange (start stop step : Float) : List Float :=
  if h : start >= stop || step ≤ 0 then []
  else
    have lem : (stop - (start + step)) < (stop - start) := by
      simp only [ge_iff_le, Bool.or_eq_true, decide_eq_true_eq, not_or, not_le] at h
      rw [@sub_lt_sub_iff_left]
      simp_all
    have : sizeOf (stop - (start + step)) < sizeOf (stop - start) := by
      sorry
    start :: List.arrange (start + step) stop step
termination_by stop - start

#eval! List.arrange (-5.0) 5.0 0.1

-- 停止性を証明するのは難しいかもしれない（それはそれで興味がある）
-- しかし、for 文を使って実装して再帰を避ければきっとうまくいきそう

def SciLean.DataArrayN.arrange [IndexType I] [PlainDataType X]
    (start stop step : Float) : DataArrayN Float I :=
  sorry
  -- if start >= stop then ⊞[]
  -- else arrange (start) x
