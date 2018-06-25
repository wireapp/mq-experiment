{-# LANGUAGE OverloadedStrings, RecordWildCards #-}

module Main where

import           Control.Concurrent
import           Control.Applicative
import           Control.Monad
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import           Data.Text (Text)

import qualified Network.Mom.Stompl.Client.Queue as S
import qualified Codec.MIME.Type as MIME

import           Options

data MainOptions = MainOptions
    { server    :: String
    , port      :: Int
    , message   :: String
    , receive   :: Bool
    , send      :: Bool
    }

instance Options MainOptions where
    defineOptions = pure MainOptions
        <*> simpleOption "server" "localhost"
            "server"
        <*> simpleOption "port" 61613
            "server's port"
        <*> simpleOption "message" "first"
            "message"
        <*> simpleOption "receive" False
            "only receiving"
        <*> simpleOption "send" False
            "only sending"

main :: IO ()
main =
    runCommand $ \MainOptions{..} args -> do
    S.withConnection server port [S.OAuth "admin" "admin"] [("host", "/")] $ \conn -> do
        reader <- S.newReader conn "TestQ" "/queue/test" [S.OMode S.ClientIndi] [] iconv
        writer <- S.newWriter conn "TestQ" "/queue/test" [S.OWithReceipt, S.OWaitReceipt] [] oconv
        unless receive $ void $ forkIO $ forM_ [1..] $ \i -> do
            S.writeQ writer MIME.nullType [("persistent", "true")]
                (T.pack (message ++ " " ++ show i))
            threadDelay 5000000
        unless send $ void $ forkIO $ forever $ do
            msg <- S.readQ reader
            print (S.msgContent msg)
            case T.takeWhile (/= ' ') (S.msgContent msg) of
                "crash!" -> error "crashing"
                "loop!"  -> threadDelay maxBound
                _        -> S.ack conn msg
            threadDelay 3000000
        forever $ threadDelay maxBound

iconv :: S.InBound Text
iconv _ _ _ = pure . T.decodeUtf8  -- NB. might fail at runtime

oconv :: S.OutBound Text
oconv = pure . T.encodeUtf8

{-  
    m <- M.newMosquitto True serverName (Just ())
    -- M.setTls m caCert userCert userKey
    -- M.setTlsInsecure m True
    M.setUsernamePassword m "admin" "admin"  -- doesn't error out if pass is wrong :/
    
    M.setReconnectDelay m True 2 30

    M.onMessage m print
    M.onLog m $ const putStrLn
    M.onConnect m $ \c -> do
        print c
        M.subscribe m 0 "#"

    M.onDisconnect m print
    M.onSubscribe m $ curry print

    M.connect m server port keepAlive

    forkIO $ forever $ do
        M.publish m True 1 "sometopic" "krendel"
        threadDelay 5000000

    M.loopForever m
    M.destroyMosquitto m
-}
