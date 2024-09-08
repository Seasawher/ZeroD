import SciLean.Data.DataArray

open SciLean

/- ### 1.5.5 ブロードキャスト -/
namespace Chapter155

def A := ⊞[1.0, 2.0; 3.0, 4.0]
def B := ⊞[10.0, 20.0]

-- ブロードキャストはできない
#check_failure A * B

-- reshape もできない．
-- サイズが異なるので
#check B.reshape (Fin 2 × Fin 2) (by sorry)

-- B をコピーすることによって Fin 2 × Fin 2 の要素を作りたい
-- 簡単に行う方法はなさそうなので自作
-- TODO: これを簡単に行う方法を作る
def B' : DataArrayN Float (Fin 2 × Fin 2) := ⊞ i j => B[j]

#eval B'

#eval A * B'

end Chapter155
