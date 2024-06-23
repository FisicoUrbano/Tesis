globals [ max_densi d1 d2 d3 ing1 ing2 ing3 d_max max_income]


breed [hogares hogar]        ; Define el tipo de agente "ciudadano-rico"
breed [inmobiliarias inmobiliaria]             ; Define el tipo de agente "inmobiliaria"
breed [gobierno gobernante]                    ; Define el tipo de agente "gobierno"
breed [manzanas manzana]                    ; Define el tipo de agente "gobierno"

hogares-own [
  raw-income
  ingreso
  ;educacion

  vivienda
  preferencias
]
inmobiliarias-own[
  localizacion
  ganancia
  demanda
  precios
]

patches-own[
  densidad
  precio
  kind
  cuartos
  superficie
  idh
  house_0 ; houses without home
  house_1 ; houses with home
  houses  ; number of  houses
  d       ; distance tu center
  utilidad_d
  utilidad_den
  utilidad_idh
]


to setup
  clear-all                    ; Limpia la interfaz y la memoria

;   Configuración global
;  set tamano-ciudad 30         ; Tamaño de la ciudad en parches
;  set tamano-vivienda-pobre 1  ; Tamaño de la vivienda para ciudadanos pobres en parches
;  set tamano-vivienda-rica 2   ; Tamaño de la vivienda para ciudadanos ricos en parches
;
  ; Configuración de los parches
  ask patches
  [;; Create de idh value for blocks
    set d distance-to-center pxcor pycor
    set idh (1 - (d / max-distance-world))

     set pcolor scale-color green house_1    0 10



    ]


  ask patch 0 0 [
    let n_patches count patches
    let n_hogares 10 * n_patches
    sprout-hogares n_hogares [
      set shape "person"  ; Asegúrate de que "persona" es el nombre de la forma en tu Shapefile.
      set color blue      ; O cualquier otro color de tu elección.
      let alpha 1 ; solo un valor inicial, ajusta según necesidad
      let beta 0.01  ; solo un valor inicial, ajusta según necesidad
      set raw-income (random-gamma alpha beta)


    ]
  ]


    ;set pcolor scale-color green idh 0 1

    ;set pcolor [255 0 0]


  ask hogares[
    let in-min min [raw-income] of hogares
    let in-max max [raw-income] of hogares
    let out-min 1000
    let out-max 500000
    set ingreso rescale raw-income in-min in-max out-min out-max


  ]

  acomodar-tortugas
   ;ask patches with [kind = 1] [set pcolor blue]
   ;print max [ingresos] of hogares
  ask patches [ set house_1 count turtles-here
                set house_0 random 10
                set houses house_0 + house_1
                set d_max max [d] of patches
                let distancia_cen d / d_max
                set max_densi (max [houses] of patches)
                let densi  (1.01 - (houses / max_densi))
                let dist   (1.01 - distancia_cen)
                set utilidad_d (densi ^ .3) * (idh ^ .2) * (dist ^ .5)
                set utilidad_den     (densi ^ .5) * (idh ^ .3) * (dist ^ .2)
                set utilidad_idh   (densi ^ .3) * (idh ^ .5) * (dist ^ .2)




    set pcolor scale-color green idh 0 1
  ]


  precio-ingresos-en-patches





  print word "el ingreso mínimo es: "  min [ingreso] of turtles
   print word "el ingreso máximo es: "  max [ingreso] of turtles
  print word "el indice de Gini es: "  calculate-gini


reset-ticks
end

