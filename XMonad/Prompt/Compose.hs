{-# LANGUAGE ForeignFunctionInterface, BlockArguments #-}

module XMonad.Prompt.Compose (
  InputContext,
  withInputContext,
  filterEvent,
  lookupInput,
) where

import Control.Exception (bracket)
import Foreign
import Foreign.C.Types
import Graphics.X11.Xlib
import XMonad.Prelude

type InputContext = Ptr ()

withInputContext :: Display -> Window -> (Maybe InputContext -> IO a) -> IO a
withInputContext d w action = bracket (createInputContext d w) destroy \ic ->
  action if ic == nullPtr then Nothing else Just ic
 where
  destroy :: InputContext -> IO ()
  destroy ic = if ic == nullPtr then pure () else destroyInputContext ic

filterEvent :: XEventPtr -> Window -> IO Bool
filterEvent e w = (/= 0) <$> xFilterEvent e w

lookupInput :: InputContext -> XKeyEventPtr -> IO String
lookupInput ic e = go 64
 where
  go :: Int -> IO String
  go size = allocaBytes size \buffer -> do
    c <- lookupInputString ic e buffer (fi size)
    if c < 0 then go (fi (-c)) else map (chr . fi) <$> peekArray (fi c) buffer

foreign import ccall unsafe "prompt_create_ic"
  createInputContext :: Display -> Window -> IO InputContext

foreign import ccall unsafe "prompt_destroy_ic"
  destroyInputContext :: InputContext -> IO ()

foreign import ccall unsafe "XFilterEvent"
  xFilterEvent :: XEventPtr -> Window -> IO CInt

foreign import ccall unsafe "prompt_lookup_str"
  lookupInputString :: InputContext -> XKeyEventPtr -> Ptr Word8 -> CInt -> IO CInt
