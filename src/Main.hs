module Main where

import           Control.Lens                   ( (.~)
                                                , (&)
                                                , makeLenses
                                                )
import           Control.Monad.IO.Class         ( liftIO )
import           Miso
import qualified Miso.String                   as MS
import           Language.Javascript.JSaddle.WebKitGTK
                                                ( run )
import           Prelude                        ( IO
                                                , Show
                                                , Eq
                                                , Maybe(..)
                                                , Bool(..)
                                                , ($)
                                                , (.)
                                                , (==)
                                                , (<>)
                                                )

import           OS.Linux.NixOS                 ( nixOsAtom )
import           Types



data Model = Model
  { _editorOrIde :: EditorOrIde,
    _log :: MS.MisoString
  } deriving (Show, Eq)

makeLenses ''Model

main :: IO ()
main = run $ startApp App { .. }
 where
  initialAction = NoOp
  model         = Model Atom ""
  update        = updateModel
  view          = viewModel
  events        = defaultEvents
  subs          = []
  mountPoint    = Nothing

updateModel :: Action -> Model -> Effect Action Model
updateModel NoOp model = noEff model
updateModel (SetChecked editorOrIde_ (Checked True)) model = noEff $ model & editorOrIde .~ editorOrIde_
updateModel (SetChecked _ _) model = noEff model
updateModel (Append appendText) model = noEff model {  _log = _log model <> appendText }
updateModel Install model = effectSub model (liftIO . nixOsAtom) -- TODO log SETUP BEING / END

clickHandler :: action -> Attribute action
clickHandler action =
  onWithOptions (defaultOptions { preventDefault = True }) "click" emptyDecoder
    $ \() -> action

viewModel :: Model -> View Action
viewModel model = form_
  []
  [ link_
    [ rel_ "stylesheet"
    , href_ "https://cdn.jsdelivr.net/npm/bulma@0.8.0/css/bulma.min.css"
    ]
  , h5_ [class_ "title is-5"] [text "Easy Haskell Editor / IDE Setup"]
  , div_
    [class_ "control"]
    [ "Editor / IDE"
    , br_ []
    , label_
      [class_ "radio"]
      [ input_
        [ type_ "radio"
        , name_ "editor"
        , checked_ (_editorOrIde model == Atom)
        , onChecked (SetChecked Atom)
        ]
      , "Atom"
      ]
    , label_
      [class_ "radio"]
      [ input_
        [ type_ "radio"
        , name_ "editor"
        , checked_ (_editorOrIde model == VisualStudioCode)
        , onChecked (SetChecked VisualStudioCode)
        ]
      , "Visual Studio Code"
      ]
    , label_
      [class_ "radio"]
      [ input_
        [ type_ "radio"
        , name_ "editor"
        , checked_ (_editorOrIde model == IntelliJIdeaCommunity)
        , onChecked (SetChecked IntelliJIdeaCommunity)
        , disabled_ True
        ]
      , "IntelliJ IDEA Community"
      ]
    , label_
      [class_ "radio"]
      [ input_
        [ type_ "radio"
        , name_ "editor"
        , checked_ (_editorOrIde model == SublimeText3)
        , onChecked (SetChecked SublimeText3)
        , disabled_ True
        ]
      , "Sublime Text 3"
      ]
    , label_
      [class_ "radio"]
      [ input_
        [ type_ "radio"
        , name_ "editor"
        , checked_ (_editorOrIde model == Leksah)
        , onChecked (SetChecked Leksah)
        , disabled_ True
        ]
      , "Leksah"
      ]
    ]
  , br_ []
  , textarea_ [rows_ "15", cols_ "80", disabled_ True ] [ text $ _log model ]
  , br_ []
  , button_ [clickHandler Install, class_ "button"] [text "Install"]
  ]