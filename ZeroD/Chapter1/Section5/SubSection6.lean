import SciLean

/- ### 1.5.6 要素へのアクセス -/
namespace Chapter156

open SciLean

def X := ⊞[51.0, 55.0; 14.0, 19.0; 0.0, 4.0]
#eval X
#check X
#check Float^[3,2]
#check SciLean.DataArrayN

-- 本当はゼロ行目をとるつもりだったのだが，１番目の要素になってしまった
#eval X[0]

-- X[0] はこういうものとして解釈される
#eval X[0, 0]

-- TODO: ゼロ行目を取得する適切な方法は?

-- 現状ではこれがゼロ行目を取得する最も簡単な方法かな
#eval ⊞ i => X[0, i]

-- (0, 1) の要素
#eval X[0, 1]

-- DataArrayN から List Float に変換できないだろうか？
-- Loogle は使えないので exact? で探す
example (X : Float^[1,2]) : List Float := by sorry

-- これだとすべての要素を逆順に出すだけになってしまう
-- 「すべての行」にはなってくれない
-- TODO: なぜ DataArrayN には forIn インスタンスがないのか？
-- TODO: なぜ逆順なのか？
#eval show IO Unit from
  for elm in X.toList do
    IO.println elm

-- TODO: 行列の「すべての行成分」を取得する適切な方法を調べる
variable {α : Type} [pd : PlainDataType α] {ι : Type} [IndexType.{0} ι]

/-- すべての行を取得する関数 -/
def _root_.SciLean.DataArrayN.rows {m n : Nat} (xs : DataArrayN α (Fin m × Fin n)) : Array (DataArrayN α (Fin n)) := Id.run do
  let mut array := #[]
  for h : i in [0:m] do
    let i : Fin m := ⟨i, h.right⟩
    let row := ⊞ j => xs[i, j]
    array := array.push row
  return array

-- すべての行を取得する関数
#eval X.rows

#eval show IO Unit from
  for row in X.rows do
    IO.println row

-- DataArrayN Float (Fin 6) という型になってほしいけど、ちゃんとなってる
/-- info: X.flatten ⋯ : Float^[6] -/
#guard_msgs in #check X.flatten

-- Fin n は IndexType 型クラスのインスタンス
#synth IndexType (Fin 2)

-- simp 補題を追加する
@[simp] theorem IndexType.card_fin (n : Nat) : size (Fin n) = n := by rfl

-- ちゃんと shape が Fin 6 になった！
#check X.flatten

-- インデックスの0番目と2番目と4番目を取得したいが
-- こういう書き方はできないようだ
#check_failure X[#[0, 2, 4]]

#check GetElem

-- instance : GetElem (DataArrayN α ι) (Array Nat) (Array α) (fun xs arr => arr.all fun i => i < IndexType.card ι) where
--   getElem xs arr h := Id.run do
--     let mut ys := #[]
--     -- for i in arr do
--     --   have : i < IndexType.card ι := by
--     --     exact? using h
--     --   let i : Fin (IndexType.card ι) := ⟨i, ?lem⟩
--     --   ys := ys.push (xs[⟨i, h i⟩])
--     -- arr.map (fun i => xs[i])
--     sorry

end Chapter156

open SciLean IndexType

def matVecMul {n m} (A : Float^[n,m]) (x : Float^[m]) := ⊞ i => ∑ j, A[i,j] * x[j]

-- 書いたときの心境がわからないのでコメントアウト
-- def_optimize matVecMul by
--   simp only [GetElem.getElem, LeanColls.GetElem'.get, DataArrayN.get, IndexType.toFin, id,
--              Fin.pair, IndexType.fromFin, Fin.cast, IndexType.card]

def matDot {n m} (A B : Float^[n,m]) := ∑ (ij : Fin n × Fin m), A[ij] * B[ij]

def_optimize matDot by optimize_index_access
