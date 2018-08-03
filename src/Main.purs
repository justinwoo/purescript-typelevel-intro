module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Prim.TypeError as TE
import Type.Prelude as TP

data Fruit = Apple | Banana | Cherry

isApple :: Fruit -> Boolean
isApple x = case x of
  Apple -> true
  Banana -> false
  _ -> false

foreign import kind Color
foreign import data Red :: Color
foreign import data Blue :: Color
foreign import data Green :: Color

-- Color :: Color -> Type
data ColorProxy (color :: Color) = ColorProxy

redProxy :: ColorProxy Red
redProxy = ColorProxy

class IsRed (color :: Color) (result :: TP.Boolean) | color -> result

instance isRedRed :: IsRed Red TP.True
-- instance isRedBlue :: IsRed Blue TP.False
-- instance isRedGreen :: IsRed Green TP.False
else instance isRedElse :: IsRed a TP.False

class Succ (curr :: Symbol) (next :: Symbol) | curr -> next, next -> curr

instance succ01 :: Succ "zero" "one"
else instance succ12 :: Succ "one" "two"
else instance succ23 :: Succ "two" "three"
else instance succ34 :: Succ "three" "four"
else instance succ45 :: Succ "four" "five"
else instance succ56 :: Succ "five" "six"
else instance succ67 :: Succ "six" "seven"
else instance succ78 :: Succ "seven" "eight"
else instance succ89 :: Succ "eight" "nine"
else instance succ90 :: Succ "nine" "ten"
else instance succNo ::
  ( TE.Fail (TE.Text "i don't know how to count any bigger than ten or less than zero")
  ) => Succ i o

class Add (l :: Symbol) (r :: Symbol) (o :: Symbol) | l -> r o
instance zeroAdd :: Add "zero" r r
else instance succAdd ::
  ( Succ l' l
  , Succ r r'
  , Add l' r' o
  ) => Add l r o

add
  :: forall l r o
   . Add l r o
  => TP.SProxy l
  -> TP.SProxy r
  -> TP.SProxy o
add _ _ = TP.SProxy

resultOfAdd :: TP.SProxy "five"
resultOfAdd = add (TP.SProxy :: TP.SProxy "three") (TP.SProxy :: TP.SProxy "two")

class Sub (l :: Symbol) (r :: Symbol) (o :: Symbol) | r -> l o
instance zeroSub :: Sub l "zero" l
else instance succSub ::
  ( Succ l' l
  , Succ r' r
  , Sub l' r' o
  ) => Sub l r o

subtract
  :: forall l r o
   . Sub l r o
  => TP.SProxy l
  -> TP.SProxy r
  -> TP.SProxy o
subtract _ _ = TP.SProxy

resultOfSubtract :: TP.SProxy "three"
resultOfSubtract = subtract (TP.SProxy :: TP.SProxy "five") (TP.SProxy :: TP.SProxy "two")

main :: Effect Unit
main = do
  log "Hello sailor!"
