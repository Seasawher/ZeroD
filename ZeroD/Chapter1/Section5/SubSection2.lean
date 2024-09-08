import SciLean.Data.DataArray

open SciLean

/- ### 1.5.2 NumPy 配列の生成 -/
namespace Chapter152

-- np.array に相当するかも
#check SciLean.DataArrayN

open SciLean

def x := ⊞[1.0, 2.0, 3.0]

def y := ⊞[2.0, 4.0, 6.0]

#eval x + y

#eval x - y

-- 要素ごとの積になる
#eval x * y

-- 要素ごとの商になる
#eval x / y

-- こういう書き方はできない
#check_failure x / 2.0

-- 一応これでできる
#eval x.mapMono (· / 2.0)

-- これもできない
#check_failure 2 * x

-- これはできる
#check 2.0 • x

end Chapter152
