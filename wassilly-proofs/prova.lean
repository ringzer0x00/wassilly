inductive Palindrome : List α → Prop where
  | nil      : Palindrome []
  | single   : (a : α) → Palindrome [a]
  | sandwich : (a : α) → Palindrome as → Palindrome ([a] ++ as ++ [a])
