extensions [ gis nw sound]
Globals [data centro-dcn dcn  L den-min den-max esc-min esc-max ren-max ren-min cambio-renta precio-casa v* lista-normal world por nt  p_min p_max den_max sincasa d_l
ing_l pob_l pob_r pob_s precio_l n_u mudanzas sol_hogar precio_promedio-1 precio_promedio ingreso_promedio ganancias_promedio tbl d_l0 ing_l0 d_lf ing_lf indice_gentrificacion asequible
pob_r0 pob_rf pob_s0 pob_sf]
breed [centros centro ]
breed[sellers seller]
breed[hogares hogar]
breed[bancos banco]
Breed[banca-publca Infonavit]
Breed[constructoras constructora]
Breed[gobiernos gobierno]

centros-own[id_c dist_max]
patches-own[area id_p id-pc mza-p ageb-p mun-p dom-p viv-p ubicacion-p cen-p tipo-p  pob-p precio-p esc-p area_p desoc-p viv_1dor viv_2masdor viv_sani viv_auto  viv_inter pea esc sinb-p ]

sellers-own[id_s mza_s ageb_s mun_s   area_s periferia ;; del espacio
    ahorro educ  ingresos   v_des v_des-1 v_des-2 vt v_1dor v_2dor v_sani  v_auto v_inter precio p0 l_migrantes n_m p_m pb
  vt_a v_des_a v_propia_a v_ocu_a  v_alquiler_a precio_a n_construc_a ;; de los hogares
  q0 v_propia  v_alquiler v_hipoteca l_hipoteca precio_a tp densidad_s0 densidad_s   v_ocu v_ocu-1 tv v_sinserv  distancia_centro i_m  vecindad vecinos i_v utilidad_s
  utilidad_promedio_s utilidad_r  utilidad_promedio_r vt_r  t_construc buscando transaccion demanda  precio-1 precio-2 demand demand-1 demand-2 vacantes ocupadas
  n_construc transaccion-1 precio_referencia dv t_ocu compra  casa_en_venta ingresos_s prospectos_s vpt vpo vpd cup l_d_vs  hogares_social   tipo_v  v_r v_p t_h
  ingresos_c  costos ganancias  ganancias_totales]   ;; vivienda social
hogares-own[ ingresos_h esc_h ahorro_h alquiler_h distancia_h utilidad_h utilidad_promedio_h prospectos_c prospectos_r i_v_h status pje_alquiler v_actual
  residente direccion clase_social contador_h  th]
gobiernos-own[partido subsidio gasto_compra]
bancos-own [id_b lista-compra solicitud]
constructoras-own[ solicitudes]

to setup
  ca  ;Limpia el escenario
  set den_max 500
  display-sellers ; genera los sellers, uno por manzana, con la info de las viviendas y hogares
 ; show 1
 ;distance-centro
  assign-income
  income-education
  ; ingresos-v ; con la info que los sellers tienen de la vivienda y hogares, se les asigna un ingreso a cada seller.
 ; show 2

 caract-mza ; se genera el indice de manzana, de vecindario y la función de utilidad
 ; show 3
 ;display-viviendas ;
 ;display-desarrolladora
;color-densidad

;  create-hogares 3 [
;    buscar-casa]
;color-poblacion
  color-educacion
 ; show 4
  if save? [save0]
  set precio_promedio precision (mean ([precio] of sellers)) 3
  graphs
  histograma [ingresos] of sellers with [distancia_centro <= 6]

 ; show 5
  set v* min [v_ocu] of sellers
  reset-ticks
  color-ingreso
  ;show 6
  ask sellers with [v_r > v_p and distancia_centro <= 6][ ask patch-here [set pcolor 93]]
  ask sellers with [v_p > v_r and distancia_centro <= 6][ ask patch-here [set pcolor 97]]
  if  viv_asequible?[ set asequible 1]
  graphs
end


to display-sellers
  ask patch 0 0 [sprout-gobiernos 1[ set partido who       ; generamos el Gobierno
  set subsidio 0   set size 0.4 ]]
  ask patch 0 0 [sprout-centros 1[ set id_c who  set size 0.4]] ;generamos el centro de la ciudad
  ask patch 0 0 [sprout-bancos 1[ set id_b who  set size 0.4]]
  ask patch 0 0 [sprout-constructoras 1  [set size 0.4]]
  ask patches with [distance patch 0 0 <= 6]  [sprout-sellers 1                 ;generamos los vendedores dentro de la zona urbana
        [;set precio-centro precio-patch
       ; set mza_s mza-p
       ; set ageb-s ageb-p
       ; set mun_s mun-p
        set id_s [who] of self
     ;   set area_s (1 + random 10)
         set area_s 1
        ;set ubicacion-s ubicacion-p
        set vt  (1 + random viv_max)

        set q0 vt
      if q0 = 0   [show q0]
        ;set pob   pob-p
       assign-income
        set v_des ceiling ((random-float 1) * vt)
        set v_1dor ceiling ((random-float 1) * vt)
        set v_2dor ceiling ((random-float 1) * vt)
        set v_sani ceiling ((random-float 1) * vt)
        set v_auto ceiling ((random-float 1) * vt)
        set v_inter ceiling ((random-float 1) * vt)
        set v_des-1 v_des
        set v_des-2 v_des
        set v_ocu (vt -  v_des)
        set v_ocu-1 v_ocu
        set v_sinserv ceiling ((random-float 1) * vt)
        set l_migrantes []
        set transaccion 0
        set compra 0
        set vpt 0
        set vpo 0
        set vpd 0
        set cup 0
        set vt_a 0
        set v_des_a 0
        set v_propia_a 0
        set v_ocu_a 0
        set v_alquiler_a 0
        set l_d_vs []
        set l_hipoteca []
                                                                ;; DENSIDAD
        ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]

        set densidad_s0 densidad_s
                                                                  ;;; Casa propia o de alquiler ;;;;
;      prob-alquiler
;      let z  ((0.51 *  viv_auto) + ( esc * 0.1) + ( viv_1dor * -0.38) + ( viv_2masdor * -0.38)  ) ;; calcular Z-normal
;      let zz precision z 1
;      let f 10 * zz + 36
;      let t vt
;  ifelse f > 0 and f < 72[                                    ;decidimos si es de alquiler o propia vamos a decidir el número por medio
;  let prob item 0 item 0 item (f - 1) lista-normal             ;de este procedimiento para todas las casas ocupadas
;        ifelse prob < 0.5 [set v_propia vt][ifelse prob > 0.95 [set v_alquiler v_ocu ][ set v_propia ceiling (0.5 * v_ocu)  set  v_alquiler v_ocu - v_propia ] ]
;        ] [set v_propia v_ocu ]



      let z  ((-0.77 *  viv_auto) + ( esc * 0.018) + ( viv_1dor * -0.1) + ( viv_2masdor * -0.1)  ) ;; calcular Z-normal
      let zz precision z 1
      let prob 1 / (1 + Exp(-(zz)))
      ifelse prob < 0.5 [set v_propia vt][ifelse prob > 0.95 [set v_alquiler v_ocu ][ set v_propia ceiling (0.5 * v_ocu)  set  v_alquiler v_ocu - v_propia ] ]



          ]
        ]


  ask patches with [distance patch 0 0 > 6]  [sprout-sellers 1                 ;generamos los vendedores de la periferia
        [;set precio-centro precio-patch
        set periferia 1
        set id_s [who] of self
        set area_s (1 + random 10)
  ]]



ask sellers [set size 0.1]

  ;show date-and-time
 set nt count sellers
 set n_u ceiling (pje_u * nt)
end


to assign-income    ;; owner procedure
   ask sellers with [vt != 0][
;; assigns the income and savings of a new owner
;; uses gamma (alpha, lambda) distribution
;; mean of a gamma distribution = alpha / lambda
; parameters taken from http://www2.physics.umd.edu/~yakovenk/papers/PhysicaA-370-54-2006.pdf
  let alpha 1.3
  let lambda 1 / 20000
  set ingresos 0
  ; avoid impossibly low incomes (i.e. less than half the desired mean income)
 ; while [ income < MeanIncome / 2 ] [
    set ingresos (MeanIncome * lambda / alpha ) * (random-gamma alpha lambda); *
                  ;    (1 + (Inflation / (TicksPerYear * 100)) ) ^ ticks
   ; ]
  ; give them a proportion of a year's income as their savings
 ; set capital income * Savings / 100


  if cluster?[
      let r 0
    set r distance patch 0 0

      set ingresos ingresos * (  1 / (r + 1) ) ]
  ]




end



to ingresos-v
 ; show date-and-time
  let y0 2800
  ask sellers with [vt != 0][



    if ingresos <= 100000[
    set precio 120 * 0.3 *  ingresos]
    if ingresos > 100000[
    let maxi max [ingresos] of sellers
    let m 4000000 / (maxi - 100000)
    let b 3000000 - ((4000000 / (maxi - 100000)) * 100000)
      set precio (m * ingresos) + b] ;funcion lineal del precio con respecto al ingreso

     ; set precio-viv
  ;;; calculamos el precio de renta que es del 1% del precio de la vivienda ;;;
      set precio_a 0.01 * precio
      set pb 0.5 * precio
      set precio-1 precio
      set precio-2 precio
      set p0 precio
      set precio_referencia p0
      set ahorro  0.5 * ingresos
      ]
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;;;;;;;;;;;;;; Tipo de vivienda "residencial" o "popular" ;;;;;;;;;;;;;


  let pm mean [precio] of sellers with [periferia = 0]
  ask sellers with [periferia = 0] [  ifelse precio > pm [ set tipo_v "residencial" set v_r v_ocu][ set tipo_v "popular" set v_p v_ocu]   ]


 ; show date-and-time
end


to income-education

  ask sellers with [vt != 0][
  if ingresos <= 0.5 *  MeanIncome [ set educ ceiling ( random-float 6)]
  if ingresos > 0.5 *  MeanIncome and ingresos  <=  MeanIncome [set educ ceiling (6 + random-float 3)]
  if ingresos > MeanIncome and ingresos <= (3 / 2) * MeanIncome [set educ ceiling (9 + random-float 3)]
  if ingresos > (3 / 2) * MeanIncome and ingresos <= 2 * MeanIncome [set educ ceiling (12 + random-float 4)]
  if ingresos >  2 * MeanIncome [set educ ceiling (16 + random-float 6)]

  if ingresos <= 100000[
    set precio 120 * 0.3 *  ingresos]
    if ingresos > 100000[
    let maxi max [ingresos] of sellers
    let m 4000000 / (maxi - 100000)
    let b 3000000 - ((4000000 / (maxi - 100000)) * 100000)
      set precio (m * ingresos) + b] ;funcion lineal del precio con respecto al ingreso
     ; set precio-viv
  ;;; calculamos el precio de renta que es del 1% del precio de la vivienda ;;;
      set precio_a 0.01 * precio
      set pb 0.5 * precio
      set precio-1 precio
      set precio-2 precio
      set p0 precio
    set ahorro  0.5 * ingresos]
  let pm mean [precio] of sellers with [periferia = 0]
  let p_maxi max [precio] of sellers
  let pc 0.7 * p_maxi
  ask sellers with [periferia = 0] [  ifelse precio > pc [ set tipo_v "residencial" set v_r v_ocu][ set tipo_v "popular" set v_p v_ocu]   ]
