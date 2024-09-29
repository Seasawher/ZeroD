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

/-- numpy の np.arange のような関数を List への関数として実現したもの

停止性の証明を避けるために頑張っている。
for 文を使うなどしてもいいかも
-/
def List.arange (start stop step : Float) : List Float :=
  let n : Nat := (stop - start) / step |> toNat
  aux n start
  where
    toNat (f : Float) : Nat :=
      let f' := f.floor
      if f'.isFinite then f'.toUInt64.toNat else 0
    aux : Nat → Float → List Float
      | 0, _ => []
      | n + 1, v => v :: aux n (v + step)

#eval 1.0 / 0.0
#eval 0.0 / 0.0 |> List.arange.toNat
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
def SciLean.DataArray.arange (start stop step : Float) : DataArray Float := Id.run do
  let list := List.arange start stop step
  let mut array : DataArray Float := DataArray.mkEmpty (capacity := list.length)
  for i in list do
    array := array.push i
  return array

#eval DataArray.arange 3.0 4.4 0.1
#eval DataArray.arange (-5.0) 5.0 0.1

/- start, stop, step から作るのではなくて、
start, (個数 : Nat), step で作れば IndexType は誤差がなくなる
-/

-- /-- numpy の np.arange のような関数を DataArrayN に対して実装したもの -/
-- def SciLean.DataArrayN.arange {I : Type} [IndexType I]
--     (start stop step : Float) (hk : ((stop - start) / step).floor = size I) : DataArrayN Float I := Id.run do
--   let mut dataArray := []
--   sorry
