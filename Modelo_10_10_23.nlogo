globals [d_l ing_l  pob_l price_l ]

breed [homes hom]        ; Define el tipo de agente "ciudadano-rico"
breed [real_estates real_estate]             ; Define el tipo de agente "inmobiliaria"
breed [government Governor]                    ; Define el tipo de agente "government"
breed [blocks blocka]                    ; Define el tipo de agente "gobierno"

homes-own [
  income
  education
  utility_function
  house
  preference
  raw-income ; borrarla
]
real_estates-own[
location
profit
demand

]

patches-own[
price
kind
beds
area
hdi
house_0 ; houses withou home
house_1 ; houses with home
houses  ; number of  houses
d       ; distance tu center
income_mean ; mean of incomen of homes in the patch
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  BEGINNING OF THE SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup
  clear-all                    ; Limpia la interfaz y la memoria

;   Configuración global
;  set tamano-ciudad 30         ; Tamaño de la ciudad en parches
;  set tamano-house-pobre 1  ; Tamaño de la house para ciudadanos pobres en parches
;  set tamano-house-rica 2   ; Tamaño de la house para ciudadanos ricos en parches
;
  ; Configuración de los parches
  ask patches
  [;; Create de hdi value for blocks
    set d distance-to-center pxcor pycor
    set hdi (1 - (d / max-distance-world))
   ;;; Asing the type of house in the blocks, in t=0  there hare two types of block 1 and 0 type = 1  All house are rich, tyoe = 0 all de house are poor
  ifelse random-float 1.0 < hdi * 0.95 + 0.1 ; Esto da un 20% de no correspondencia
  [set kind 1]  [set kind 0]


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; houses por manzana

    ; Asigna un valor aleatorio con distribución normal a la primitiva patch.
    set houses round(random-normal 7 2)

    ; Genera un percentage aleatorio entre 15 y 25.
    let percentage_0 random-float 10 + 15 ; esto generará un número entre 15 y 25.

    ; Calcula cuánto de 'casas' va a 'casas_0' basado en el percentage.
    set house_0 round(houses * (percentage_0 / 100))

    ; El resto de 'casas' va a 'casas_1'.
    set house_1 houses - house_0

   ]
  ask patches[sprout-homes  house_1 [
      set shape "person"  ; Asegúrate de que "persona" es el nombre de la forma en tu Shapefile.
      set color blue      ; O cualquier otro color de tu elección.
      let alpha 0.5 ; solo un valor inicial, ajusta según necesidad
      let beta 2  ; solo un valor inicial, ajusta según necesidad
      set raw-income random-gamma alpha beta
      ;set income raw-income ;(rescale raw-income 0 max [income] of turtles 2000 500000)
      set income rescale raw-income 0 max [raw-income] of turtles 3000 500000
      reassign-house
    ]
  ]
   ;ask patches with [kind = 1] [set pcolor blue]
   ;print max [income] of homes
   print word "el máximo de la funcion gamma es: "  max [raw-income] of turtles
   print word "el ingreso máximo es: "  max [income] of turtles
  print word "el ingreso promedio es: " mean [income] of turtles
  print word "el indice de Gini es: "  calculate-gini
  print word "la distancia más lejanna es: " max[d] of patches

  ask patches [
  let n count turtles-here
 set house_1  n
  set pcolor scale-color green house_1    0 10
  average-income
  house-price]
  income-education
   g_income
   g_population
  g_price
 ;
reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; SETUP PROCEDURES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to reassign-house
  let max-distance max [d] of patches
let segment-distance max-distance / 4
  ; Define los límites de cada anillo
; Define los límites de cada anillo
let ring1 list 0 segment-distance
let ring2 list segment-distance (2 * segment-distance)
let ring3 list (2 * segment-distance) (3 * segment-distance)
let ring4 list (3 * segment-distance) max-distance
let rings (list ring1 ring2 ring3 ring4)
  ifelse income < 50000 [
                                                                       move-to one-of patches with [d >= first ring4 and d < last ring4]
                           ] [
                         ifelse (income >= 50000 and income < 100000) [move-to one-of patches with [d >= first ring3 and d < last ring3]
                          ] [
                         ifelse income >= 100000 and income < 200000 [move-to one-of patches with [d >= first ring2 and d < last ring2]
                          ]  [
                                                                         move-to one-of patches with [d >= first ring1 and d < last ring1]
      ]
     ]
    ]
end

to house-price

ifelse income_mean <= 5000 [
  set price (100000 + random 200000) ; aleatorio entre 100 mil y 300 mil
] [
  ifelse income_mean > 5000 and income_mean <= 10000 [
    set price (300000 + random 400000) ; aleatorio entre 300 mil y 700 mil
  ] [
    ifelse income_mean > 10000 and income_mean <= 15000 [
      set price (700000 + random 300000) ; aleatorio entre 700 mil y 1 millon
    ] [
      ifelse income_mean > 15000 and income_mean <= 20000 [
        set price (1000000 + random 500000) ; aleatorio entre 1 millon y 1.5 millones
      ] [
        ifelse income_mean > 20000 and income_mean <= 30000 [
          set price (1500000 + random 700000) ; aleatorio entre 1.5 millones y 2.2 millones
        ] [
          ifelse income_mean > 30000 and income_mean <= 50000 [
            set price (2200000 + random 500000) ; aleatorio entre 2.2 millones y 2.7 millones
          ] [
            ifelse income_mean > 50000 and income_mean <= 100000 [
              set price (2700000 + random 700000) ; aleatorio entre 2.7 millones y 3.4 millones
            ] [
              ; Para income mayores a 100,000
              set price (5000000 + random-normal 0 1000000)
            ]
          ]
        ]
      ]
    ]
  ]
]
end
to income-education
  ;;;;;;; We obtain de medean of home's income

  let MedianIncome median-income
  ask homes[
  if income <= 0.5 *  MedianIncome [ set education ceiling ( random-float 6)]
  if income > 0.5 *  MedianIncome and income  <=  MedianIncome [set education ceiling (6 + random-float 3)]
  if income > MedianIncome and income <= (3 / 2) * MedianIncome [set education ceiling (9 + random-float 3)]
  if income > (3 / 2) * MedianIncome and income <= 2 * MedianIncome [set education ceiling (12 + random-float 4)]
  if income >  2 * MedianIncome [set education ceiling (16 + random-float 6)]
  ]
end
to-report median-income
  let list-income [income] of homes
  let list-sort sort list-income
  let middle length list-sort / 2

  ifelse length list-sort mod 2 = 0 [
    report (item (middle - 1) list-sort + item middle list-sort) / 2
  ] [
    report item middle list-sort
  ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  END OF THE SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  BEGINNING OF THE GO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to GO
;  live the city ;; The homers walk around the city for leisure.
;  choose-house ;; The new home in the city choose som plaece to call home.
;  mortgage     ;; Report the number of tickets and finish de mortgae.
;  migration    ;; The homers decide change the house that generate a mayor satisfaction, maybe some homes leave the city  for different razons.
;  demand       ;; Thea real state review the zones with most demand to built more houses.
;  hoisung-price ;; Update de housing price considering suppy and demand.
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; SETUP PROCEDURES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to choose-house
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  END OF THE GO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; GLOBAL PROCEDURES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to average-income
; obtén una lista de income de los homes en este parche
      let list-income [income] of turtles-here with [ breed = homes ]
      set income_mean 0
      if not empty? list-income  [ ; asegúrate de que hay al menos un home en el patch
      set income_mean (mean list-income)]
      ;set pcolor scale-color green hdi 0 1
end

to color-poblacion
  ask patches [

      set pcolor scale-color green house_1 0 10]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  REPORTS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



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


to-report calculate-gini
  let incomes sort [income] of turtles ; ordenar income de menor a mayor
  let n count turtles
  let total-ing sum incomes
  let lorentz-sum 0

  ;; Construir y sumar áreas bajo la curva de Lorenz
  let running-total 0
  foreach incomes [
    ing ->
    set running-total running-total + ing
    set lorentz-sum lorentz-sum + (running-total / total-ing)
  ]

  ;; Calcular el índice de Gini
  let gini 1 - (2 / n) * lorentz-sum
  report gini
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  PLOTS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to g_income
  let d_m max [d] of patches
  let di []
  let r 10
  let n r - 1
  set di n-values r [ i ->  lput ((( i   ) * d_m )/( n  )) di ]
 ; print di
 ; print item 0 item 0 di
  set d_l   di
  let s 9
  set ing_l []
  set ing_l n-values s [i -> lput (mean [income_mean] of patches with [(d >= item 0 item i d_l) and (d < item 0 item (i + 1) d_l) ]) ing_l]
  set d_l but-first di
  end

to g_population
  let d_m max [d] of patches
  let di []
  let r 16
  let n r - 1
  set di n-values r [ i ->  lput ((( i   ) * d_m )/( n  )) di ]
 ; print di
 ; print item 0 item 0 di
  set d_l   di
  let s 15
  set pob_l []
  set pob_l n-values s [i -> lput (sum [house_1] of patches with [(d >= item 0 item i d_l) and (d < item 0 item (i + 1) d_l) ]) pob_l]
  set d_l but-first di
  end

to g_price
  let d_m max [d] of patches
  let di []
  let r 16
  let n r - 1
  set di n-values r [ i ->  lput ((( i   ) * d_m )/( n  )) di ]
 ; print di
 ; print item 0 item 0 di
  set d_l   di
  let s 15
  set price_l []
  set price_l n-values s [i -> lput (mean[price] of patches with [(d >= item 0 item i d_l) and (d < item 0 item (i + 1) d_l) ]) price_l]
  set d_l but-first di
  end



@#$#@#$#@
GRAPHICS-WINDOW
148
10
585
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
24
14
134
47
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
711
23
911
173
Income Distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range (min [income] of homes)  (max [income] of homes)\nset-plot-y-range 0 count homes\nset-histogram-num-bars 20" "set-plot-x-range (min [income] of homes)  (max [income] of homes)\nset-plot-y-range 0 count homes\nset-histogram-num-bars 20"
PENS
"default" 1.0 2 -16777216 true "" "histogram [income] of homes"

PLOT
930
25
1130
175
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
"Lorenz Curve" 1.0 0 -7500403 true "let incomes sort [income] of turtles\nlet total-income sum incomes\nlet running-total 0\nlet population-fraction 0\nlet n count turtles\n\nset-current-plot-pen \"Lorenz Curve\"\n; Comienza en el origen\nplotxy 0 0 \n\nforeach incomes [\n  ing -> \n  set running-total running-total + ing\n  set population-fraction population-fraction + (1 / n)\n  plotxy population-fraction (running-total / total-income)\n]" "let incomes sort [income] of turtles\nlet total-income sum incomes\nlet running-total 0\nlet population-fraction 0\nlet n count turtles\n\nset-current-plot-pen \"Lorenz Curve\"\n; Comienza en el origen\nplotxy 0 0 \n\nforeach incomes [\n  ing -> \n  set running-total running-total + ing\n  set population-fraction population-fraction + (1 / n)\n  plotxy population-fraction (running-total / total-income)\n]"
"Equality Line" 1.0 0 -2674135 true "\nset-current-plot-pen \"Equality Line\"\nplotxy 0 0\nplotxy 1 1" ""

MONITOR
600
29
670
74
Gini Index
calculate-gini
17
1
11

PLOT
711
208
911
358
Ingreso Promedio
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.5 1 -16777216 true "" "plot-pen-reset\nlet n 9\nlet li 0\n set li  n-values n [ i -> i  ]\nforeach li [[t] -> plotxy item 0 item t d_l item 0 item t ing_l]"

PLOT
935
209
1135
359
Densidad Poblacional
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "plot-pen-reset\nlet n 15\nlet li 0\n set li  n-values n [ i -> i  ]\nforeach li [[t] -> plotxy item 0 item t d_l item 0 item t pob_l]"

PLOT
1163
214
1363
364
Price
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "plot-pen-reset\nlet n 15\nlet li 0\n set li  n-values n [ i -> i  ]\nforeach li [[t] -> plotxy item 0 item t d_l item 0 item t price_l]"

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
