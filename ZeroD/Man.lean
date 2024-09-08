structure Man : Type where
  name : String

def Man.hello (man : Man) : IO Unit :=
  IO.println s!"Hello {man.name}!"

def Man.goodbye (man : Man) : IO Unit :=
  IO.println s!"Goodbye {man.name}!"

def m := Man.mk "David"

def main : IO UInt32 := do
  m.hello
  m.goodbye
  return 0