end

to caract-mza

  ; show date-and-time
    let distancia 0

    let max_densi (max [densidad_s] of sellers)
    ask sellers[
    set distancia distance patch 0 0
    set distancia_centro distancia
    let id id_s
    let dist 0
    let dist_m max  [distance patch 0 0] of sellers

    let distancia_cen distancia / dist_m
    set dist   (1.01 - distancia_cen)

      ;;; vecindario;;;;;;
      ;;;;;;;;;de vecindad-sellers;;;;;;

;;;;;

    let j []
    set j sort-on [distance  myself] sellers
     set j remove-item 0 j

     set vecindad [ ]
     set vecindad lput (item 0 j) vecindad
     set vecindad lput (item 1 j) vecindad
     set vecindad lput (item 2 j) vecindad
     set vecindad lput (item 3 j) vecindad

     set vecinos [ ]
     set  vecinos lput ([id_s] of item 0 vecindad)  vecinos
     set  vecinos lput ([id_s] of item 1 vecindad)  vecinos
     set  vecinos lput ([id_s] of item 2 vecindad)  vecinos
     set  vecinos lput ([id_s] of item 3 vecindad)  vecinos

    if vt != 0[
    let v_conser  vt -  v_sinserv
    let prob_serv  v_conser / vt
    let prob_esc  educ / 19


    set  i_m    1 -  distancia / dist_m

    let densi  (1.01 - (densidad_s / max_densi))


      set utilidad_s (densi ^ .2) * (prob_esc ^ .3) * (dist ^ .5)
      set utilidad_r (densi ^ .2) * (prob_esc ^ .5) * (dist ^ .3)


 ;;; Función de utilidad;;;;;;;;;;;;;;;


  ]]
  ;;;;;; Calculamos la Utilidad promedio ;;;;;;
 ask sellers[
    if vecinos != 0[
  let h 0
   let lista1 []
 while [h < 4][
  set lista1 lput ([utilidad_s] of turtle item h vecinos) lista1
     set h (h + 1)
        ]

         let lista2 []
   while [h < 4][
   set lista2 lput ([utilidad_r] of turtle item h vecinos) lista2
   set h (h + 1)
        ]
    let u_r utilidad_r
    set lista2 lput u_r lista2
    set   utilidad_promedio_r mean lista2

    set   utilidad_promedio_s mean lista1
 set label  ceiling  vt


;   print "Fin catact-mza"
  ]]
;  show date-and-time
end

to prob-alquiler
;;;;;;;;                                                                             ;;;;;;;;
;;;;;;;;  Cargando los datos de la probabilidad acumlada de dena distribución normal ;;;;;;;;;
;;;;;;;;                                                                             ;;;;;;;;



  file-open "normal_prob.txt" ;;; archivo externo donde están los datos de las probabilidades
let k 0
   let j 0
  set lista-normal []
while [ not file-at-end? ]
[
  let entrada (list n-values 1 [file-read])
   set lista-normal lput entrada lista-normal
   ; print item 0 item 0 item j lista    ;;; los datos aparecen como una lista de listas de listas por los que hay que adentrarse hasta obtener el número
  set j (j + 1)
]

file-close
end


to go
  ask sellers [set vacantes v_des
               set ocupadas v_ocu]
 if nuevos-hogares > 0[ create-hogares nuevos-hogares [

    buscar-casa
    comprar-casa]



; ask hogares[comprar-casa]
  ]

;  verificar-vecindario
;  comprar-casa-en-renta
  actualizar-info

 construir
;
 verificar-vecindario
 comprar-casa-en-renta
 pensar-vender
 contabilidad
  ;print sincasa
  let nnn count sellers with [tv > 2000]
  ;print (word "hogares saturados " nnn)
 ; if contar-hogares > 20 [stop]

    if choque-ingresos? [
      if (sum [v_ocu] of sellers with [distancia_centro > 6]) != 0 [choque-ingresos] ]

   set precio_promedio-1 precio_promedio
  set precio_promedio precision (mean ([precio] of sellers)) 3


  ask sellers [set label ceiling v_ocu]

; color-poblacion
 ; color-educacion
  ;color-ingreso
 ; save1
    ask sellers with [v_r > v_p and distancia_centro <= 6][ ask patch-here [set pcolor 94]]   ;;; Azul
    ask sellers with [v_p > v_r and distancia_centro <= 6][ ask patch-here [set pcolor 64]]   ;;; Verde

  graphs
  histograma [ingresos] of sellers with [distancia_centro <= 6]

  if ticks = 1 [ set ing_l0 ing_l
    set d_l0 d_l set ing_lf ing_l
    set d_lf d_l
    set pob_r0 pob_r
    set pob_s0 pob_s
  ]
  if ticks = tiempo [ set ing_lf ing_l
    set d_lf d_l   i-gentrificacion
  set pob_rf pob_r set pob_sf pob_s]

  ;if precio_promedio-1 = precio_promedio [if save? [save1] stop]
  if ticks > tiempo [if ganancias_promedio > 0 [ if expropiar-espacios? [expropiar-espacios] if save? [save1]   stop]]
  let n count sellers with [v_des_a > 0]
  if n > 0 [
   ; print n
   ; print ticks
  ]
  let r count sellers with [v_ocu < 0 ]
  if ticks = (tiempo - 5) [if viv_asequible? [asequible-final]]

  tick
 ; print if  tick
; asequible-final
end

to buscar-casa

    let y0 2800
  let alpha 1.3
  let lambda 1 / 2
 ; set income 0
 ; avoid impossibly low incomes (i.e. less than half the desired mean income)

  set ingresos_h (MeanIncome * lambda / alpha ) * (random-gamma alpha lambda)  ;;------ Corregir ingresos-------
    ;set esc_h ceiling (12 *(random-gamma  2 2))

  if ingresos_h <= 0.5 *  MeanIncome [ set esc_h ceiling ( random-float 6)]
  if ingresos_h > 0.5 *  MeanIncome and ingresos_h  <=  MeanIncome [set esc_h ceiling (6 + random-float 3)]
  if ingresos_h > MeanIncome and ingresos_h <= (3 / 2) * MeanIncome [set esc_h ceiling (9 + random-float 3)]
  if ingresos_h > (3 / 2) * MeanIncome and ingresos_h <= 2 * MeanIncome [set esc_h ceiling (12 + random-float 4)]
  if ingresos_h >  2 * MeanIncome [set esc_h ceiling (16 + random-float 6)]

    set ahorro_h 0.5 * ingresos_h
    let ah ahorro_h
    let mens ingresos_h * pje_al
    set ingreso_promedio mean [ingresos] of sellers
    ;;;; Elegir el seller que maximice la utilidad u*
    ifelse ingresos_h > ingreso_promedio [set clase_social "alta"
    set th 0

  ]
  [set clase_social "baja"
    set th 1
  ]
    let tipo_viv 0
    let w 0

    ifelse th = 0 [let n count (sellers with [  (precio * 0.2 <= ah) and  precio * 0.01 <= mens  and distancia_centro <= 6  and v_des > 0])

    ifelse n > n_u[
    set w  max-n-of n_u  sellers with [  (precio * 0.2 <= ah) and  precio * 0.01 <= mens and distancia_centro <= 6 and v_des > 0 ]
    [utilidad_r]  ]

  [
    set w max-n-of  n sellers with [ (precio * 0.2 <= ah) and  precio * 0.01 <= mens and distancia_centro <= 6 and v_des > 0 ]
    [utilidad_r]]

  ask w [ set demanda demanda + 1]

  set prospectos_c sort-on  [(- utilidad_r)]  w
  let prosp prospectos_c ]
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   [let n count (sellers with [   (precio * 0.2 <= ah) and  precio * 0.01 <= mens  and distancia_centro <= 6  and v_des > 0])

    ifelse n > n_u[
    set w  max-n-of n_u  sellers with [  (precio * 0.2 <= ah) and  precio * 0.01 <= mens and distancia_centro <= 6  and v_des > 0]
    [utilidad_s]  ]

  [
    set w max-n-of  n sellers with [  (precio * 0.2 <= ah) and  precio * 0.01 <= mens and distancia_centro <= 6 and v_des > 0]
    [utilidad_s]]

  ask w [ set demanda demanda + 1]

  set prospectos_c sort-on  [(- utilidad_r)]  w
  let prosp prospectos_c]



end



to comprar-casa
  let y who
  ifelse length prospectos_c != 0 [

  let s first prospectos_c
    ifelse [v_des > 0] of s[ comprar-a s y][set prospectos_c but-first prospectos_c comprar-casa ]
  ]  [buscar-rentar y]

end

to comprar-a [s y]


    ask s [

      let esco 0
      let ingre 0
      let ahorros 0
      set transaccion 1
      set compra 1
     let p precio
    set esco [esc_h] of myself
    set ingre [ingresos_h] of myself
    set ahorros [ahorro_h] of myself
    let c_s [clase_social] of myself
      set ahorro (v_ocu * ahorro + ahorros) / (v_ocu + 1)
      set educ  (v_ocu * educ + esco) / (v_ocu + 1)
      set ingresos (v_ocu * ingresos + ingre) / (v_ocu + 1)
      set v_ocu-1 v_ocu
      set v_ocu v_ocu + 1
      set v_des-2 v_des-1
      set v_des-1 v_des
      set v_des v_des - 1
      set v_propia v_propia + 1
ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
    set ingresos_c  ingresos_c + p

    ifelse t_h = 0 [   set v_r v_r + 1][set v_p v_p + 1  ]
  ]
  ask hogar y [die]



die ;ya tienen casa ya no aparecen en el modelo
end
to buscar-rentar [x]   ;hay que checar ingresos esa variable es de sellers y no sirve en la desigualdad
  let h 0
  ask hogar x[
    set h who
    let ing ingresos_h

   let w 0
    ifelse th = 0 [let n count (  sellers with [  (precio_a  <= ing * pje_al) and distancia_centro <= 6 and v_des > 0])
    ifelse n > n_u[
    set w  max-n-of  n_u  sellers with [   (precio_a  <= ing * pje_al) and distancia_centro <= 6 and v_des > 0]
    [utilidad_r]]
  [
    set w max-n-of  n sellers with [  (precio_a  <= ing * pje_al) and distancia_centro <= 6  and v_des > 0]
    [utilidad_r]]

  ask w [ set demanda demanda + 1]
  set prospectos_r sort-on  [(- utilidad_r)]  w  ]

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    [let n count (  sellers with [   (precio_a  <= ing * pje_al) and distancia_centro <= 6 and v_des > 0])
    ifelse n > n_u[
    set w  max-n-of  n_u  sellers with [  (precio_a  <= ing * pje_al) and distancia_centro <= 6 and v_des > 0]
    [utilidad_s]]
  [
    set w max-n-of  n sellers with [ (precio_a  <= ing * pje_al) and distancia_centro <= 6  and v_des > 0]
    [utilidad_s]]

  ask w [ set demanda demanda + 1]
  set prospectos_r sort-on  [(- utilidad_s)]  w]


; print (word "prospectos renta " prospectos_r)



    rentar-casa
  ]