to precio-ingresos-en-patches
  ;;;;;;;;;;;;;;;;; d1 ;;;;;;;;;;;;;;;
  ; Inicializamos una lista vacía para almacenar los ingresos de las turtles en los patches con d = d1
  let lista-ingresos_d1 []
  let ingreso_promedio_d1 0
  set d_max max [d] of patches
  let precio_d1 0
  ; Recorremos todos los patches con d = d1
  ask patches with [d <= d_max / 4] [
    ; Para cada patch, obtenemos las turtles presentes y agregamos sus ingresos a la lista
    ask turtles-here [
      set lista-ingresos_d1 lput ingreso lista-ingresos_d1
    ]
  ]

  ; Calculamos y reportamos el promedio de la lista de ingresos
  ifelse not empty? lista-ingresos_d1 [
    set ingreso_promedio_d1 mean lista-ingresos_d1
  ] [
    set ingreso_promedio_d1 0 ; Si la lista está vacía, reportamos 0
  ]

  ask patches with [d <= d_max / 4]
  [ set pcolor brown
  let precio_1 0.3 * 20 * 12 * ingreso_promedio_d1
  let precio_n1 random-normal (0.5 * precio_1)  (0.3 * precio_1)
  set precio absolute-value precio_n1
  ]

  ;;;;;;;;;;;;;;;;; d2 ;;;;;;;;;;;;;;;

  ; Inicializamos una lista vacía para almacenar los ingresos de las turtles en los patches con d = d1
  let lista-ingresos_d2 []
  let ingreso_promedio_d2 0

  let precio_d2 0
  ; Recorremos todos los patches con d = d1
  ask patches with [(d > d_max / 4) and (d <= d_max / 2)] [
    set pcolor orange
    ; Para cada patch, obtenemos las turtles presentes y agregamos sus ingresos a la lista
    ask turtles-here [
      set lista-ingresos_d2 lput ingreso lista-ingresos_d2
    ]
  ]

  ; Calculamos y reportamos el promedio de la lista de ingresos
  ifelse not empty? lista-ingresos_d2 [
    set ingreso_promedio_d2 mean lista-ingresos_d2
  ] [
    set ingreso_promedio_d2 0 ; Si la lista está vacía, reportamos 0
  ]

  ask patches with [(d > d_max / 4) and (d <= d_max / 2)]
  [
  let precio_2 0.3 * 20 * 12 * ingreso_promedio_d2
  let precio_n2 random-normal (0.3 * precio_2)  (0.3 * precio_2)
  set precio absolute-value precio_n2
  ]

  ;;;;;;;;;;;;;;;;; d3 ;;;;;;;;;;;;;;;

  ; Inicializamos una lista vacía para almacenar los ingresos de las turtles en los patches con d = d1
  let lista-ingresos_d3 []
  let ingreso_promedio_d3 0

  let precio_d3 0
  ; Recorremos todos los patches con d = d1
  ask patches with [(d > d_max / 2) and (d <= (3 / 4) * d_max )] [
    set pcolor gray
    ; Para cada patch, obtenemos las turtles presentes y agregamos sus ingresos a la lista
    ask turtles-here [
      set lista-ingresos_d3 lput ingreso lista-ingresos_d3
    ]
  ]

  ; Calculamos y reportamos el promedio de la lista de ingresos
  ifelse not empty? lista-ingresos_d3 [
    set ingreso_promedio_d3 mean lista-ingresos_d3
  ] [
    set ingreso_promedio_d3 0 ; Si la lista está vacía, reportamos 0
  ]

  ask patches with [(d > d_max / 2) and (d <= (3 / 4) * d_max )]
  [
  let precio_3 0.3 * 10 * 12 * ingreso_promedio_d3
  let precio_n3 random-normal (0.3 * precio_3)  (0.3 * precio_3)
  set precio absolute-value precio_n3
  ]
