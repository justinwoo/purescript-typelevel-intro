---
title: "Type classes: pattern matching for types"
author: Justin Woo
date: October 18 2018
theme: Madrid
colortheme: dolphin
fontfamily: noto-sans
header-includes:
- \usepackage{cmbright}
fontsize: 10pt
---

## What is PureScript?

* A language similar to Haskell

* Users program using types and values

* Values match the types, usage of values type-checked

* Users can statically derive values via types

## What are data types?

```hs
  data Maybe a = Just a | Nothing
```

Key parts:

* `data`: begins the data type declaration

* `Maybe`: the **name** of our data type

* `a`: a parameter of our data type

* `Just`: A **constructor** of `Maybe`

* `|`: Separates constructors in our type

For a given data type, there are one or more constructors.

## What are constructors?

Constructors are values that are or can be used to create values of our data type:

```hs
  data Maybe a = Just a | Nothing

  mkJust :: forall a. a -> Maybe a
  mkJust = Just

  mkNothing :: forall a. Maybe a
  mkNothing = Nothing
```

## What is pattern matching?

We've seen how to construct values of data types, but how do we then match on constructors of data types?

Using case expressions:

```hs
  isJust :: forall a. Maybe a -> Boolean
  isJust m = case m of
    Just x -> true
    Nothing -> false
```

At definition sites:

```hs
  isJust' :: forall a. Maybe a -> Boolean
  isJust' (Just x) = true
  isJust' Nothing = false
```

## Recap: data types

* Users can define data types

* The most commonly useful data types have multiple constructors*

* Sum members can be pattern matched for

*i.e. they are Sum types

## To the type level

Four things we need to learn to work with the type level:

1. What are type classes?
2. What are instances?
3. What are kinds?
4. What are proxies?

## 1. What are type classes?

Type classes are a way to match on types based on kinds, allowing for defining methods for types which have an instance of a given class

```hs
  class Show a where
    show :: a -> String
```

## 2. What are instances?

An instance is a definition for a class for a matched type by an instance head

```hs
  instance showString :: Show String where
    show s = s

  myString :: String
  myString = show "value"
```

## 3. What are kinds?

Kinds are a "type of types", of which the most common is `Type` and has associated runtime values.

```hs
  foreign import data ForeignData :: Type

  foreign import kind MaybeTy
  foreign import data JustTy :: Type -> MaybeTy
  foreign import data NothingTy :: MaybeTy
```

## 4. What are Proxies?

A proxy is a data type that has a parameter of a given kind, where the parameter is not exposed as a value.

```hs
  -- no kind signature: inferred as `Type`
  data Proxy ty = Proxy
  data Proxy2 (ty :: Type) = Proxy2

  data MaybeTyProxy (mt :: MaybeTy) = MaybeTyProxy

  justIntProxy :: MaybeTyProxy (JustTy Int)
  justIntProxy = MaybeTyProxy
```

## How do these come together?

With these pieces, now we can see the correspondence:

\begin{center}
  \includegraphics[width=0.8\textwidth]{./diagram.jpg}
\end{center}

values : Types :: types : kinds

case of : class

branch : instance

## Example

Now let's try pattern matching on the `MaybeTy`:

```hs
  class IsJustTy (mt :: MaybeTy) where
    isJustTy :: MaybeTyProxy mt -> Boolean

  instance justTyIsJustTy :: IsJustTy (JustTy a) where
    isJustTy _ = true

  instance nothingTyIsJustTy :: IsJustTy NothingTy where
    isJustTy _ = false

  result :: Boolean
  result = isJustTy justIntProxy
```

## What if we wanted to return the result in the type level?

We can use multi-param type classes, along with functional dependencies ("fundeps"):

```hs
  class IsJustTy (mt :: MaybeTy) (result :: Type.Data.Boolean)
    | mt -> result

  instance justTypeIsJustTy ::
    IsJustTy (JustTy a) Type.Data.True

  instance nothingTypeIsJustTy ::
    IsJustTy NothingTy Type.Data.False
```

The parameter `mt` determines `result`, i.e. instances can be matched for by `mt` alone.

-----

Example usage in function definition:

