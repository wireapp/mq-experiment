{-# LANGUAGE OverloadedStrings, RecordWildCards #-}

module Main where

import           Control.Concurrent
import           Control.Monad
import qualified Network.Mosquitto as M
import           Network.Mosquitto.Internal.Types

import           Control.Applicative
import           Options

data MainOptions = MainOptions
    { caCert    :: String
    , userCert  :: String
    , userKey   :: String
    , server    :: String
    , serverName :: String
    , port      :: Int
    , keepAlive :: Int
    }

instance Options MainOptions where
    defineOptions = pure MainOptions
        <*> simpleOption "ca" "rootCA.pem"
            "server's CA"
        <*> simpleOption "cert" "cert.pem"
            "client cert"
        <*> simpleOption "key" "cert.key"
            "client key"
        <*> simpleOption "server" "localhost"
            "server"
        <*> simpleOption "name" "server-demo"
            "server's name"
        <*> simpleOption "port" 1883
            "server's port"
        <*> simpleOption "keep-alive" 1200
            "server's port"

main :: IO ()
main = runCommand $ \MainOptions{..} args -> M.withMosquittoLibrary $ do
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