end

to rentar-casa
 ; print "inicia busqueda de renta"
   let h who
   ifelse length prospectos_r != 0[

  let s first prospectos_r
    ifelse [v_des > 0] of s[ rentar-a h s] [set prospectos_r but-first prospectos_r rentar-casa ]
    ]  [
  ; print "no encontré casa ni para comprar ni para rentar"
   ; print 1
    set status  "sin_techo_n"                                     ;::::::::: LOS SIN TECHO, NUEVOS EN LA CIUDAD

    sin-techo1 h
    ]
end

to rentar-a [h s ]
let tipoh 0
  ask hogar h [set tipoh th]
    ask s [
    set compra 1
    let pa precio_a
     set transaccion   1
   ;   ask vivienda casa [
    let esco [esc_h] of myself
    let ingre [ingresos_h] of myself
    let ahorros [ahorro_h] of myself
    let c_s [clase_social] of myself
      set ahorro (v_ocu * ahorro + ahorros) / (v_ocu + 1)
      set educ  (v_ocu * educ + esco) / (v_ocu + 1)
      set ingresos (v_ocu * ingresos + ingre) / (v_ocu + 1)
      set v_ocu-1 v_ocu
      set v_ocu v_ocu + 1
      set v_des-2 v_des-1
      set v_des-1 v_des
      set v_des v_des - 1
      set v_alquiler v_alquiler + 1
ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
 ;   print (word "ya tengo casa rentada en " s "con un precio " precio " con vacantes " v_des " y con demanda_c " demanda )

    ifelse tipoh = 0 [   set v_r v_r + 1  ][set v_p v_p + 1 ]
  ]

  ask hogar h [die] ; ya tienen casa, desaparecen del modelo.

end

to-report mensualidad [x ]
  let eng x * 0.2
  let n (- 360)
  let Loan x - eng
  let i 0.1
  report (i * Loan) /  ( 1 - (1 + i )^(n))
end

to actualizar-info


;let v* 0
 set precio_promedio precision (mean ([precio] of sellers)) 3
 set v* mean [  demanda / vacantes] of sellers with [vacantes != 0]

set p_max  max[precio] of sellers
 let d_max max[demanda] of sellers


  ask sellers with [compra = 0 and vt > 0 and distancia_centro <= 6 and v_des > 0]
  [let p precio
    ifelse rigido?[   set precio 0.99 * p][set precio ((v_des / vt) * P)]]
  ask sellers with [distancia_centro <= 6 and compra = 1][

;    let d_ocu 0
;    set d_ocu (v_ocu - v_ocu-1) / (v_ocu + 1)

   let v 0
   ; ifelse d_max > 0 [set v v_ocu * (demanda / d_max)][set v 0]
    ; ifelse d_max > 0 and vt != 0 [set v (1 - (v_des / vt)) * (demanda / d_max)][set v 0]
     ifelse d_max > 0 and v_des-1 != 0 [set v (1 - ( v_des / vt)) * (demanda / d_max)][set v 0]
    let p precio
; print v
      set precio-2  precio-1
      set precio-1 precio

 ;  ifelse distancia_centro <= 4 [set precio p +  p0 * v][set precio p]

   ;;;;;;;;;;;; ifelse (v_ocu - v_ocu-1) = 0 [set precio 0.5 * p][ set precio   p +  p0 * v]
   ; set precio p + (p0 * (v - v*))

     set precio   p +  p0 * v

    set precio_a 0.01 * precio

    set compra 0


  ]

  ask sellers with [distancia_centro <= 6 and compra = 0][
     set precio_a 0.01 * precio]



;color-demanda
ask sellers [
    let y who
   ;  ifelse ocupadas > 0 [ set tv ( v_ocu -  ocupadas   ) / ocupadas][set tv 0]
    act-utilidad y


    ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]





    let a ingresos * 0.01
    set ahorro ahorro + a

  ]

  ;pensar-vender


end


to construir
  let t ticks
  let m1 max [vt] of sellers
  ;if m1 > viv_max [ print (word "seller con muchas casas antes de construir " m1 )]
  let n count sellers with [precio  > precio-1 and distancia_centro <= 6 and vt < densidad_maxima ]
 ; print n
 ask sellers with [precio  > precio-1 and distancia_centro <= 6 and vt < densidad_maxima and v_des >= 0]   [
      let yo who
      let pt precio
      let pt-1 precio-1
      set t_construc (t + 6)
      let qdes v_des

      let qs  ceiling (q0 * ((pt - p0) / p0))
        let qn (qs - qdes)
        let maxv vt + qn
        if maxv > viv_max [ set qn (viv_max - vt)]
      ;;;;;;;;;;;; Porcentaje de vivienda asequible

    if qn < 0 [set qn 0
                set n_construc 0]

    if qn > 0 [

    let qa 0
    ifelse  viv_asequible?[
    ifelse pt > n_p * p0   [


          set n_construc_a  ceiling (qn * alfa * ( 1 / (1 - alfa)))

        set n_construc (qn - n_construc_a)
       ; print  (word "seller " yo  " q_n " qn " n_construc " n_construc " n_construc_a " n_construc_a)
       ; print n_construc_a
        ]
        [set n_construc qn]]

       [ set n_construc qn]


  ]

  ]

  ask sellers with [t_construc = t and vt < viv_max and distancia_centro <= 6 ] [
        let s who


        set v_des v_des + n_construc
        set v_des_a v_des_a + n_construc_a
        set vt_r v_des + v_ocu
        set vt_a v_des_a + v_ocu_a
        set vt vt_r +  vt_a
        let qn n_construc
        ifelse n_construc_a > 0 [
        let qa n_construc_a
        let qt qn  /(1 - alfa)
        let c (qt * p0) + ((p0 * qt * qt) / (2 * q0))
        set costos costos + c ]
       [let c (qn * p0) + ((p0 * qn * qn) / (2 * q0))

        set costos costos + c]
      ;;;;;;;;;


        set n_construc 0
        set n_construc_a 0
   ; if vt > densidad_maxima [print (word  n_construc " nuevas viviendas en " s "  con un total de " vt )]
      set t_construc 0]

;  ask sellers with [demanda != 0 and v_des = 0 and v_des-1 != 0 and vt > 0 and vt < densidad_maxima ] [
;    let q vt
;     let pt-1 precio-1
;    let qn ceiling  (0.3 * q)
;    set v_des-1 v_des
;    set v_des v_des + qn
;    set vt v_des + v_ocu
;    let c (qn * p0) + ((p0 * qn * qn) / (2 * q0))
;    set costos  c]
;


  ask sellers  [set demanda 0
    set transaccion-1 transaccion
      set transaccion 0]

   let m2 max [vt] of sellers
 ; if m2 > viv_max [ print (word "seller con muchas casas después de construir " m2 )]
end





to act-utilidad [x]
 let max_densi (max [densidad_s] of sellers)
 ask seller x[
let id id_s
    let dist 0
    let dist_m max  [distance patch 0 0] of sellers
    let distancia distance patch 0 0
    let distancia_cen distancia / dist_m
    set dist   (1 - distancia_cen)
    if vt != 0[
    let v_conser  vt -  v_sinserv
    let prob_serv  v_conser / vt
    let prob_esc  educ / 19
    let densi (1 - (densidad_s / max_densi))
   ;;; Función de utilidad;;;;;;;;;;;;;;;
     ; print prob_esc
   set utilidad_s (densi ^ .2) * (prob_esc ^ .3) * (dist ^ .5)
    set utilidad_r (densi ^ .2) * (prob_esc ^ .5) * (dist ^ .3)
  ;;;;;; Calculamos la Utilidad promedio ;;;;;;
    let h 0
   let lista1 []
   while [h < 4][
   set lista1 lput ([utilidad_s] of turtle item h vecinos) lista1
   set h (h + 1)
        ]
    let u_s utilidad_s
    set lista1 lput u_s lista1
    set   utilidad_promedio_s mean lista1
      ;;;;;;;;;;;;;;;
      let lista2 []
   while [h < 4][
   set lista2 lput ([utilidad_r] of turtle item h vecinos) lista2
   set h (h + 1)
        ]
    let u_r utilidad_r
    set lista2 lput u_r lista2
    set   utilidad_promedio_r mean lista2
 ;set label  precision  utilidad_s 2
]  ]

end

to tasa-vacante

ask sellers [
  ]


end

to color-densidad
  ask sellers [
    let densidad densidad_s
    ask patch-here[
      set pcolor scale-color green densidad 0 50]]
end

to color-precio
  ask sellers [
    let densidad precio
    ask patch-here[
      set pcolor scale-color green densidad 0 100]]
end

to color-poblacion
  ask sellers [
    let poblacion v_ocu
    ask patch-here[
      set pcolor scale-color green poblacion 0 50]]
end
to color-educacion
  ask sellers [
    let educacion educ
    ask patch-here[
      set pcolor scale-color green educacion 0 50]]
end

to color-demanda
  ask sellers [
    let densidad demanda
    ask patch-here[
      set pcolor scale-color green densidad 0 100]]

end

to color-ingreso
  ask sellers [
    let densidad ingresos
    let i_max max [ingresos] of sellers
    let i_min min [ingresos] of sellers
    ask patch-here[
      ;show densidad
      set pcolor scale-color green densidad i_min (i_max + 1)]]
end
to quien-con-$max


   let w max-one-of sellers [precio]
    ask w[
  ;  print (word " el seller " who " tiene el precio mas alto con " precio " con una demanda " demanda " y oferta " v_des)
  ;  print (word " la tasa natural de vacantes v* es " v*)
   ;print ",,,,,,,,"
   ]
  let s max-one-of sellers [tp]
  ;ask  s [print (word " el seller " who " tien la tp  mas alto " tp " con una demanda " demanda " y oferta " v_des)]
 ; print ";;;;;;;"
 ; print ";;;;;;"
end


to verificar-vecindario

  ask sellers with [precio_a > pje_al * ingresos and v_ocu > 0 and distancia_centro <= 6 ][
   ; print "me voy porque está muy caro"
let a 0
    let a1 0
    ;;; los primeros que se irán son los de vivienda popular

    ifelse v_p > 1[
      set t_h 1
      set a1 ceiling(random-float 1 * v_p)] [
      if v_r > 0[
      set t_h 0
        set a1 ceiling(random-float 1 * v_r)]
    ]
 let tipoh t_h
    ifelse a1 > v_alquiler [set a v_alquiler][set a a1]
    let s who
    let ing ingresos
    let ed educ
    let ah ahorro
    let vp v_p

    ask patch-here[ sprout-hogares a [
    set pje_alquiler pje_al + 0.1
    let h who
    set v_actual s
    set status  "sin_techo_v"
    set ingresos_h ing
    set esc_h ed
    set ahorro_h ah
    set th tipoh
      ifelse vp > 1 [ set clase_social "baja"] [set clase_social "alta"]
      buscar-renta s h
     ; print (word h " con clase social " clase_social " se tiene que ir de " s )
    ]]
  ]
