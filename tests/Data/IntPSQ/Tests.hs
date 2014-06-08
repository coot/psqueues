module Data.IntPSQ.Tests
    ( tests
    ) where

import           Prelude hiding (lookup)

import           Test.QuickCheck                      (Property, arbitrary,
                                                       forAll)
import           Test.Framework                       (Test)
import           Test.Framework.Providers.HUnit       (testCase)
import           Test.Framework.Providers.QuickCheck2 (testProperty)
import           Test.HUnit                           (Assertion, assert)

import           Data.IntPSQ.Internal
import           Data.PSQ.Class.Gen

--------------------------------------------------------------------------------
-- Index of tests
--------------------------------------------------------------------------------

tests :: [Test]
tests =
    [ testCase     "hasBadNils"              test_hasBadNils
    , testProperty "valid"                   prop_valid
    , testProperty "insertLargerThanMaxPrio" prop_insertLargerThanMaxPrio
    ]

--------------------------------------------------------------------------------
-- Unit tests
--------------------------------------------------------------------------------

-- 100% test coverage...
test_hasBadNils :: Assertion
test_hasBadNils =
    assert $ hasBadNils (Bin 1 2 'x' 0 Nil Nil)

--------------------------------------------------------------------------------
-- QuickCheck properties
--------------------------------------------------------------------------------

prop_valid :: Property
prop_valid = forAll arbitraryPSQ $ \t ->
    valid (t :: IntPSQ Int Char)

prop_insertLargerThanMaxPrio :: Property
prop_insertLargerThanMaxPrio =
    forAll arbitraryPSQ $ \t ->
    forAll arbitrary    $ \k ->
    forAll arbitrary    $ \x ->
        let maxPriority     = fold' (\_ p _ acc -> max' p acc) Nothing t
            priority        = maybe 3 (+ 1) maxPriority
            t'              = insertLargerThanMaxPrio k priority x t
        in valid (t' :: IntPSQ Int Char) && lookup k t' == Just (priority, x)
  where
    max' x Nothing  = Just x
    max' x (Just y) = Just (max x y)
