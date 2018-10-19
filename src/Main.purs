module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Type.Data.Boolean as Type.Data

data Maybe a = Just a | Nothing

mkJust :: forall a. a -> Maybe a
mkJust = Just

mkNothing :: forall a. Maybe a
mkNothing = Nothing

isJust :: forall a. Maybe a -> Boolean
isJust m = case m of
  Just x -> true
  Nothing -> false

isJust' :: forall a. Maybe a -> Boolean
isJust' (Just x) = true
isJust' Nothing = false

class Show a where
  show :: a -> String

instance showString :: Show String where
  show s = s

myString :: String
myString = show "value"

foreign import data ForeignData :: Type

foreign import kind MaybeTy
foreign import data JustTy :: Type -> MaybeTy
foreign import data NothingTy :: MaybeTy

data Proxy ty = Proxy
data Proxy2 (ty :: Type) = Proxy2

data MaybeTyProxy (mt :: MaybeTy) = MaybeTyProxy

justIntProxy :: MaybeTyProxy (JustTy Int)
justIntProxy = MaybeTyProxy

class IsJustTyBoolean (mt :: MaybeTy) where
  isJustTyBoolean :: MaybeTyProxy mt -> Boolean

instance justTyIsJustTy :: IsJustTyBoolean (JustTy a) where
  isJustTyBoolean _ = true

instance nothingTyIsJustTy :: IsJustTyBoolean NothingTy where
  isJustTyBoolean _ = false

result :: Boolean
result = isJustTyBoolean justIntProxy

class IsJustTy (mt :: MaybeTy) (result :: Type.Data.Boolean)
  | mt -> result

instance justTypeIsJustTy ::
  IsJustTy (JustTy a) Type.Data.True

instance nothingTypeIsJustTy ::
  IsJustTy NothingTy Type.Data.False

getIsJustTy ::
  forall mt b.
  IsJustTy mt b =>
  MaybeTyProxy mt -> Type.Data.BProxy b
getIsJustTy _ = Type.Data.BProxy

result' :: Type.Data.BProxy Type.Data.True
result' = getIsJustTy (MaybeTyProxy :: MaybeTyProxy (JustTy Int))

main :: Effect Unit
main = do
  log "Hello sailor!"
