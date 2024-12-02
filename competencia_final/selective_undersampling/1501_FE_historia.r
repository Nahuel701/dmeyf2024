#!/usr/bin/env Rscript
cat( "ETAPA  z1501_FE_historia.r  INIT\n")

# Workflow  Feature Engineering historico

# inputs
#  * gran dataset
#  * especificaciones de nuevos atributos historicos
# output  
#   muuuy gran dataset :
#     misma cantidad de registros
#     los valores de los campos no se modifican
#     agregado de nuevos atributos, basados en la historia


# limpio la memoria
rm(list = ls(all.names = TRUE)) # remove all objects
gc(full = TRUE, verbose= FALSE) # garbage collection

require("data.table", quietly=TRUE)
require("yaml", quietly=TRUE)
require("Rcpp", quietly=TRUE)

#cargo la libreria
# args <- c( "~/labo2024ba" )
args <- commandArgs(trailingOnly=TRUE)
source( paste0( args[1] , "/src/lib/action_lib.r" ) )

#------------------------------------------------------------------------------
# se calculan para los 6 meses previos el minimo, maximo y
#  tendencia calculada con cuadrados minimos
# la formula de calculo de la tendencia puede verse en
#  https://stats.libretexts.org/Bookshelves/Introductory_Statistics/Book%3A_Introductory_Statistics_(Shafer_and_Zhang)/10%3A_Correlation_and_Regression/10.04%3A_The_Least_Squares_Regression_Line
# para la maxíma velocidad esta funcion esta escrita en lenguaje C,
# y no en la porqueria de R o Python

