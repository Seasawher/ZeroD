/- ## 1.3 Python インタプリタ -/
import Lean

/- ### 1.3.1 算術計算 -/

-- これはゼロになってしまう
#guard 1 - 2 = 0

#guard (1 - 2 : Int) = -1

#guard 4 * 5 = 20

-- これは１になってしまう
#guard 7 / 5 = 1

-- Float として計算しないと値は Float にならない
-- Lean の Float は Python の float と同じ（どっちも倍精度）
#eval (7 / 5 : Float)

-- べき乗
-- Python では `**` だが，Lean では `^` で表す
#guard 3 ^ 2 = 9


/- ### 1.3.2 データ型
Lean では型を調べるのは関数を使わなくていいので、`type()` はない
hover するか、`#check` を使う
-/


/- ### 1.3.3 変数
省略
-/


/- ### 1.3.4 リスト -/
namespace Chapter134

-- 配列（Python のリストは Lean の配列に相当しそう）
def a := #[1, 2, 3, 4, 5]

#eval a

-- リストの長さを取得する
#eval a.size

-- 最初の要素にアクセス
#eval a[0]

#eval a[4]

-- 値の代入（Lean では実際には破壊的変更はしていない）
#eval a.set! 4 99

-- Python と似たような記法が使えるが，
-- 以下のように表示されてしまう.
-- これは嬉しくない
#eval a[0:2]

-- Subarray というのがある！
#check Subarray

-- array フィールドを使うと，元の配列が表示される
-- これは欲しいものではない
#eval a[0:2].array

-- toArray という関数があり，それでスライス先を表示できる
-- 0 ≤ i < 2 番目の要素を表示する
#eval a[0:2].toArray

-- こうやっても中身を表示できる
#eval (a[0:2] : Array Nat)

-- ToString インスタンスはこういうのになっている
#eval s!"{a[0:2]}"

-- インデックスの1から最後まで
#eval (a[1:] : Array Nat)

-- 最初からインデックスの３番目まで（３番目は含まない）
#eval (a[:3] : Array Nat)

-- Lean ではこういう書き方はできない
#check_failure a[:-1]

-- やるとしたらこうかな？
-- Julia だと `a[:end-1]` みたいな書き方をするよね
#eval (a[:a.size-1] : Array Nat)

#eval (a[:a.size-2] : Array Nat)

-- Lean で配列から、subarray を取ってくるときに、
-- Array.toSubarray が呼ばれている。しかし、この関数の定義域が Nat になってるので、
-- Int で範囲アクセスできない。

-- julia 式のを定義するのもちょっと難しい？
--
-- syntax (name := rangeAccess) ident "[" ":" "end" term "]" : term
-- macro_rules
--   | `($a[ : end $st]) => `(a[: a.size $st])


end Chapter134


/- ### 1.3.5 ディクショナリ -/
namespace Chapter135

open Lean

-- 文字列をキーとしてNatを値とする辞書の型
#check HashMap String Nat

-- リストからHashMapを作ることができる
def me := HashMap.ofList [("height", 180)]

-- 要素にアクセスすることができるが，
-- 当然返り値が Option に包まれている．
#guard me["height"] = some 180

-- ビックリマークをつけても何も起こらない（ふしぎ）
#eval me["height"]!

-- Option に包まれた値を取り出す関数
-- none だった場合は Inhabited.default を使う
#check Option.get!

-- これをすると Option の値を取り出せる
#guard me["height"].get! = 180

-- 新しい要素を追加する
def me' := me.insert "weight" 70

-- 普通に #eval に渡すことはできない．
/--
error: expression
  me'
has type
  HashMap String Nat
but instance
  MetaEval (HashMap String Nat)
failed to be synthesized, this instance instructs Lean on how to display the resulting value, recall that any type implementing the `Repr` class also implements the `Lean.MetaEval` class
-/
#guard_msgs (error) in #eval me'

-- toList をかませば表示できる
-- ほかの方法もありそう
#eval me'.toList

end Chapter135


/- ### 1.3.6 ブーリアン -/
namespace Chapter136

-- Lean ではBooleanは小文字
def hungry := true
def sleepy := false

#check hungry

-- 否定
#guard not hungry = false

-- これも否定
#guard ! hungry = false

-- このあたりはPythonと同じ
#check and
#check or

-- 論理積
-- ∧ はProp用で，&&はBool用
#eval hungry ∧ sleepy
#eval hungry && sleepy

-- 中値記法ではない
#check_failure hungry and sleepy
#check_failure hungry or sleepy

-- 論理和
#eval hungry ∨ sleepy
#eval hungry || sleepy

end Chapter136

/- ### 1.3.7 if 文 -/
namespace Chapter137

-- Lean にも if 文が一応ある

-- これは Prop
def hungry := true

def main (cond : Bool) : IO Unit :=
  if cond then
    IO.println "I'm hungry"
  else do
    IO.println "I'm not hungry"
    IO.println "I'm sleepy"

#eval main hungry

#eval main (! hungry)

end Chapter137


/- ### 1.3.8 for文 -/
namespace Chapter138

-- Lean にもfor 文はあって，do構文の一部として提供されています
-- Python の構文とよく似ています

def main : IO Unit :=
  for i in [1:4] do
    IO.println s!"{i}"

#eval main

end Chapter138


/- ### 1.3.9 関数 -/
namespace Chapter139

def hello := IO.println "Hello, world!"

#eval hello

-- 文字列の連結は ++ で行う
def hello' (name : String) : IO Unit :=
  IO.println <| "Hello, " ++ name ++ "!"

#eval hello' "cat"

end Chapter139
