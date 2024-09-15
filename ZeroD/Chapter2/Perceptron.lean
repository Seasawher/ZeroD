import SciLean.Data.DataArray

/- # 2 パーセプトロン -/

set_option autoImplicit false
set_option relaxedAutoImplicit false
set_option linter.hashCommand false

namespace Perceptron

/- ## 2.3 パーセプトロンの実装 -/
/- ### 2.3.1 簡単な実装 -/

/-- AND 論理回路をパーセプトロン的に作ったもの -/
def and' (x1 x2 : Float) : Float :=
  let w1 := 0.5
  let w2 := 0.5
  let θ := 0.7
  let tmp := x1 * w1 + x2 * w2
  if tmp <= θ then 0 else 1

#guard and' 0 0 == 0
#guard and' 1 0 == 0
#guard and' 0 1 == 0
#guard and' 1 1 == 1

/- ### 2.3.2 重みとバイアスの導入 -/

/-
```python
>>> import numpy as np
>>> x = np.array([0, 1]) # 入力
>>> w = np.array([0.5, 0.5]) # 重み
>>> b = -0.7 # バイアス
>>> w*x
array([ 0. , 0.5])
>>> np.sum(w*x)
0.5
>>> np.sum(w*x) + b
-0.19999999999999996 # およそ-0.2（浮動小数点数による演算誤差）
```
-/

-- なぜか python にはある誤差がない
#eval
  let x :=  ⊞[0.0, 1.0]
  let w := ⊞[0.5, 0.5]
  let b := - 0.7
  (w * x).foldl (· + ·) 0 + b

open SciLean DataArrayN

variable {X I : Type}

/-- 行列の要素をすべて足した和 -/
def _root_.SciLean.DataArrayN.sum [IndexType I] [PlainDataType X] [Add X] [Zero X]
    (x : DataArrayN X I) :=
  x.foldl (· + ·) 0

/- ### 2.3.3 重みとバイアスによる実装 -/

/-- AND 論理回路をパーセプトロン的に作ったもの。
バイアスを使用した実装 -/
def and (x1 x2 : Float) : Float :=
  let x := ⊞[x1, x2]
  let w := ⊞[0.5, 0.5]
  let b := -0.7
  let tmp := (w * x).sum + b
  if tmp <= 0 then 0 else 1

/-- NAND 回路 -/
def nand (x1 x2 : Float) : Float :=
  let x := ⊞[x1, x2]
  let w := ⊞[-0.5, -0.5]
  let b := 0.7
  let tmp := (w * x).sum + b
  if tmp <= 0 then 0 else 1

/-- OR 回路 -/
def or (x1 x2 : Float) : Float :=
  let x := ⊞[x1, x2]
  let w := ⊞[0.5, 0.5]
  let b := -0.2
  let tmp := (w * x).sum + b
  if tmp <= 0 then 0 else 1

/-- XOR 回路 -/
def xor (x1 x2 : Float) : Float :=
  let s1 := nand x1 x2
  let s2 := or x1 x2
  let y := and s1 s2
  y

#guard xor 0 0 == 0
#guard xor 1 0 == 1
#guard xor 0 1 == 1
#guard xor 1 1 == 0

end Perceptron