end

to comprar-casa-en-renta
ask sellers with [precio_a <= pje_al * ingresos and v_ocu > 0 and distancia_centro <= 6 and v_alquiler > 0 ][



    let a ceiling(random-float v_alquiler)
    let p precio
    let ah ahorro
    let s1 who

    let mens pje_al * ingresos
    ifelse ah > p * 0.2  and  precio * 0.01 <= mens[

     set v_alquiler v_alquiler - a
     set v_hipoteca v_hipoteca + a
     let l1 ticks + 300
  ;  print l1
     let li ( list l1 a)
  ;  print li
     set l_hipoteca lput li l_hipoteca
     set v_propia  v_propia + a
     set compra 1
      set ingresos_c  ingresos_c + p
    ]

    [ pensar-irme s1]

  ]


end


to pensar-irme [s1] ;;; s seller, h vivienda

    let vs v_p
    let vr v_r
    let vtot vt
    let ing ingresos
    let ed educ
    let va v_alquiler
    let np v_propia
    let ah ahorro
    let v_oc v_ocu
;    ifelse v_p > 1[
;      set t_h 1
;      set a1 ceiling(random-float 1 * v_p)] [
;      set t_h 0
;       set a1 ceiling(random-float 1 * v_r)
;    ]

let a 0
    let a1 0
    ;;; los primeros que se irán son los de vivienda residencial

    ifelse v_r > 1[
      set t_h 0
      set a1 ceiling(random-float 1 * v_r)] [
      if v_p > 1[
      set t_h 1
        set a1 ceiling(random-float 1 * v_p)]
    ]

    ifelse a1 > v_alquiler [set a v_alquiler][set a a1]

   if v_ocu < va [ print (word "seller con ocupación negativa " s1 "pensar-irme" v_ocu)  ]
 ; print tipo_v
    let t_v tipo_v
    let h 0
    let probabilidad tolerancia_alquiler

    let  prob v_alquiler / vt

    let tipoh t_h

    ask patch-here [sprout-hogares a [
    set h who
    set status "con_techo"
    set ingresos_h ing
    set esc_h ed
    set ahorro_h ah
    set th tipoh
    ifelse t_v = "residencial" [set clase_social "alta"][set clase_social "baja"]
     ;; este die es de no me voy
    ifelse   prob >= probabilidad    [buscar-renta1 s1 h
      print (word h " se quiere ir de " s1 )]
    [ die
      print (word h " se queda en " s1 )]

  ]
   ]







  let b 0
  let b1 0
  if v_r > 0 and v_p > 0 and v_p < v_r and v_alquiler > 0 and v_ocu > 0 [
    let probabilidad1 tolerancia_social
    let prob1 v_p / vt
    ifelse v_r > 1[
      set t_h 0
      set b1 ceiling(random-float 1 * v_r)] [
      if v_p > 0[
      set t_h 1
        set b1 ceiling(random-float 1 * v_p)]
    ]

    ifelse b1 > v_alquiler [set b v_alquiler][set b a1]
    if b > 0[
    ask patch-here [sprout-hogares b [
    set h who
    set status "con_techo"
    set ingresos_h ing
    set esc_h ed
    set ahorro_h ah
    set th 0
    set clase_social "alta"
    ifelse   prob1 >= probabilidad1 [buscar-renta1 s1 h  print (word h " se quiere ir de " s1 )][ die print (word h " se queda en " s1 )]
      ]]
    ]]


end

to buscar-renta [s1 h ]
   ;print h
  ask hogar h[
    set h who
    let pje_a pje_al
   let ing ingresos_h
    ; let u utilidad_h

   let w 0
     ifelse th = 0 [let n count (  sellers with [   (precio_a  <= ing * pje_al) and distancia_centro <= 6 and v_des > 0])
    ifelse n > n_u[
    set w  max-n-of  n_u  sellers with [  (precio_a  <= ing * pje_al) and distancia_centro <= 6 and v_des > 0]
    [utilidad_r]]
  [
    set w max-n-of  n sellers with [ (precio_a  <= ing * pje_al) and distancia_centro <= 6  and v_des > 0]
    [utilidad_r]]

  ask w [ set demanda demanda + 1]
  set prospectos_r sort-on  [(- utilidad_r)]  w  ]

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    [let n count (  sellers with [  (precio_a  <= ing * pje_al) and distancia_centro <= 6 and v_des > 0])
    ifelse n > n_u[
    set w  max-n-of  n_u  sellers with [  (precio_a  <= ing * pje_al) and distancia_centro <= 6 and v_des > 0]
    [utilidad_s]]
  [
    set w max-n-of  n sellers with [  (precio_a  <= ing * pje_al) and distancia_centro <= 6  and v_des > 0]
    [utilidad_s]]

  ask w [ set demanda demanda + 1]
  set prospectos_r sort-on  [(- utilidad_s)]  w]
 ;print (word "prospectos renta " prospectos_r)
    rentar-casa1 s1 h
  ]
end


to buscar-renta1 [s1 h]

  ask hogar h[
    set h who
    set pje_alquiler pje_al
    let ing ingresos_h
    let pje_a pje_alquiler
     let u utilidad_h
   let w 0
    ifelse th = 0 [ let n count (  sellers with [ (precio_a  <= ing *  pje_al) and utilidad_s >= u and distancia_centro <= 6  and v_des > 0])
    ifelse n > n_u[
    set w  max-n-of  n_u  sellers with [  (precio_a  <= ing * pje_al) and distancia_centro <= 6 and v_des > 0]
    [ utilidad_r]]
  [
    set w max-n-of  n sellers with [  (precio_a  <= ing * pje_al) and distancia_centro <= 6 and v_des > 0]
    [ utilidad_r]]

  ask w [ set demanda demanda + 1]
      set prospectos_r sort-on  [ ( - utilidad_r)]  w]
 ;print (word "prospectos renta " prospectos_r)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    [let n count (  sellers with [  (precio_a  <= ing * pje_al) and distancia_centro <= 6 and v_des > 0])
    ifelse n > n_u[
    set w  max-n-of  n_u  sellers with [  (precio_a  <= ing * pje_al) and distancia_centro <= 6 and v_des > 0]
    [utilidad_s]]
  [
    set w max-n-of  n sellers with [  (precio_a  <= ing * pje_al) and distancia_centro <= 6  and v_des > 0]
    [utilidad_s]]

  ask w [ set demanda demanda + 1]
  set prospectos_r sort-on  [(- utilidad_s)]  w]
    rentar-casa1 s1 h
  ]
end





to rentar-casa1 [s1 h]
let i 0
 ; print "inicia busqueda de renta"
   ifelse length prospectos_r != 0[
          let s2 first prospectos_r
          ifelse [v_des > 0] of s2 [
      let sw [who] of s2
                  rentar-a1 s1 sw h print (word h " se fue de " s1 " a " s2)]
                  [set prospectos_r but-first prospectos_r
                  rentar-casa1 s1 h ]
          ]  [
    ifelse pje_alquiler < pje_al + 0.1               ;;;;;;;;;;;Aquí está el pedo!!!!!!
          [set pje_alquiler pje_al + 0.1
            set i i + 1
          ;  print i
           buscar-renta s1 h]

    [
      if status = "con_techo" [ask hogar h [die] print (word h " no encuentra otro lugar diferente a " s1 )]                                            ;;;;; SUBIÓ EL PRECIO Y YA NO TIENEN HOGAR
      if status = "sin_techo_v" [acomodar-hogares s1 h]
      ;sin-techo2 s1 h
    ]
   ; esperar-vivienda s1 h

    ]

end
to rentar-a1 [ s1 s2 h ]
;let tipoh 0
  ;ask hogar h [set tipoh th
 ; print tipoh]