```hs
  getIsJustTy ::
    forall mt b.
    IsJustTy mt b =>
    MaybeTyProxy mt -> Type.Data.BProxy b
  getIsJustTy _ = Type.Data.BProxy

  result' :: Type.Data.BProxy Type.Data.True
  result' = getIsJustTy (MaybeTyProxy :: MaybeTyProxy (JustTy Int))
```

## Some important notes

### Kinds are not closed, unlike sum types
If anything, the parallel is closer with an open polymorphic variant.

### Instances are "partial"
Compilation fails when instances cannot be found with `No type class instance was found for _`.

### There are some limited ways of doing wildcard matches for type classes
e.g. using instance chains (groups) in PureScript 0.12 to constrain instances to a module in a continuous group.

## So why do we care about Type Classes?

### We should be able to derive information and/or values from static information.

Computers should do work for us, not the other way around.

### Runtime checks for static information leave much to be desired

Leaving calculations to the runtime that should be verified in compile time leaves us with dead code paths at best. And really, is there actually a difference between an incorrect program and crashes and an incorrect program that "never crashes" but always ends up in an invalid path?

### Why shouldn't we actually program using type information?

Why should we use types only to check some usages of values rather than reduce error-prone work and more powerfully extract values from static information?

## Example: JSON decoding

Common error cases when manually writing code that should be derived from the type information:

```hs
  type DecodeResult a = Either DecodeError a

  type MyRecord = { apple :: String, banana :: Int }

  readMyRecord1 :: Foreign -> DecodeResult MyRecord
  readMyRecord1 f = do
    apple <- readString =<< readProperty "apple"
    banana <- readInt =<< readProperty "apple"
    pure { apple, banana }
```

-----

```hs
  readMyRecord2 :: Foreign -> DecodeResult MyRecord
  readMyRecord2 f = do
    apple <- readString =<< readProperty "apple" f
    banana <- readString =<< readProperty "banana" f
    pure { apple, banana }

  type OtherRecord = { cherry :: String, durian :: String }

  mkOtherRecord :: String -> String -> OtherRecord
  mkOtherRecord -- ...

  readOtherRecord :: Foreign -> DecodeResult OtherRecord
  readOtherRecord f =
    mkOtherRecord
    <$> readString =<< readProperty "durian" f
    <*> readString =<< readProperty "cherry" f
```

-----

If all you want to do is read the type at the given field with the correct label and type, why even deal with this?

Use Simple-JSON [github.com/justinwoo/purescript-simple-json](https://github.com/justinwoo/purescript-simple-json)

```hs
  type MyJSON =
    { apple :: String
    , banana :: Int
    , cherry :: Maybe Boolean
    }

  decodeToMyJSON :: String -> SimpleJSON.E MyJSON
  decodeToMyJSON = SimpleJSON.readJSON
```

This is also flexible for inferred field type changing, field addition/removal, etc.

## Example 2: Parse parameters out of a static type-level string

If we have a static parameterized SQLite query, we should be able to build up the request query type:

```hs
  getEm :: forall a b.
    AllowedParamType a => AllowedParamType b =>

    DBConnection
    -> { "$name" :: a, "$count" :: b }
    -> Aff Foreign

  getEm db = J.queryDB db $ SProxy :: SProxy """
      select name, count from mytable
      where name = $name and count = $count
    """
```

-----

And we can:

```hs
  queryDB ::
    forall query params.
    IsSymbol query => ExtractParams query params =>

    SQLite3.DBConnection
    -> SProxy query
    -> { | params }
    -> Aff Foreign
```

See more: [speakerdeck.com/justinwoo/superior-string-spaghetti-with-purescript](https://speakerdeck.com/justinwoo/superior-string-spaghetti-with-purescript)

## Conclusion

* There is a parallel between pattern matching of values of a Type and type classes of types of a kind.

* The parallel is not a perfect correspondence, which also sometimes helps us more easily use type information to derive routines and values from types.

* We can avoid error-prone (non-)boilerplate and use type classes to allow us to take advantage of dependent-typed techniques with PureScript.

* You don't have to rely on code generation or the whims of thoughtleaders to make things work the way you see fit!