;;;;;;;;;;;;;;;;; d4 ;;;;;;;;;;;;;;;

  ; Inicializamos una lista vacía para almacenar los ingresos de las turtles en los patches con d = d1
  let lista-ingresos_d4 []
  let ingreso_promedio_d4 0

  let precio_d4 0
  ; Recorremos todos los patches con d = d1
  ask patches with [d >  (3 / 4) * d_max ] [
    set pcolor pink
    ; Para cada patch, obtenemos las turtles presentes y agregamos sus ingresos a la lista
    ask turtles-here [
      set lista-ingresos_d4 lput ingreso lista-ingresos_d4
    ]
  ]

  ; Calculamos y reportamos el promedio de la lista de ingresos
  ifelse not empty? lista-ingresos_d4 [
    set ingreso_promedio_d4 mean lista-ingresos_d4
  ] [
    set ingreso_promedio_d4 0 ; Si la lista está vacía, reportamos 0
  ]

  ask patches with [d >  (3 / 4) * d_max ]
  [
  let precio_4 0.3 * 10 * 12 * ingreso_promedio_d4
  let precio_n4 random-normal (0.2 * precio_4)  (0.2 * precio_4)
  set precio absolute-value precio_n4
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to acomodar-tortugas
  set d_max max [d] of patches
  set d1  0.25 * d_max
  set d2  0.5 * d_max
  set d3  0.75 * d_max
  set max_income max [ingreso] of turtles
  set ing1 0.25 * max_income
  set ing2 0.5 * max_income
  set ing3 0.75 * max_income
  ask turtles with [ ingreso >=  ing3 ] [ move-to one-of patches with [ d <= d1 ]]
  ask turtles with [ (ingreso < ing3) and (ingreso >= ing2)] [ move-to one-of patches with [ (d >  d1)  and (d <= d2) ]]
  ;ask turtles with [ (ingreso < 0.75 * max_income ) and (ingreso >= 0.5 * max_income )] [ move-to one-of patches with [ (d >  0.25 * d_max)  and (d <= 0.5 * d_max) ]]
  ask turtles with [ (ingreso <  ing2 ) and (ingreso >= ing1)] [ move-to one-of patches with [ (d > d2 ) and (d <= d3 )]]
  ask turtles with [ (ingreso <  ing1 )] [ move-to one-of patches with [ (d > d3 )]]
end


;to go
;
;    ask ciudadanos-ricos [
;    let target house-here
;    if target != nobody [
;      face target
;      forward 1
;    ]
;  ]
;
;    ask ciudadanos-pobres [
;    let target house-here
;    if target != nobody [
;      face target
;      forward 1
;    ]
;  ]
;end

;ask turtles [
;    let idh-patch idh-at patch-here ; obtener el valor de "idh" del parche donde se encuentra la casa
;    ifelse idh-patch >= 0.1 and idh-patch <= 0.3 [
;      set precio random 401 + 300 ; asignar un precio aleatorio entre 300 y 700 mil
;    ]
;    [ ifelse idh-patch > 0.3 and idh-patch <= 0.5 [
;        set precio random 701 + 800 ; asignar un precio aleatorio entre 800 mil y 1.5 millones
;      ]
;      [ ifelse idh-patch > 0.5 and idh-patch <= 0.7 [
;          set precio random 901 + 1600 ; asignar un precio aleatorio entre 1.6 y 2.5 millones
;        ]
;        [ ifelse idh-patch > 0.7 [
;            set precio random 4000001 + 3000000 ; asignar un precio aleatorio entre 3 y 7 millones
;          ]
;          [ set precio 0 ; si no se cumple ninguna de las condiciones, el precio se establece en cero ]
;        ]
;      ]
;    ]
;  ]
;


to go


  ;;; 1 satisfacción
          ;;;; So --> OK, NO --> 2 Buscar casa
                                 ;;;;;  ---> 3. seleccionar prospectos --- > 4. analizar viabilidad  ----- > S5. ubastar casa 1--- >>
                                                                                                              ;;;;      6. Me ejigen: Si ---> Me mudo, NO --> 7. Subastar casa 2 en t+1, etc 5 casas, se acaban las prospectas --- > 1. satisfacción.


  ask n-of 10 turtles[
    satisfaccion-distancia
  ]


end


to satisfaccion-distancia
  let distancia 0
   ask patch-here[
    set distancia d
                    ]
  ifelse distancia >= d3
     [buscar-casa-cerca]
     [satisfaccion-vecindario]

end

to satisfaccion-vecindario
  let prom_idh mean [ utilidad_idh ] of patches with [d < d3]
  let prom_den mean [ utilidad_den ] of patches with [d < d3]
  let idh_here 0
  let den_here 0
  let total-global prom_idh + prom_den
  let total-here   idh_here + den_here
  if total-global > total-here [buscar-casa-lujo]

end

to buscar-casa-cerca


end

to buscar-casa-lujo

end
to color-poblacion
  ask patches [

      set pcolor scale-color green house_1 0 10]
end

to utilidad
  let u_d 0
  let u_den 0
  let u_idh 0
  ask patch-here [
    set u_d utilidad_d
    set u_den utilidad_den
    set u_idh utilidad_idh
    ifelse d >= d3 [print "Lejos"] [print "Cerca"]

  ]

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  REPORTS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;to-report house-here
;  report min-one-of casas [distance myself]
;end

to-report max-distance-world
   ; Calcula la distancia desde el punto más extremo (max-pxcor, max-pycor) hasta el centro (0, 0)
  let world-width_r (max-pxcor)
  ;print world-width_r
  let world-height_r (max-pycor)
  ;print world-height_r
  report sqrt (world-width_r ^ 2 + world-height_r ^ 2)
end

to-report distance-to-center[ x y]
  ; Calcula la distancia desde el parche actual al centro (0, 0)
  report sqrt (x ^ 2 + y ^ 2)
end

to-report rescale [value in-min in-max out-min out-max]
  report (out-min + (out-max - out-min) * ((value - in-min) / (in-max - in-min)))
end


to-report calculando-utilidad [x]
  (ifelse x  <= 5000 [ report  1]
         (x > 5000) and (x <= 10000) [report   2 ]
         (x > 10000) and (x <= 20000) [report  3]
         (x > 20000) [report  4])
end

to-report calculate-gini
  let incomes sort [ingreso] of turtles ; ordenar ingresos de menor a mayor
  let n count turtles
  let total-income sum incomes
  let lorentz-sum 0

  ;; Construir y sumar áreas bajo la curva de Lorenz
  let running-total 0
  foreach incomes [
    income ->
    set running-total running-total + income
    set lorentz-sum lorentz-sum + (running-total / total-income)
  ]

  ;; Calcular el índice de Gini
  let gini 1 - (2 / n) * lorentz-sum
  report gini
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  GRÁFICAS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to g_ingresos
  let d_m max [d] of patches
  let di []
  let r 8
  let n r - 1
  set di n-values r [ i ->  lput ((( i   ) * d_m )/( n  )) di ]
 ; print di
 ; print item 0 item 0 di
  let d_l   di
  let s 7
  let ing_l []
  set ing_l n-values s [i -> lput (mean [ingreso] of patches with [(d >= item 0 item i d_l) and (d < item 0 item (i + 1) d_l) ]) ing_l]
  set d_l but-first di
end

to-report absolute-value [number]
  ifelse number >= 0
    [ report number ]
    [ report (- number) ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
37
23
179
56
Iniciando el modelo
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
771
213
1078
432
Income Distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range (min [ingreso] of hogares)  (max [ingreso] of hogares)\nset-plot-y-range 0 count hogares\nset-histogram-num-bars 20" "set-plot-x-range (min [ingreso] of hogares)  (max [ingreso] of hogares)\nset-plot-y-range 0 count hogares\nset-histogram-num-bars 20"
PENS
"default" 1.0 1 -16777216 true "" "histogram [ingreso] of hogares"

PLOT
850
31
1010
151
Lorenz Curve
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"Lorenz Curve" 1.0 0 -7500403 true "let incomes sort [ingreso] of turtles\nlet total-income sum incomes\nlet running-total 0\nlet population-fraction 0\nlet n count turtles\n\nset-current-plot-pen \"Lorenz Curve\"\n; Comienza en el origen\nplotxy 0 0 \n\nforeach incomes [\n  income -> \n  set running-total running-total + income\n  set population-fraction population-fraction + (1 / n)\n  plotxy population-fraction (running-total / total-income)\n]" "let incomes sort [ingreso] of turtles\nlet total-income sum incomes\nlet running-total 0\nlet population-fraction 0\nlet n count turtles\n\nset-current-plot-pen \"Lorenz Curve\"\n; Comienza en el origen\nplotxy 0 0 \n\nforeach incomes [\n  income -> \n  set running-total running-total + income\n  set population-fraction population-fraction + (1 / n)\n  plotxy population-fraction (running-total / total-income)\n]"
"Equality Line" 1.0 0 -2674135 true "\nset-current-plot-pen \"Equality Line\"\nplotxy 0 0\nplotxy 1 1" ""

MONITOR
665
31
735
76
Gini Index
calculate-gini
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