;print (word "s1, " s1 ", s2 ," s2 " y h " h)
  let tipoh 0
  ask hogar h [set tipoh th]
    ask seller s1 [
     let pa precio_a
  ;  set size 1
     set transaccion   1
    set compra 1
   ;   ask vivienda casa [
    let esco [esc_h] of myself
    let ingre [ingresos_h] of myself
    let ahorros [ahorro_h] of myself
    let c_s [clase_social] of myself

    if v_ocu > 1[
      set ahorro (v_ocu * ahorro - ahorros) / (v_ocu - 1)
      set educ  (v_ocu * educ - esco) / (v_ocu - 1)
      if educ < 0 [
         print (word "seller con educación negativa " s1 " rentar-a1")]
      set ingresos (v_ocu * ingresos - ingre) / (v_ocu - 1)
      set v_ocu-1 v_ocu
      set v_ocu v_ocu - 1]
    ;  set mudanzas mudanzas + 1
    if v_ocu < 0 [ print (word "seller con ocupación negativa " s1 " rentar-a1" v_ocu)  ]
      set v_des-2 v_des-1
      set v_des-1 v_des
      set v_des v_des + 1
      set v_alquiler v_alquiler - 1
      set n_m n_m + 1
    ifelse vt != 0 [set p_m n_m / vt][set p_m 0]
ifelse area_s > 0 [ set densidad_s (vt / area_s)]
    [set densidad_s  vt / 1]

   ; set t_h tipoh
ifelse tipoh = 0 [   set v_r v_r - 1 ][set v_p v_p - 1 ]
  ]



  ask  seller s2[
    set transaccion   1
  ;  set size 1
   ;   ask vivienda casa [
    let pa precio_a
    let esco [esc_h] of myself
    let ingre [ingresos_h] of myself
    let ahorros [ahorro_h] of myself
    let c_s [clase_social] of myself

      set ahorro (v_ocu * ahorro + ahorros) / (v_ocu + 1)
      set educ  (v_ocu * educ + esco) / (v_ocu + 1)
      set ingresos (v_ocu * ingresos + ingre) / (v_ocu + 1)
      set v_ocu-1 v_ocu
      set v_ocu v_ocu + 1
      set v_des-2 v_des-1
      set v_des-1 v_des
      set v_des v_des - 1
      set v_alquiler v_alquiler + 1

ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
    ;print (word "vengo de rentar en " s1 " y  ya tengo casa rentada en " s2 "con un precio " precio " con vacantes " v_des " y con demanda " demanda )
 ;print set t_h tipoh

    ifelse tipoh = 0[   set v_r v_r + 1  ][set v_p v_p + 1 ]
  ]
 ; ask hogar h [if clase_social = "alta" [ print (word " rico de" s1 " se va a "  s2) ask s2 [set size 1]]]

  ask hogar h [die]   ; ya tengo casa
  ask sellers [set size 0.1]
end



to save0

let file_out_name  (word "Asequible0.txt")
 file-open file_out_name                                          ;;   q, number of agents in the bigger cultural domain (normalized), number of cultural domains (normalized)
  ;  file-print (word q " " (giant-component-size / number_of_agents) " " (number_of_cultural_regions / number_of_agents) " " time)

  foreach sort sellers [ t ->
    ask t [
      file-print (word  " " xcor " " ycor " " pje_al " " pje_u " " n_p " " alfa " "
      precision distancia_centro 2" " precision ingresos 2 " " v_ocu " "  precision precio 2 " " v_p " " v_r " " v_des " " vt " " v_alquiler " " v_propia)
    ]
  ]
   file-close

end

to save1
  let s [subsidio] of gobierno 0
  let c [gasto_compra] of gobierno 0
  let  urbano sum [v_ocu] of sellers with [distancia_centro <= 6]
  let marginal sum [v_ocu] of sellers with [distancia_centro   > 6]
  print marginal
  let aseq sum [vt_a] of sellers
  let file_out_name  (word "Asequible1.txt")
 file-open file_out_name                                          ;;   q, number of agents in the bigger cultural domain (normalized), number of cultural domains (normalized)
  ;  file-print (word q " " (giant-component-size / number_of_agents) " " (number_of_cultural_regions / number_of_agents) " " time)
let tt ticks
  foreach sort sellers [ t ->
    ask t [
      file-print (word  " " xcor " " ycor " " pje_al " " pje_u " " n_p " " alfa " " tolerancia_social " " tolerancia_alquiler " "  ganancias_promedio " " v_ocu_a " " v_alquiler " " v_alquiler_a " " v_des_a " "
      precision distancia_centro 2" " precision ingresos 2 " " v_ocu " " vt " " v_des " " precision precio 2 " " v_p " " v_r " " c " " s  " " urbano " " marginal " " aseq " " precision indice_gentrificacion 2  " " asequible )
    ]
  ]
   file-close
end
to save3

  let file_out_name  (word "tiempo_equilibrio.txt")
 file-open file_out_name                                          ;;   q, number of agents in the bigger cultural domain (normalized), number of cultural domains (normalized)
  ;  file-print (word q " " (giant-component-size / number_of_agents) " " (number_of_cultural_regions / number_of_agents) " " time)
  let tt ticks

      file-print (word tt " " precision precio_promedio 2)

   file-close
end
to graphs
  g1
  g2
  g3
 set-current-plot "Histograma-Ingresos"

  set-plot-x-range (min [ingresos] of sellers)  (max [ingresos] of sellers  )
    set-plot-y-range 0 count sellers
   set-histogram-num-bars 10
   histogram [ingresos ] of sellers
;  set-plot-pen-interval 1000
;; set-plot-x-range 0 ifelse-value (max [income] of turtles > 1E+5) [ 1E+6 ] [ 1E+4 ]
;  set-plot-x-range 0 20000
;  histogram [ ingresos] of sellers with [educ > 0]

end
to g1
  let d_m max [distancia_centro] of sellers
  let di []
  let r 8
  let n r - 1
  set di n-values r [ i ->  lput ((( i   ) * d_m )/( n  )) di ]
 ; print di
 ; print item 0 item 0 di
  set d_l   di
  let s 7
  set ing_l []
  set ing_l n-values s [i -> lput (mean [ingresos] of sellers with [(distancia_centro >= item 0 item i d_l) and (distancia_centro < item 0 item (i + 1) d_l) ]) ing_l]
  set d_l but-first di
end


to g2
  let d_m max [distancia_centro] of sellers
  let di []
  let r 8
  let n r - 1
  set di n-values r [ i ->  lput ((( i   ) * d_m )/( n  )) di ]
  set d_l   di
  let s 7
  set pob_l []
  set pob_r []
  set pob_s []
  set pob_l n-values s [i -> lput (mean [v_ocu] of sellers with [(distancia_centro >= item 0 item i d_l) and (distancia_centro < item 0 item (i + 1) d_l) ]) pob_l]
  set pob_r n-values s [i -> lput (mean [v_r] of sellers with [(distancia_centro >= item 0 item i d_l) and (distancia_centro < item 0 item (i + 1) d_l) ]) pob_r]
  set pob_s n-values s [i -> lput (mean [v_p] of sellers with [(distancia_centro >= item 0 item i d_l) and (distancia_centro < item 0 item (i + 1) d_l) ]) pob_s]
  set d_l but-first di
end
to g3
  let d_m max [distancia_centro] of sellers
  let di []
  let r 8
  let n r - 1
  set di n-values r [ i ->  lput ((( i   ) * d_m )/( n  )) di ]
  set d_l   di
  let s 7
  set precio_l []
  set precio_l n-values s [i -> lput (mean [precio] of sellers with [(distancia_centro >= item 0 item i d_l) and (distancia_centro < item 0 item (i + 1) d_l) ]) precio_l]
  set d_l but-first di
end


to g4
  let d_m max [distancia_centro] of sellers
  let di []
  set ing_l0 []
  set d_lf []
  set ing_lf []
  let r 8
  let n r - 1
  set di n-values r [ i ->  lput ((( i   ) * d_m )/( n  )) di ]
 ; print di
 ; print item 0 item 0 di
  set d_l   di
  let s 7
  set ing_l []
  set ing_l n-values s [i -> lput (mean [ingresos] of sellers with [(distancia_centro >= item 0 item i d_l) and (distancia_centro < item 0 item (i + 1) d_l) ]) ing_l]


  if ticks = 500 [ set ing_lf
    ing_l set d_lf d_l]


end



to sin-techo1 [ h]
  let n_min count sellers with [ precio_a > 0 and v_des > 0 and distancia_centro <= 6]
  ifelse n_min > 0[
  let m_alq min [precio_a] of sellers with [ precio_a > 0 and v_des > 0 and distancia_centro <= 6]
  let h1 h


  let n_s 0
  let l_s 0
  ask hogar h[
  ;  print (word "el hogar "who " busca otra oportunidad")
  let pje_alq pje_al
  let alq_mens ingresos_h * pje_alq
  let ing_h ingresos_h



    ifelse alq_mens >= m_alq
    ;; me alcanza para rentar en algun lugar
    [
     ; print (word "el hogar "who " analiza sus finanzas")

  set n_s count sellers with [precio_a <= ing_h * pje_alq and v_des > 0 and distancia_centro <= 6  ]
  ;print n_s
  ifelse n_s = 0 [
      ask sellers with [precio_a <= ing_h * pje_alq and v_des = 0 and distancia_centro <= 6  and vt < viv_max] [set vt vt + 1     ;;;;;;; originalmete set vt vt + 1;   vamos a dejar set vt vt para ver si esto es lo que está causando el problema de construcción de vivienda
        set v_des v_des  + 1
        set sol_hogar sol_hogar + 1
         ; print 1
          ; print (word "el hogar "who " no encontró seller")

      ]
       buscar-rentar  h
     ; print (word "el hogar "who " busca rentar formal")
      ][
        let w  one-of  sellers with [precio_a <= ing_h * pje_alq and v_des > 0 and distancia_centro <= 6]
      ; print w
        rentar-a h1 w


      ;  print (word "el hogar "who " tiene para pagar en algún lugar")
      ]
    ]

    ;; no me alcanza para rentar en la ciudad
    [
      let n count sellers with [v_des_a > 0]
      ifelse n > 0 and asequible > 0
      [

        vivienda-asequible h1
        ]
      [
        vivienda-informal-1  h1
        ]



       ]
  ]
  ]
   [
      let n count sellers with [v_des_a > 0]
      ifelse n > 0 and asequible > 0
      [
        ask hogar h[
        let h1 who
        vivienda-asequible h1]
        ]
      [
      ask hogar h[
        let h1 who
        vivienda-informal-1  h1
        ]
    ]


       ]
end





to acomodar-hogares [s1 h]
  let m_alq min [precio_a] of sellers with [precio_a > 0 and distancia_centro <= 6 and v_des > 0] ;;;; que no eliga el mismo seller s1!!!
  let h1 h
  let s s1
 ; print h1
  let n_s 0
  let l_s 0
  ask hogar h[
  let pje_alq pje_al
  let alq_mens ingresos_h * pje_alq
  let ing_h ingresos_h


    ;print s
    ifelse alq_mens >= m_alq [
     let s2 0
      ask one-of sellers  with [   precio_a = m_alq and distancia_centro <= 6 and v_des > 0   ]                    ;;;;;;;;;que le rente a este cuate
        [set s2 who]
      rentar-a1 s s2 h1
    ]
    [
      let n count sellers with [v_des_a > 0]
      ifelse n > 0  and asequible > 0
      [vivienda-asequible-1  s h1]

     [ vivienda-informal-2 s h1]]]




end


to vivienda-informal-2 [s1 h]
  let tipoh 0
  ask hogar h [set tipoh th]
 ask seller s1 [
     set transaccion   1
   ;   ask vivienda casa [
    let esco [esc_h] of myself
    let ingre [ingresos_h] of myself
    let ahorros [ahorro_h] of myself
    let c_s [clase_social] of myself
      set ahorro (v_ocu * ahorro + ahorros) / (v_ocu + 1)
      set educ  (v_ocu * educ + esco) / (v_ocu + 1)
      set ingresos (v_ocu * ingresos + ingre) / (v_ocu + 1)
      set v_ocu-1 v_ocu
      set v_ocu v_ocu - 1
      set mudanzas mudanzas + 1
    if v_ocu < 0 [ print (word "seller con ocupación negativa " s1 " vivienda-informal-2") ]
      set v_des-2 v_des-1
      set v_des-1 v_des
      set v_des v_des + 1
      set v_alquiler v_alquiler - 1
      set n_m n_m + 1
    ifelse vt != 0 [set p_m n_m / vt][set p_m 0]
ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
ifelse tipoh = 0[   set v_r v_r - 1 ][set v_p v_p - 1]
  ]

  ask one-of sellers  with [distancia_centro > 6 ][
    set transaccion   1
   ;   ask vivienda casa [
    let esco [esc_h] of myself
    let ingre [ingresos_h] of myself
    let ahorros [ahorro_h] of myself
  let c_s [clase_social] of myself
      set ahorro (v_ocu * ahorro + ahorros) / (v_ocu + 1)
      set educ  (v_ocu * educ + esco) / (v_ocu + 1)
      set ingresos (v_ocu * ingresos + ingre) / (v_ocu + 1)
      ;set vt vt  ;  + 1  ;;;;;;; originalmete set vt vt + 1;   vamos a dejar set vt vt para ver si esto es lo que está causando el problema de construcción de vivienda
      set v_ocu-1  v_ocu
      set v_ocu  v_ocu + 1

      set v_alquiler v_alquiler + 1


ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
   ifelse tipoh = 0[   set v_r v_r + 1 ][set v_p v_p + 1]
    ;print (word "vengo de rentar en " s1 " y  ya tengo casa rentada en " s2 "con un precio " precio " con vacantes " v_des " y con demanda " demanda )
  ]

  ask hogar h [die]   ; ya tengo casa



end

to vivienda-informal-1  [h]
  let tipoh 0
   ask hogar h[
    set tipoh th
    let ingre ingresos_h
    let esco esc_h
    let ahorros ahorro_h
    let c_s [clase_social] of myself
    ask one-of sellers  with [distance patch 0 0 > 6][

      set ahorro (v_ocu * ahorro + ahorros) / (v_ocu + 1)
      set educ  (v_ocu * educ + esco) / (v_ocu + 1)
      set ingresos (v_ocu * ingresos + ingre) / (v_ocu + 1)
      set vt vt ;+ 1 ;;;;;;; originalmete set vt vt + 1;   vamos a dejar set vt vt para ver si esto es lo que está causando el problema de construcción de vivienda
      set v_ocu-1 v_ocu
      set v_ocu v_ocu + 1
      set v_alquiler v_alquiler + 1
ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
     ifelse tipoh = 0[   set v_r v_r + 1 ][set v_p v_p + 1]]
  ]
  ask hogar h [die]

end


to choque-ingresos


   ; let a random-float 1
    ask  sellers with [distancia_centro > 6 and v_ocu > 0][
      let va v_alquiler
      let s1 who
      let ing ingresos
      let ah ahorro
      let ed educ
     let dist distancia_centro
     let vr v_r
    let vp v_p
  set t_h 0
      ask patch-here [
      sprout-hogares vr[
         set th 0
        set distancia_h dist
      ;sprout-hogares ceiling (a * va)[
        set status "con_techo"
        let h who
        let pp min  [precio_a] of sellers with [distancia_centro <= 6 and precio_a > 0 and  v_des > 0]
         let dif ( pp / (0.3 * ing) ) - 1
        let alpha 0
        ifelse dif > 0 [set alpha dif][set alpha 0]
       set ingresos_h ing * ( 1 + alpha)
        let ingg ingresos_h
        ask gobiernos  [set subsidio  subsidio + (ing * alpha)]
        ;print ingresos_h
        set ahorro_h ah
        set esc_h ed
        buscar-renta s1 h]

      sprout-hogares vp[
    set th 1
        set distancia_h dist
      ;sprout-hogares ceiling (a * va)[
        set status "con_techo"
        let h who
        let pp min  [precio_a] of sellers with [distancia_centro <= 6 and precio_a > 0 and  v_des > 0]
         let dif ( pp / (0.3 * ing) ) - 1
        let alpha 0
        ifelse dif > 0 [set alpha dif][set alpha 0]
       set ingresos_h ing * ( 1 + alpha)
        let ingg ingresos_h
        ask gobiernos  [set subsidio  subsidio + (ing * alpha)]
        ;print ingresos_h
        set ahorro_h ah
        set esc_h ed
        buscar-renta s1 h]




    ]
  ]
;ask sellers [set label v_ocu]
;  graphs
;  tick
  ask sellers with [distancia_centro > 0] [ if ingresos < 0 [set ingresos 0]]
end


to expropiar-espacios
;  let n_v 5
 let w1 0
 let w2 0
 let n1 count (sellers with [ v_des > 0 and distancia_centro <= 6  ])
 let n2 count (sellers with [ v_ocu > 0 and distancia_centro > 6  ])

    set w1    min-n-of n1  sellers with [ v_des > 0 and distancia_centro <= 6  ]
    [v_ocu]
  set w2    max-n-of n2  sellers with [ v_ocu > 0 and distancia_centro > 6  ]
    [v_ocu]
  let s1 sort-on  [( v_ocu)]  w1
  let s2 sort-on [(- v_ocu)] w2

;  print s1
;  print s2
 ; if not empty? s1 [ print 1]
  while [(not empty? s1) and (not empty? s2)][
  let dif_v 0
    let l_who []
     let vo0 0
    let wp 0
    let l1 0
    let costo_total 0
    let sel1 [who] of  first s1
    let sel2 [who] of  first s2
  ask  seller sel1 [
      let w who
       set l1 length l_who
      if not member? w l_who [set l_who  lput w l_who set vo0 v_ocu]

    set vt densidad_maxima
    set v_des vt - v_ocu
    let voc v_ocu
    let vd v_des
    let vp v_propia
    let vo1 0
    let vp1 0
    let vdes 0
    let ah 0
    let ed 0
    let ing 0

    ask seller sel2 [
      let vo v_ocu
      set dif_v vd - vo
      ifelse dif_v > 0 [
      set vo1 voc + vo
      set vp1 vp + vo
      set vt 0
      set ah ahorro
      set ed educ
      set ing ingresos
      set v_ocu 0
      set ingresos 0
      set ahorro 0
      set v_des 0
      set v_r 0
      set v_p 0
      ][
        set v_ocu v_ocu - dif_v
        set v_des v_des + dif_v
        set vo1 voc + dif_v
        set vp1 vp + dif_v
        set dif_v 0

      ]


    ]
      set ahorro (v_ocu * ahorro + ah) / (v_ocu + 1)
      set educ  (v_ocu * educ + ed) / (v_ocu + 1)
      set ingresos (v_ocu * ingresos + ing) / (v_ocu + 1)
      set v_ocu vo1
      set v_propia vp1
      set v_des dif_v
      set vt v_ocu + v_des
  ]
  if [v_des] of (first s1) = 0 [set s1 but-first s1]
  if [v_ocu] of (first s2) = 0 [set s2 but-first s2]
  let l2 length l_who
    let v_t [vt] of seller sel1
    if l1 != l2 [set wp last l_who
      set costo_total ([precio] of seller wp) *  vo0 + ((min [precio] of sellers) * v_t)
    ]
    ask gobierno 0 [set gasto_compra gasto_compra + costo_total]
  ]

;  ask w [
;  let
;
;  ]
  ask sellers [set label ceiling vt ]
  graphs
tick
end



to vender-mi-casa [s1 s2]
  ask seller s1

  [


    if v_ocu < 0 [
         print (word "seller con ocupación negativa " s1 " vender-mi-casa")]

    if v_ocu < 0 [print v_ocu
      stop]

    let c_s tipo_v
    let p precio
    let esco educ
   let ingre ingresos
   let ahorros ahorro
    set ahorro (v_ocu * ahorro - ahorros) / (v_ocu + 1)
    set educ  (v_ocu * educ - esco) / (v_ocu + 1)
    if educ < 0 [
         print (word "seller con educación negativa " s1 " vender-mi-casa")]
      set ingresos (v_ocu * ingresos - ingre) / (v_ocu + 1)
      set v_ocu-1 v_ocu
      set v_ocu v_ocu - 1
      set v_des-2 v_des-1
      set v_des-1 v_des
      set v_des v_des + 1
      set v_propia v_propia - 1
ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
    ifelse t_h = 0 [   set v_r v_r - 1 set ingresos_c  ingresos + p][set v_p v_p - 1 set ingresos_c  ingresos + p]]

  ask seller s2[  let c_s tipo_v
    if v_ocu < 0 [print v_ocu
      stop]
    let esco educ
    let p precio
   let ingre ingresos
   let ahorros ahorro
    set ahorro (v_ocu * ahorro + ahorros) / (v_ocu + 1)
      set educ  (v_ocu * educ + esco) / (v_ocu + 1)
      set ingresos (v_ocu * ingresos + ingre) / (v_ocu + 1)
      set v_ocu-1 v_ocu
      set v_ocu v_ocu + 1
      set v_des-2 v_des-1
      set v_des-1 v_des
      set v_des v_des - 1
      set v_propia v_propia + 1
ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
    ifelse t_h = 0 [   set v_r v_r + 1 set ingresos_c  ingresos + p][set v_p v_p + 1 set ingresos_c  ingresos_c + p]]

end

to pensar-vender

  ask sellers with [v_propia > 0 and distancia_centro <= 6 and precio >= n_p * p0 and v_ocu > 0 ] [
   let s1 who
   let s2 0
   let p_0 p0
    let p1 precio
   let u utilidad_s
   let u' utilidad_promedio_s
   let esco educ
   let ingre ingresos
   let ahorros ahorro
   let w 0
   let prosp 0
   let n 0
    ifelse v_p > v_r [set t_h 1] [set t_h 0]
  set n count (  sellers with [ distancia_centro <= 6 and utilidad_promedio_s > u' and p1 >= precio and v_des > 0 and v_ocu > 0])

    if n > 1 [ set w  max-n-of  n sellers with [   distancia_centro <= 6 and utilidad_promedio_s > u' and p1 >= precio and v_des > 0 and v_ocu > 0] [( utilidad_r)]
    ]
   if w != 0  [
     ask w [ set demanda demanda + 1]
    set prosp sort-on  [(- utilidad_r)]  w
    let s first prosp
  ask s [ set s2 who]
    vender-mi-casa s1 s2
  ]]


end

to contabilidad

  ask sellers[
    let pa precio_a
    let pa0 p0 * 0.01
    let ing_a 0
;  set costos costos + costos
set ing_a v_ocu * pa + v_ocu_a * pa0
  let ing ing_a + ingresos_c
  set ganancias ing - costos
  set ganancias_totales  ganancias_totales + ganancias
   set costos 0

  ]
  set ganancias_promedio mean [ganancias] of sellers
;print ganancias_promedio

end
to histograma [lista]
;  let l0 remove-duplicates lista
;  show length l0
;  show length lista
;  set-current-plot "logaritmo-riqueza"
;  set-current-plot-pen "default"
; ; set-plot-x-range min max
;  foreach l0 [
;    f ->
;    let l1 filter [
;      r -> f = r   ] lista
;    let n length l1
;    show n
;    show f
;    plotxy ln (f) ln(n)
;  ]
;
;


end


to i-gentrificacion
    let ig0 []
    set ig0 lput item 0 item 0 ing_l0 ig0
    set ig0 lput item 0 item 1 ing_l0 ig0
    set ig0 lput item 0 item 2 ing_l0 ig0
    set ig0 lput item 0 item 3 ing_l0 ig0
    set ig0 lput item 0 item 4 ing_l0 ig0
    set ig0 lput item 0 item 5 ing_l0 ig0
    set ig0 lput item 0 item 6 ing_l0 ig0
    let sum_ig0 sum ig0


  let igf []
    set igf lput item 0 item 0 ing_lf igf
    set igf lput item 0 item 1 ing_lf igf
    set igf lput item 0 item 2 ing_lf igf
    set igf lput item 0 item 3 ing_lf igf
    set igf lput item 0 item 4 ing_lf igf
    set igf lput item 0 item 5 ing_lf igf
    set igf lput item 0 item 6 ing_lf igf
  let sum_igf sum igf


set indice_gentrificacion (sum_igf - sum_ig0) / sum_ig0

  print indice_gentrificacion
end

to vivienda-asequible[h]
  let tipoh 0
  ask hogar h [set tipoh th]
  let s1 sellers with [v_des_a > 0 ]
  let s min-one-of s1 [distancia_centro]
  ask s [
    set compra 1
    let pa precio_a
     set transaccion   1
   ;   ask vivienda casa [
    let esco [esc_h] of hogar h
    let ingre [ingresos_h] of hogar h
    let ahorros [ahorro_h] of hogar h
    let c_s [clase_social] of hogar h
      set ahorro (v_ocu * ahorro + ahorros) / (v_ocu + 1)
      set educ  (v_ocu * educ + esco) / (v_ocu + 1)
      set ingresos (v_ocu * ingresos + ingre) / (v_ocu + 1)
      set v_ocu_a v_ocu_a + 1
      set v_des_a v_des_a - 1
      set v_alquiler_a v_alquiler_a + 1
      set vt_a v_ocu_a + v_des_a
      set vt_r v_ocu + v_des
      set vt vt_a + vt_r


ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
 ;   print (word "ya tengo casa rentada en " s "con un precio " precio " con vacantes " v_des " y con demanda_c " demanda )

    ifelse tipoh = 0 [  set v_r v_r + 1  set ingresos_c  ingresos_c + p0][set v_p v_p + 1 set ingresos_c ingresos_c + p0]
  ]

  ask hogar h [die]




end


to asequible-final
  let aseq_des sum [v_des_a] of sellers
  let marginal sum [v_ocu] of sellers with [distancia_centro > 6]
    print (word " hay va asequible final con viviendas asequibles vacantes : " aseq_des "y hogares marginales : " marginal)

  while [aseq_des > 0 and marginal > 0][

  let s1 one-of sellers with [v_p > 0 and distancia_centro > 6]
  let n1 [v_p] of s1

  let s2 one-of sellers with [v_des_a > 0]
  let n2 [v_des_a] of s2
  let ahorro2 [ahorro] of s2
  let educ2 [educ] of s2
  let ingresos2 [ingresos] of s2

   let n 0
  if n1 > 0 [
    ifelse n1 > n2 [set n  n2][set n n1]
   ask  s1[
   set v_ocu v_ocu - n
   set v_p v_p - n]

    ask  s2[
      set ahorro (v_ocu * ahorro + ahorro2) / (v_ocu + 1)
   set educ  (v_ocu * educ + educ2) / (v_ocu + 1)
   set ingresos (v_ocu * ingresos + ingresos2) / (v_ocu + 1)
      set v_des_a v_des_a - n
      set v_ocu_a v_ocu_a + n
      set v_alquiler_a v_alquiler_a
      set vt_a v_ocu_a + v_des_a
      set v_ocu v_ocu + n
      set v_p v_p + n1

      set ingresos_c ingresos_c + p0
      ]

  ]
    set aseq_des sum [v_des_a] of sellers
  set marginal sum [v_ocu] of sellers with [distancia_centro > 6]

  ]


  ;;;;; quedó bien el contador de mudanza de viviendas, falta poner las ganancias de las constructoras
  ;;;;; actualizar el total de viviendas
  ;;;;; checar como funciona tolerancia social



    print (word " termina asequible final con viviendas asequibles vacantes : " aseq_des "y hogares marginales : " marginal)
end

to vivienda-asequible-1  [s1 h]
  let sel sellers with [v_des_a > 0 ]
  let s2 min-one-of sel [distancia_centro]
let tipoh 0
  ask hogar h [set tipoh th]
ask seller s1 [
  ;  set size 1
     set transaccion   1
    set compra 1
   ;   ask vivienda casa [
    let esco [esc_h] of myself
    let ingre [ingresos_h] of myself
    let ahorros [ahorro_h] of myself
    let c_s [clase_social] of myself

    if v_ocu > 1[
      set ahorro (v_ocu * ahorro - ahorros) / (v_ocu - 1)
      set educ  (v_ocu * educ - esco) / (v_ocu - 1)
      if educ < 0 [
         print (word "seller con educación negativa " s1 " vivienda-asequible-1")]
      set ingresos (v_ocu * ingresos - ingre) / (v_ocu - 1)]

      set v_ocu v_ocu
    ;  set mudanzas mudanzas + 1
    if v_ocu < 0 [ print (word "seller con ocupación negativa " s1 " rentar-a1")  ]

      set v_des v_des + 1

      set n_m n_m + 1
    ifelse vt != 0 [set p_m n_m / vt][set p_m 0]
ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
ifelse tipoh = 0 [   set v_r v_r - 1 ][set v_p v_p - 1 ]
  ]



  ask  s2[
    set transaccion   1
  ;  set size 1
   ;   ask vivienda casa [
    let pa precio_a
    let esco [esc_h] of myself
    let ingre [ingresos_h] of myself
    let ahorros [ahorro_h] of myself
    let c_s [clase_social] of myself

      set ahorro (v_ocu * ahorro + ahorros) / (v_ocu + 1)
      set educ  (v_ocu * educ + esco) / (v_ocu + 1)
      set ingresos (v_ocu * ingresos + ingre) / (v_ocu + 1)

      set v_ocu_a v_ocu_a + 1
      set v_des_a v_des_a - 1
      set v_alquiler_a v_alquiler_a + 1
       set vt_a v_ocu_a + v_des_a
      set vt_r v_ocu + v_des
      set vt vt_a + vt_r

ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
    ;print (word "vengo de rentar en " s1 " y  ya tengo casa rentada en " s2 "con un precio " precio " con vacantes " v_des " y con demanda " demanda )

    ifelse tipoh = 0 [   set v_r v_r + 1  set ingresos_c ingresos_c + p0][set v_p v_p + 1 set ingresos_c ingresos_c + p0]
  ]
 ; ask hogar h [if clase_social = "alta" [ print (word " rico de" s1 " se va a "  s2) ask s2 [set size 1]]]

  ask hogar h [die]




end


to vivienda-asequible-2  [s1 h]
  let sel sellers with [v_des_a > 0 ]
  let s2 min-one-of sel [distancia_centro]
  ifelse s2 != nobody [
let tipoh 0
  ask hogar h [set tipoh th]
ask seller s1 [
  ;  set size 1
     set transaccion   1
    set compra 1
   ;   ask vivienda casa [
    let esco [esc_h] of myself
    let ingre [ingresos_h] of myself
    let ahorros [ahorro_h] of myself
    let c_s [clase_social] of myself

    if v_ocu > 1[
      set ahorro (v_ocu * ahorro - ahorros) / (v_ocu - 1)
      set educ  (v_ocu * educ - esco) / (v_ocu - 1)
      if educ < 0 [
         print (word "seller con educación negativa " s1 " vivienda-asequible-1")]
      set ingresos (v_ocu * ingresos - ingre) / (v_ocu - 1)]

      set v_ocu v_ocu
    ;  set mudanzas mudanzas + 1
    if v_ocu < 0 [ print (word "seller con ocupación negativa " s1 " rentar-a1")  ]

      set v_des v_des + 1

      set n_m n_m + 1
    ifelse vt != 0 [set p_m n_m / vt][set p_m 0]
ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
;ifelse tipoh = 0 [   set v_r v_r - 1 ][set v_p v_p - 1 ]
  ]



  ask  s2[
    set transaccion   1
  ;  set size 1
   ;   ask vivienda casa [
    let pa precio_a
    let esco [esc_h] of myself
    let ingre [ingresos_h] of myself
    let ahorros [ahorro_h] of myself
    let c_s [clase_social] of myself

      set ahorro (v_ocu * ahorro + ahorros) / (v_ocu + 1)
      set educ  (v_ocu * educ + esco) / (v_ocu + 1)
      set ingresos (v_ocu * ingresos + ingre) / (v_ocu + 1)

      set v_ocu_a v_ocu_a + 1
      set v_des_a v_des_a - 1
      set v_alquiler_a v_alquiler_a + 1
       set vt_a v_ocu_a + v_des_a
      set vt_r v_ocu + v_des
      set vt vt_a + vt_r

ifelse area_s > 0 [ set densidad_s (vt / area_s)]
                      [set densidad_s  vt / 1]
    ;print (word "vengo de rentar en " s1 " y  ya tengo casa rentada en " s2 "con un precio " precio " con vacantes " v_des " y con demanda " demanda )

    ifelse tipoh = 0 [   set v_r v_r + 1  set ingresos_c ingresos_c + p0][set v_p v_p + 1 set ingresos_c ingresos_c + p0]
  ]
 ; ask hogar h [if clase_social = "alta" [ print (word " rico de" s1 " se va a "  s2) ask s2 [set size 1]]]

    ask hogar h [die]]
  [ask hogar h [die]]





end


to probando-asequible
  let s sellers with [v_des_a > 0 ]
  ask s [set size 1]
  let s1 min-one-of s [distancia_centro]
  ask s1 [set size 2]

end
@#$#@#$#@
GRAPHICS-WINDOW
233
16
538
322
-1
-1
22.91
1
10
1
1
1
0
1
1
1
-6
6
-6
6
0
0
1
ticks
30.0

INPUTBOX
107
164
157
224
sub
0.0
1
0
Number

INPUTBOX
10
88
74
148
viv_max
150.0
1
0
Number

INPUTBOX
10
156
74
216
nuevos-hogares
15.0
1
0
Number

BUTTON
111
10
174
43
NIL
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

BUTTON
156
51
228
84
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1221
568
1271
613
hogares
count hogares
17
1
11

PLOT
908
149
1068
269
Hist. Precio de las viviendas
Precio
No. Manzanas
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range (min [precio] of sellers)  (max [precio] of sellers)\nset-plot-y-range 0 count sellers\nset-histogram-num-bars 7" "set-plot-x-range (min [precio] of sellers)  (max [precio] of sellers)\nset-plot-y-range 0 count sellers\nset-histogram-num-bars 10"
PENS
"default" 1.0 1 -13791810 true "" " histogram [precio ] of sellers"

PLOT
909
273
1069
393
Histograma-Ingresos
Ingresos
Manzanas
0.0
10000.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -13791810 true "" ""

PLOT
904
15
1074
135
Histograma Viviendas vacantes
No. Viviendas vacantes
Manzanas
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range (min [v_des] of sellers)  (max [v_des] of sellers)\nset-plot-y-range 0 count sellers\nset-histogram-num-bars 10" ""
PENS
"default" 1.0 1 -13791810 true "" "histogram [v_des] of sellers"

MONITOR
993
568
1069
613
precio promedio
mean [precio] of sellers
2
1
11

MONITOR
881
561
979
606
viviendas vacante máxima
sum [v_des] of sellers
17
1
11

MONITOR
1090
566
1198
611
ingreso promedio
mean[ingresos] of sellers
2
1
11

MONITOR
413
336
524
381
total de viviendas
sum [vt] of sellers
2
1
11

PLOT
1095
273
1255
393
Precio Prom
tiempo
pesos
0.0
10.0
0.0
10.0
true
false
"\n" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [precio] of sellers"

BUTTON
83
55
138
88
step
go
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
1097
147
1257
267
viivendas vacantes
tiempo
viviendas
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"V Desocupadad" 1.0 0 -16777216 true "" "plot count sellers with [v_des > 0]"

INPUTBOX
87
93
143
153
elast-p-o
0.0
1
0
Number

PLOT
1098
13
1258
133
Densidad
Densidad
No. Manzanas
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range (min [densidad_s] of sellers)  (max [densidad_s] of sellers)\nset-plot-y-range 0 count sellers\nset-histogram-num-bars 10" "set-plot-x-range (min [densidad_s] of sellers)  (max [densidad_s] of sellers)\nset-plot-y-range 0 count sellers\nset-histogram-num-bars 10"
PENS
"default" 1.0 1 -16777216 true "" "histogram [densidad_s] of sellers"

PLOT
741
279
901
399
Ingreso prom
Dstancia
Ingreso promedio
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -14439633 true "" "plot-pen-reset\nlet n 7\nlet li 0\n   set li  n-values n [ i -> i  ]\nforeach li [[t] -> plotxy item 0 item t d_l item 0 item t ing_l]"

PLOT
728
17
888
137
Población total
 Distancia
Población prom
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -14439633 true "" "plot-pen-reset\nlet n 7\nlet li 0\n   set li  n-values n [ i -> i  ]\nforeach li [[t] -> plotxy item 0 item t d_l item 0 item t pob_l]"

PLOT
558
150
718
270
Subsidio
tiempo
pesos
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot [subsidio] of gobierno 0"

MONITOR
275
337
378
382
Hogares Totales
sum [v_ocu] of sellers
0
1
11

PLOT
732
150
892
270
Precio Promedio
Distancia
Precio Prom.
0.0
10.0
0.0
10.0
true
false
"" "set-plot-y-range 0 mean[precio] of sellers"
PENS
"default" 1.0 1 -14439633 true "" "plot-pen-reset\nlet n 7\nlet li 0\n   set li  n-values n [ i -> i  ]\nforeach li [[t] -> plotxy item 0 item t d_l item 0 item t precio_l]"

SLIDER
2
355
94
388
pje_u
pje_u
0
1
0.1
0.1
1
NIL
HORIZONTAL

INPUTBOX
8
226
89
289
densidad_maxima
150.0
1
0
Number

PLOT
553
16
722
136
plot 1
tiempo
No. Viviendas
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Propia" 1.0 0 -5825686 true "" "plot sum [v_propia] of sellers"
"Alquiler" 1.0 0 -10649926 true "" "plot sum [v_alquiler] of sellers"

SWITCH
577
666
712
699
gen_vivienda?
gen_vivienda?
1
1
-1000

SWITCH
579
701
687
734
cluster?
cluster?
0
1
-1000

MONITOR
346
639
472
684
encontrangdo hogar
sol_hogar
1
1
11

MONITOR
670
563
739
608
mudanzas
mudanzas
2
1
11

SLIDER
-3
315
91
348
pje_al
pje_al
0
1
0.3
0.1
1
NIL
HORIZONTAL

SWITCH
124
377
227
410
save?
save?
1
1
-1000

SWITCH
124
424
256
457
choque-ingresos?
choque-ingresos?
1
1
-1000

BUTTON
232
597
355
630
NIL
choque-ingresos
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1283
568
1340
613
max_vt
max[vt] of sellers
1
1
11

MONITOR
566
457
650
502
Subsidio
[subsidio] of gobierno 0
17
1
11

MONITOR
411
551
527
596
hogares_marginados
sum [v_ocu] of sellers with [distancia_centro > 6]
1
1
11

MONITOR
534
549
642
594
Hogares urbanos
sum [v_ocu] of sellers with [distancia_centro <= 6]
17
1
11

MONITOR
116
671
290
716
Gasto en compra de terrenos
[gasto_compra] of gobierno 0
2
1
11

PLOT
557
277
723
397
Ganancias Promedio
tiempo
pesos
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot ganancias_promedio"

SWITCH
124
469
272
502
expropiar-espacios?
expropiar-espacios?
1
1
-1000

SLIDER
0
599
137
632
MeanIncome
MeanIncome
5000
20000
10000.0
2500
1
NIL
HORIZONTAL

SLIDER
2
557
102
590
y_0
y_0
5000
15000
8000.0
500
1
NIL
HORIZONTAL

BUTTON
987
438
1050
471
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
897
437
960
470
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
811
439
874
472
NIL
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

MONITOR
744
621
877
666
manzanas con ventas
count  sellers with [(v_ocu - v_ocu-1) = 0]
17
1
11

SWITCH
583
739
686
772
rigido?
rigido?
0
1
-1000

MONITOR
1103
426
1174
471
residencial
count sellers with [v_r > v_p]
17
1
11

SLIDER
1
391
109
424
n_p
n_p
1.5
10
2.0
0.5
1
NIL
HORIZONTAL

PLOT
1274
13
1434
133
graf3
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range (min [ingresos] of sellers)  (max [ingresos] of sellers)\nset-plot-y-range 0 count sellers\nset-histogram-num-bars 10" "set-plot-x-range (min [ingresos] of sellers)  (max [ingresos] of sellers)\nset-plot-y-range 0 count sellers\nset-histogram-num-bars 10"
PENS
"default" 1.0 1 -16777216 true "" "histogram [ingresos] of sellers"

INPUTBOX
109
225
188
285
tiempo
500.0
1
0
Number

PLOT
1275
160
1457
310
Gentrificación
Distancia
Ingresos
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Final" 1.0 1 -13840069 true "" "plot-pen-reset\n\nlet n 7\nlet li 0\n   set li  n-values n [ i -> i  ]\nforeach li [[t] -> plotxy item 0 item t d_lf item 0 item t ing_lf]\n"
"Inicial" 1.0 1 -13345367 true "" "plot-pen-reset\n\nlet n 7\nlet li 0\n   set li  n-values n [ i -> i  ]\nforeach li [[t] -> plotxy item 0 item t d_l0 item 0 item t ing_l0]\n"

SLIDER
-5
435
106
468
alfa
alfa
0
1
0.4
0.1
1
NIL
HORIZONTAL

SWITCH
272
545
408
578
viv_asequible?
viv_asequible?
0
1
-1000

MONITOR
441
492
553
537
Gasto en vivienda
sum [gasto_compra] of gobiernos
1
1
11

PLOT
1279
329
1479
479
plot 2
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Residencial" 1.0 1 -11221820 true "" "plot-pen-reset\n\nlet n 7\nlet li 0\n   set li  n-values n [ i -> i  ]\nforeach li [[t] -> plotxy item 0 item t d_lf item 0 item t pob_r]\n"
"Popular" 1.0 1 -955883 true "" "plot-pen-reset\n\nlet n 7\nlet li 0\n   set li  n-values n [ i -> i  ]\nforeach li [[t] -> plotxy item 0 item t d_lf item 0 item t pob_s]"

MONITOR
723
481
780
526
vr
sum[v_r] of sellers
17
1
11

MONITOR
796
484
853
529
vp
sum[v_p] of sellers
17
1
11

MONITOR
310
436
436
481
NIL
ganancias_promedio
17
1
11

SLIDER
-1
480
108
513
tolerancia_alquiler
tolerancia_alquiler
0
1
0.9
0.1
1
NIL
HORIZONTAL

SLIDER
-1
519
108
552
tolerancia_social
tolerancia_social
0
1
0.2
0.1
1
NIL
HORIZONTAL

MONITOR
301
494
428
539
vivienda total asequible
sum [vt_a] of sellers
17
1
11

BUTTON
40
12
103
45
go1
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

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
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment1" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="save?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="n_p" first="1.5" step="0.5" last="4"/>
    <steppedValueSet variable="pje_u" first="0.2" step="0.2" last="1"/>
    <steppedValueSet variable="alfa" first="0.3" step="0.1" last="0.8"/>
    <enumeratedValueSet variable="nuevos-hogares">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gen_vivienda?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="viv_max">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="densidad_maxima">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pje_al">
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.4"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="choque-ingresos?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Normal" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="save?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nuevos-hogares">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MeanIncome">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gen_vivienda?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rigido?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="viv_max">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="densidad_maxima">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="y_0">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="viv_asequible?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="expropiar-espacios?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="choque-ingresos?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="pje_al" first="0.3" step="0.1" last="0.6"/>
    <enumeratedValueSet variable="n_p">
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="pje_u" first="0.1" step="0.2" last="0.9"/>
    <steppedValueSet variable="tolerancia_social" first="0.1" step="0.2" last="0.9"/>
    <steppedValueSet variable="tolerancia_alquiler" first="0.1" step="0.2" last="0.9"/>
  </experiment>
  <experiment name="Choque_Ingresos" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="save?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nuevos-hogares">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="viv_max">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="densidad_maxima">
      <value value="150"/>
    </enumeratedValueSet>
    <steppedValueSet variable="pje_al" first="0.3" step="0.1" last="0.6"/>
    <enumeratedValueSet variable="y_0">
      <value value="8000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="tolerancia_social" first="0" step="0.2" last="1"/>
    <steppedValueSet variable="pje_u" first="0" step="0.2" last="1"/>
    <enumeratedValueSet variable="MeanIncome">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gen_vivienda?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rigido?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="tolerancia_alquiler" first="0" step="0.2" last="1"/>
    <enumeratedValueSet variable="cluster?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="choque-ingresos?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="expropiar-espacios?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="viv_asequible?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n_p">
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Expropiar" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="save?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nuevos-hogares">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="viv_max">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="expropiar-espacios?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="densidad_maxima">
      <value value="150"/>
    </enumeratedValueSet>
    <steppedValueSet variable="pje_al" first="0.3" step="0.1" last="0.6"/>
    <enumeratedValueSet variable="y_0">
      <value value="8000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="tolerancia_social" first="0" step="0.2" last="1"/>
    <steppedValueSet variable="pje_u" first="0" step="0.2" last="1"/>
    <enumeratedValueSet variable="viv_asequible?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MeanIncome">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gen_vivienda?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rigido?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="tolerancia_alquiler" first="0" step="0.2" last="1"/>
    <enumeratedValueSet variable="cluster?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="choque-ingresos?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Asequible" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="save?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nuevos-hogares">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MeanIncome">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gen_vivienda?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rigido?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cluster?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="viv_max">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="densidad_maxima">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="y_0">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="viv_asequible?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="expropiar-espacios?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="choque-ingresos?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="pje_al" first="0.3" step="0.1" last="0.6"/>
    <enumeratedValueSet variable="n_p">
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="pje_u" first="0.1" step="0.2" last="0.9"/>
    <steppedValueSet variable="tolerancia_social" first="0.1" step="0.2" last="0.9"/>
    <steppedValueSet variable="tolerancia_alquiler" first="0.1" step="0.2" last="0.9"/>
    <enumeratedValueSet variable="alfa">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.4"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
