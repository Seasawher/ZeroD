import SciLean.Data.DataArray

open SciLean

/- ### 1.5.4 NumPy の N 次元配列 -/
namespace Chapter154

open SciLean

set_option linter.hashCommand false

#check DataArrayN

def A := ⊞[1.0, 2.0; 3.0, 4.0]
def C := ⊞[1.0, 2.0]

#eval A

variable {α : Type} [pd : PlainDataType α] {ι : Type} [IndexType.{0} ι]

def _root_.SciLean.DataArrayN.shape (_xs : DataArrayN α ι) := ι

-- shape を出力するコマンドを作ってみる
-- そんなに需要はないかも
macro "#shape" F:term : command => `(#reduce SciLean.DataArrayN.shape $F)

#shape A

def B := ⊞[3.0, 0.0; 0.0, 6.0]

#eval A + B

-- 要素ごとに計算が行われる
#eval A * B

-- ブロードキャストによるスカラー倍はできない
#check_failure C * A

variable {α : Type} [pd : PlainDataType α] {ι : Type} [IndexType.{0} ι]

scoped instance [Mul α] : HMul α (DataArrayN α ι) (DataArrayN α ι) where
  hMul x xs := xs.mapMono (x * ·)

/-
{ hMul := fun x xs => xs.mapMono fun x_1 => x * x_1 }
-/
#whnf (inferInstance : HMul Float (DataArrayN Float (Fin 2)) (DataArrayN Float (Fin 2)))

-- あれ？なんでできないんだろう?
-- 失敗する理由はよくわからない
#check_failure 10.0 * C

-- これでスカラー乗算ができる
#eval 10.0 • A

end Chapter154
