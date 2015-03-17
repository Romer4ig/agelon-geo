
module Web where 

import Servant
import qualified Data.Text as T
import qualified Data.List as L
import Control.Monad.IO.Class (liftIO)
import Data.IORef
import GeoService.Model.City
import Api
import Common
import GeoService.DB.Rethink as DB


server :: App -> Server Api
server app = searchCountry :<|> serachCountryShort :<|> getAllCites :<|> cityAutocomplete :<|> addCity

  where searchCountry name = do
            listCity <- liftIO $ readIORef (listCity app)  
            let list = filter (\x -> (country x) == (T.unpack name)) listCity 
            return list

        serachCountryShort name = do
            listCity <- liftIO $ readIORef (listCity app)  
            let list = filter (\x -> (country x) == (T.unpack name)) listCity 
                list' = map (\x -> T.pack (cityId x)) list
            return list' 

        getAllCites = do 
            listCity <- liftIO $ readIORef (listCity app)
            return listCity

        cityAutocomplete name limit = do
            listCity <- liftIO $ readIORef (listCity app)  
            let list = filter (\x -> any (\y -> L.isInfixOf (T.unpack name) (content y)) (cityTranslations x)) listCity             
            return (take (maybe 10 (min 20) limit) list) 

        addCity body =  do
            liftIO $ DB.add app body
            return (cityId body)