cppFunction("NumericVector fhistC(NumericVector pcolumna, IntegerVector pdesde )
{
  /* Aqui se cargan los valores para la regresion */
  double  x[100] ;
  double  y[100] ;

  int n = pcolumna.size();
  NumericVector out( 5*n );

  for(int i = 0; i < n; i++)
  {
    //lag
    if( pdesde[i]-1 < i )  out[ i + 4*n ]  =  pcolumna[i-1] ;
    else                   out[ i + 4*n ]  =  NA_REAL ;


    int  libre    = 0 ;
    int  xvalor   = 1 ;

    for( int j= pdesde[i]-1;  j<=i; j++ )
    {
       double a = pcolumna[j] ;

       if( !R_IsNA( a ) )
       {
          y[ libre ]= a ;
          x[ libre ]= xvalor ;
          libre++ ;
       }

       xvalor++ ;
    }

    /* Si hay al menos dos valores */
    if( libre > 1 )
    {
      double  xsum  = x[0] ;
      double  ysum  = y[0] ;
      double  xysum = xsum * ysum ;
      double  xxsum = xsum * xsum ;
      double  vmin  = y[0] ;
      double  vmax  = y[0] ;

      for( int h=1; h<libre; h++)
      {
        xsum  += x[h] ;
        ysum  += y[h] ;
        xysum += x[h]*y[h] ;
        xxsum += x[h]*x[h] ;

        if( y[h] < vmin )  vmin = y[h] ;
        if( y[h] > vmax )  vmax = y[h] ;
      }

      out[ i ]  =  (libre*xysum - xsum*ysum)/(libre*xxsum -xsum*xsum) ;
      out[ i + n ]    =  vmin ;
      out[ i + 2*n ]  =  vmax ;
      out[ i + 3*n ]  =  ysum / libre ;
    }
    else
    {
      out[ i       ]  =  NA_REAL ;
      out[ i + n   ]  =  NA_REAL ;
      out[ i + 2*n ]  =  NA_REAL ;
      out[ i + 3*n ]  =  NA_REAL ;
    }
  }

  return  out;
}")

#------------------------------------------------------------------------------
# calcula la tendencia de las variables cols de los ultimos 6 meses
# la tendencia es la pendiente de la recta que ajusta por cuadrados minimos
# La funcionalidad de ratioavg es autoria de  Daiana Sparta,  UAustral  2021

TendenciaYmuchomas <- function(
    dataset, cols, ventana = 6, tendencia = TRUE,
    minimo = TRUE, maximo = TRUE, promedio = TRUE,
    ratioavg = FALSE, ratiomax = FALSE) {
  gc(verbose= FALSE)
  # Esta es la cantidad de meses que utilizo para la historia
  ventana_regresion <- ventana

  last <- nrow(dataset)

  # creo el vector_desde que indica cada ventana
  # de esta forma se acelera el procesamiento ya que lo hago una sola vez
  vector_ids <- dataset[ , get( envg$PARAM$dataset_metadata$entity_id) ]

  vector_desde <- seq(
    -ventana_regresion + 2,
    nrow(dataset) - ventana_regresion + 1
  )

  vector_desde[1:ventana_regresion] <- 1

  for (i in 2:last) {
    if (vector_ids[i - 1] != vector_ids[i]) {
      vector_desde[i] <- i
    }
  }
  for (i in 2:last) {
    if (vector_desde[i] < vector_desde[i - 1]) {
      vector_desde[i] <- vector_desde[i - 1]
    }
  }

  for (campo in cols) {
    nueva_col <- fhistC(dataset[, get(campo)], vector_desde)

    if (tendencia) {
      dataset[, paste0(campo, "_tend", ventana) :=
        nueva_col[(0 * last + 1):(1 * last)]]
    }

    if (minimo) {
      dataset[, paste0(campo, "_min", ventana) :=
        nueva_col[(1 * last + 1):(2 * last)]]
    }

    if (maximo) {
      dataset[, paste0(campo, "_max", ventana) :=
        nueva_col[(2 * last + 1):(3 * last)]]
    }

    if (promedio) {
      dataset[, paste0(campo, "_avg", ventana) :=
        nueva_col[(3 * last + 1):(4 * last)]]
    }

    if (ratioavg) {
      dataset[, paste0(campo, "_ratioavg", ventana) :=
        get(campo) / nueva_col[(3 * last + 1):(4 * last)]]
    }

    if (ratiomax) {
      dataset[, paste0(campo, "_ratiomax", ventana) :=
        get(campo) / nueva_col[(2 * last + 1):(3 * last)]]
    }
  }
}
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# Aqui empieza el programa
cat( "ETAPA  z1501_FE_historia.r  START\n")
action_inicializar() 

# cargo el dataset donde voy a entrenar
# esta en la carpeta del exp_input y siempre se llama  dataset.csv.gz
# cargo el dataset
envg$PARAM$dataset <- paste0( "./", envg$PARAM$input, "/dataset.csv.gz" )
envg$PARAM$dataset_metadata <- read_yaml( paste0( "./", envg$PARAM$input, "/dataset_metadata.yml" ) )

cat( "lectura del dataset\n")
action_verificar_archivo( envg$PARAM$dataset )
cat( "Iniciando lectura del dataset\n" )
dataset <- fread(envg$PARAM$dataset)
cat( "Finalizada lectura del dataset\n" )


colnames(dataset)[which(!(sapply(dataset, typeof) %in% c("integer", "double")))]


GrabarOutput()

#--------------------------------------
# estas son las columnas a las que se puede agregar
#  lags o media moviles ( todas menos las obvias )

campitos <- c( envg$PARAM$dataset_metadata$primarykey,
  envg$PARAM$dataset_metadata$entity_id,
  envg$PARAM$dataset_metadata$periodo,
  envg$PARAM$dataset_metadata$clase )

campitos <- unique( campitos )

cols_lagueables <- copy(setdiff(
  colnames(dataset),
  envg$PARAM$dataset_metadata
))

# ordeno el dataset por primary key
#  es MUY  importante esta linea
# ordeno dataset
setorderv(dataset, envg$PARAM$dataset_metadata$primarykey)


if (envg$PARAM$lag1) {
  cat( "Inicio lag1\n")
  # creo los campos lags de orden 1
  envg$OUTPUT$lag1$ncol_antes <- ncol(dataset)
  dataset[, paste0(cols_lagueables, "_lag1") := shift(.SD, 1, NA, "lag"),
    by = eval( envg$PARAM$dataset_metadata$entity_id),
    .SDcols = cols_lagueables
  ]

  # agrego los delta lags de orden 1
  for (vcol in cols_lagueables)
  {
    dataset[, paste0(vcol, "_delta1") := get(vcol) - get(paste0(vcol, "_lag1"))]
  }

  envg$OUTPUT$lag1$ncol_despues <- ncol(dataset)
  GrabarOutput()
  cat( "Fin lag1\n")
}


cols_lagueables <- intersect(cols_lagueables, colnames(dataset))
if (envg$PARAM$lag2) {
  cat( "Inicio lag2\n")
  # creo los campos lags de orden 2
  envg$OUTPUT$lag2$ncol_antes <- ncol(dataset)
  dataset[, paste0(cols_lagueables, "_lag2") := shift(.SD, 2, NA, "lag"),
    by = eval(envg$PARAM$dataset_metadata$entity_id),
    .SDcols = cols_lagueables
  ]

  # agrego los delta lags de orden 2
  for (vcol in cols_lagueables)
  {
    dataset[, paste0(vcol, "_delta2") := get(vcol) - get(paste0(vcol, "_lag2"))]
  }

  envg$OUTPUT$lag2$ncol_despues <- ncol(dataset)
  GrabarOutput()
  cat( "Fin lag2\n")
}


cols_lagueables <- intersect(cols_lagueables, colnames(dataset))
if (envg$PARAM$lag3) {
  cat( "Inicio lag3\n")
  # creo los campos lags de orden 3
  envg$OUTPUT$lag3$ncol_antes <- ncol(dataset)
  dataset[, paste0(cols_lagueables, "_lag3") := shift(.SD, 3, NA, "lag"),
    by = eval(envg$PARAM$dataset_metadata$entity_id),
    .SDcols = cols_lagueables
  ]

  # agrego los delta lags de orden 3
  for (vcol in cols_lagueables)
  {
    dataset[, paste0(vcol, "_delta3") := get(vcol) - get(paste0(vcol, "_lag3"))]
  }

  envg$OUTPUT$lag3$ncol_despues <- ncol(dataset)
  GrabarOutput()
  cat( "Fin lag3\n")
}


#--------------------------------------
# agrego las tendencias

# ordeno el dataset por primary key
#  es MUY  importante esta linea
cat( "ordenado dataset\n")
setorderv(dataset, envg$PARAM$dataset_metadata$primarykey)

cols_lagueables <- intersect(cols_lagueables, colnames(dataset))
if (envg$PARAM$Tendencias1$run) {
  envg$OUTPUT$TendenciasYmuchomas1$ncol_antes <- ncol(dataset)
  TendenciaYmuchomas(dataset,
    cols = cols_lagueables,
    ventana = envg$PARAM$Tendencias1$ventana, # 6 meses de historia
    tendencia = envg$PARAM$Tendencias1$tendencia,
    minimo = envg$PARAM$Tendencias1$minimo,
    maximo = envg$PARAM$Tendencias1$maximo,
    promedio = envg$PARAM$Tendencias1$promedio,
    ratioavg = envg$PARAM$Tendencias1$ratioavg,
    ratiomax = envg$PARAM$Tendencias1$ratiomax
  )

  envg$OUTPUT$TendenciasYmuchomas1$ncol_despues <- ncol(dataset)
  GrabarOutput()
}


cols_lagueables <- intersect(cols_lagueables, colnames(dataset))
if (envg$PARAM$Tendencias2$run) {
  envg$OUTPUT$TendenciasYmuchomas2$ncol_antes <- ncol(dataset)
  TendenciaYmuchomas(dataset,
    cols = cols_lagueables,
    ventana = envg$PARAM$Tendencias2$ventana, # 6 meses de historia
    tendencia = envg$PARAM$Tendencias2$tendencia,
    minimo = envg$PARAM$Tendencias2$minimo,
    maximo = envg$PARAM$Tendencias2$maximo,
    promedio = envg$PARAM$Tendencias2$promedio,
    ratioavg = envg$PARAM$Tendencias2$ratioavg,
    ratiomax = envg$PARAM$Tendencias2$ratiomax
  )

  envg$OUTPUT$TendenciasYmuchomas2$ncol_despues <- ncol(dataset)
  GrabarOutput()
}
#------------------------------------------------------------------------------
# .=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-.
# |                     ______                     |
# |                  .-"      "-.                  |
# |                 /            \                 |
# |     _          |              |          _     |
# |    ( \         |,  .-.  .-.  ,|         / )    |
# |     > "=._     | )(__/  \__)( |     _.=" <     |
# |    (_/"=._"=._ |/     /\     \| _.="_.="\_)    |
# |           "=._"(_     ^^     _)"_.="           |
# |               "=\__|IIIIII|__/="               |
# |              _.="| \IIIIII/ |"=._              |
# |    _     _.="_.="\          /"=._"=._     _    |
# |   ( \_.="_.="     `--------`     "=._"=._/ )   |
# |    > _.="                            "=._ <    |
# |   (_/   jgs                              \_)   |
# |                                                |
# '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-='


target_df <- dataset[dataset$foto_mes == 201901, ]
include_columns = c(
  'Master_Finiciomora','Master_Fvencimiento','Master_cadelantosefectivo','Master_cconsumos','Master_delinquency','Master_madelantodolares','Master_madelantopesos','Master_mconsumosdolares','Master_mconsumospesos','Master_mconsumototal','Master_mfinanciacion_limite','Master_mlimitecompra','Master_mpagado','Master_mpagominimo','Master_mpagosdolares','Master_mpagospesos','Master_msaldodolares','Master_msaldopesos','Master_msaldototal','Master_status','Visa_Finiciomora','Visa_Fvencimiento','Visa_cadelantosefectivo','Visa_cconsumos','Visa_delinquency','Visa_madelantodolares','Visa_madelantopesos','Visa_mconsumosdolares','Visa_mconsumospesos','Visa_mconsumototal','Visa_mfinanciacion_limite','Visa_mlimitecompra','Visa_mpagado','Visa_mpagominimo','Visa_mpagosdolares','Visa_mpagospesos','Visa_msaldodolares','Visa_msaldopesos','Visa_msaldototal','Visa_status','catm_trx','catm_trx_other','ccaja_ahorro','ccaja_seguridad','ccajas_consultas','ccajas_depositos','ccajas_extracciones','ccajas_otras','ccajas_transacciones','ccajeros_propios_descuentos','ccallcenter_transacciones','ccheques_depositados','ccheques_depositados_rechazados','ccheques_emitidos','ccheques_emitidos_rechazados','ccomisiones_mantenimiento','ccomisiones_otras','ccuenta_corriente','ccuenta_debitos_automaticos','cdescubierto_preacordado','cextraccion_autoservicio','cforex','cforex_buy','cforex_sell','chomebanking_transacciones','cinversion1','cinversion2','cliente_antiguedad','cliente_edad','cliente_vip','cmobile_app_trx','cpagodeservicios','cpagomiscuentas','cpayroll2_trx','cpayroll_trx','cplazo_fijo','cprestamos_hipotecarios','cprestamos_personales','cprestamos_prendarios','cproductos','cseguro_accidentes_personales','cseguro_auto','cseguro_vida','cseguro_vivienda','ctarjeta_debito','ctarjeta_debito_transacciones','ctarjeta_master','ctarjeta_master_debitos_automaticos','ctarjeta_master_descuentos','ctarjeta_master_transacciones','ctarjeta_visa','ctarjeta_visa_debitos_automaticos','ctarjeta_visa_descuentos','ctarjeta_visa_transacciones','ctransferencias_emitidas','ctransferencias_recibidas','ctrx_quarter','internet','mactivos_margen','matm','matm_other','mautoservicio','mcaja_ahorro','mcaja_ahorro_adicional','mcaja_ahorro_dolares','mcajeros_propios_descuentos','mcheques_depositados','mcheques_depositados_rechazados','mcheques_emitidos','mcheques_emitidos_rechazados','mcomisiones','mcomisiones_mantenimiento','mcomisiones_otras','mcuenta_corriente','mcuenta_corriente_adicional','mcuenta_debitos_automaticos','mcuentas_saldo','mextraccion_autoservicio','mforex_buy','mforex_sell','minversion1_dolares','minversion1_pesos','minversion2','mpagodeservicios','mpagomiscuentas','mpasivos_margen','mpayroll','mpayroll2','mplazo_fijo_dolares','mplazo_fijo_pesos','mprestamos_hipotecarios','mprestamos_personales','mprestamos_prendarios','mrentabilidad','mrentabilidad_annual','mtarjeta_master_consumo','mtarjeta_master_descuentos','mtarjeta_visa_consumo','mtarjeta_visa_descuentos','mtransferencias_emitidas','mtransferencias_recibidas','mttarjeta_master_debitos_automaticos','mttarjeta_visa_debitos_automaticos','tcallcenter','tcuentas','thomebanking','tmobile_app'
) 

# Filtrar las columnas a incluir que sean numéricas
numeric_cols <- intersect(names(target_df)[sapply(target_df, is.numeric)], include_columns)

# Crear una máscara inicial para mantener todas las filas
keep_mask <- rep(TRUE, nrow(dataset))

# Iterar sobre las columnas numéricas seleccionadas
for (col in numeric_cols) {
  if (col %in% names(dataset)) {
    # Calcular los umbrales mínimo y máximo
    min_threshold <- min(target_df[[col]], na.rm = TRUE) - abs(min(target_df[[col]], na.rm = TRUE) * 0.2)
    max_threshold <- max(target_df[[col]], na.rm = TRUE) + abs(max(target_df[[col]], na.rm = TRUE) * 0.2)
    
    # Crear una máscara para los valores dentro del rango o NA
    mask <- (dataset[[col]] >= min_threshold & dataset[[col]] <= max_threshold) | is.na(dataset[[col]])
    keep_mask <- keep_mask & mask
  }
}

# Modificar el dataset globalmente
dataset <<- dataset[keep_mask, ]


#------------------------------------------------------------------------------

# grabo el dataset
cat( "grabado dataset\n")
cat( "Iniciando grabado del dataset\n" )
fwrite(dataset,
  file = "dataset.csv.gz",
  logical01 = TRUE,
  sep = ","
)
cat( "Finalizado grabado del dataset\n" )

# copia la metadata sin modificar
cat( "grabado metadata\n")
write_yaml( envg$PARAM$dataset_metadata, 
  file="dataset_metadata.yml" )

#------------------------------------------------------------------------------

# guardo los campos que tiene el dataset
tb_campos <- as.data.table(list(
  "pos" = 1:ncol(dataset),
  "campo" = names(sapply(dataset, class)),
  "tipo" = sapply(dataset, class),
  "nulos" = sapply(dataset, function(x) {
    sum(is.na(x))
  }),
  "ceros" = sapply(dataset, function(x) {
    sum(x == 0, na.rm = TRUE)
  })
))

fwrite(tb_campos,
  file = "dataset.campos.txt",
  sep = "\t"
)

#------------------------------------------------------------------------------
cat( "Fin del programa\n")
envg$OUTPUT$dataset$ncol <- ncol(dataset)
envg$OUTPUT$dataset$nrow <- nrow(dataset)

envg$OUTPUT$time$end <- format(Sys.time(), "%Y%m%d %H%M%S")
GrabarOutput()

#------------------------------------------------------------------------------
# finalizo la corrida
#  archivos tiene a los files que debo verificar existen para no abortar

action_finalizar( archivos = c("dataset.csv.gz","dataset_metadata.yml")) 
cat( "ETAPA  z1501_FE_historia.r  END\n")
