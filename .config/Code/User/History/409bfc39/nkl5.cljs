(ns app.core
  (:require
   [app.views :as views]
   [goog.dom :as gdom]
   [goog.object]
   [reagent.dom :as rdom]
   [promesa.core :as p]
   [re-frame.core :as rf]
   [app.events :as events]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; `Core` define o ponto-inicial da aplicação.
;;
;; Usa-se o elemento div, com id `app`, de forma a montar
;; a aplicação compilada de ClojureScript.
;;
;; As principais tecnologias usadas no projeto são:
;; - Re-frame.
;; - Reagent (tranvestimento de React).
;;
;; O `Re-frame` cuida da lógica de como a aplicação deve mudar
;; de estado. Toma-se seis passos. O `banco de dados`, o qua mantem
;; o estado da aplicação em cheque, é inicializado pela função
;; `iniciar-db`.
;;
;; *Essa função inicia um `evento`: inicializar e sincronizar o DB inicial.*
;;
;; A função `inicializar` faz uma call GET, para adquirir os dados da `PC`.
;; Em seguida, tranforma o JSON em um mapa em Clojure. Por fim, inicia o DB
;; com esse mapa e inicia a View, com `montar-view`.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn get-app-element []
  (gdom/getElement "app"))

(defn mount-view
  [view el]
  (rdom/unmount-component-at-node el)
  (rdom/render view el))

(defn iniciar-db
  [db]
  (rf/dispatch-sync [::events/inicializar-db db]))

(defn montar-view
  []
  (let [root-el (get-app-element)]
    (mount-view [views/app] root-el)))

(defn iniciar-aplicacao
  [db error]
  (if (nil? error)
    (do (iniciar-db db)
        (montar-view))
    (js/alert "Erro interno do servidor; tente novamente, ou contacte suporte")))

;;
;; Como inicialmente foi feito o iniciar da aplicação.
(defn ^:dev/after-load inicializar
  []
  (p/-> (p/resolved (js/main))
        (js->clj)
        (p/handle
         (fn [db error]
           (iniciar-aplicacao db error)))))

(defn ^:export main
  []
  (rf/clear-subscription-cache!)
  (inicializar))

(main)
