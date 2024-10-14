monto_columns = [
'mrentabilidad', 'mrentabilidad_annual', 'mcomisiones', 
    'mcomisiones_mantenimiento', 'mcomisiones_otras',
    'mpayroll', 'mpayroll2',
     'mcuenta_corriente', 'mcuenta_corriente_adicional',
     'mcaja_ahorro', 
     'mcaja_ahorro_adicional', 'mcaja_ahorro_dolares', 'mcuentas_saldo',
    #  'mprestamos_personales', 
     'cprestamos_prendarios', 'mprestamos_prendarios',
    'mprestamos_hipotecarios', 'mplazo_fijo_pesos','minversion1_pesos',
    'minversion2','mforex_sell','mforex_buy', 'mplazo_fijo_dolares', 'minversion1_dolares',
    'mautoservicio','mcuenta_debitos_automaticos','mttarjeta_visa_debitos_automaticos',
    'mttarjeta_master_debitos_automaticos','mpagodeservicios','mpagomiscuentas',
    'mcajeros_propios_descuentos','mtarjeta_visa_descuentos','mtarjeta_master_descuentos',
    'mcheques_depositados','mcheques_emitidos','mtransferencias_recibidas','mtransferencias_emitidas',
    'mcheques_depositados_rechazados','mcheques_emitidos_rechazados',
    'matm','matm_other','mextraccion_autoservicio',
    'Master_mfinanciacion_limite', 'Visa_mfinanciacion_limite',
    'Master_mlimitecompra', 'Visa_mlimitecompra',
        'Master_mpagado', 'Visa_mpagado',
    'Master_mpagospesos', 'Visa_mpagospesos',
    'Master_mpagosdolares', 'Visa_mpagosdolares',
    'Master_mpagominimo', 'Visa_mpagominimo',
        'Master_madelantopesos', 'Visa_madelantopesos',
    'Master_madelantodolares', 'Visa_madelantodolares',
    'Master_cadelantosefectivo', 'Visa_cadelantosefectivo',
    'mtarjeta_visa_consumo',
    'mtarjeta_master_consumo',
    'Master_mconsumospesos', 'Visa_mconsumospesos',
    'Master_mconsumototal', 'Visa_mconsumototal',
    'Master_mconsumosdolares', 'Visa_mconsumosdolares',
    'Visa_msaldototal','Visa_msaldopesos',
    'Master_msaldototal','Master_msaldopesos',
     'Master_msaldodolares','Visa_msaldodolares'
    ]


# # List of binary columns extracted
# binary_columns = [
#     'cliente_vip', 'internet',
#      'cliente_antiguedad', 'cliente_edad','cproductos'
# ]
# # Rentabilidad y comisiones
# rentabilidad_comisiones = [
#     'mrentabilidad', 'mrentabilidad_annual', 'mcomisiones', 
#     'mcomisiones_mantenimiento', 'mcomisiones_otras','ccomisiones_mantenimiento', 
#     'ccomisiones_otras'
# ]
# payroll = [
#     'cpayroll_trx', 'mpayroll', 'mpayroll2',
#         'cpayroll2_trx'
# ]
# # Cuentas y ahorros
# cuentas_ahorros = [
#     'tcuentas', 'ccuenta_corriente', 'mcuenta_corriente', 
#     'mcuenta_corriente_adicional', 'ccaja_ahorro', 'mcaja_ahorro', 
#     'mcaja_ahorro_adicional', 'mcaja_ahorro_dolares', 'mcuentas_saldo'
# ]
# # Descubiertos y préstamos
# descubiertos_prestamos = [
#     'cdescubierto_preacordado', 'cprestamos_personales', 'mprestamos_personales',
#     'cprestamos_prendarios', 'mprestamos_prendarios', 'cprestamos_hipotecarios', 
#     'mprestamos_hipotecarios'
# ]
# # Plazo fijo e inversiones
# inversiones_pesos = [
#     'cplazo_fijo', 'mplazo_fijo_pesos', 
#     'cinversion1', 'minversion1_pesos', 
#     'cinversion2', 'minversion2'
# ]
# forex = [
#     'cforex', 'cforex_buy', 'mforex_buy', 'cforex_sell', 'mforex_sell'
# ]
# inversiones_dolares = [
#     'mplazo_fijo_dolares', 'minversion1_dolares'
# ]
# # Seguros
# seguros = [
#     'cseguro_vida', 'cseguro_auto', 'cseguro_vivienda', 
#     'cseguro_accidentes_personales', 'ccaja_seguridad'
# ]
# # Tarjetas de débito y crédito
# tarjetas_debito = [
#     'ctarjeta_debito', 'ctarjeta_debito_transacciones', 'mautoservicio'
# ]
# # Débitos automáticos
# debitos_automaticos = [
#     'ccuenta_debitos_automaticos', 'mcuenta_debitos_automaticos', 
#     'ctarjeta_visa_debitos_automaticos', 'mttarjeta_visa_debitos_automaticos', 
#     'ctarjeta_master_debitos_automaticos', 'mttarjeta_master_debitos_automaticos'
# ]
# # Pagos de servicios y mis cuentas
# pagos_servicios = [
#     'cpagodeservicios', 'mpagodeservicios', 'cpagomiscuentas', 'mpagomiscuentas'
# ]
# # Descuentos
# descuentos = [
#     'ccajeros_propios_descuentos', 'mcajeros_propios_descuentos',
#     'ctarjeta_visa_descuentos', 'mtarjeta_visa_descuentos',
#     'ctarjeta_master_descuentos', 'mtarjeta_master_descuentos'
# ]
# # Transferencias y cheques
# cheques = [
#     'ccheques_depositados', 'mcheques_depositados', 
#     'ccheques_emitidos', 'mcheques_emitidos',
# ]
# transferencias = [
#     'ctransferencias_recibidas', 'mtransferencias_recibidas', 
#     'ctransferencias_emitidas', 'mtransferencias_emitidas', 
# ]

# rebotes_cheques = [
#     'ccheques_depositados_rechazados', 'mcheques_depositados_rechazados',
#     'ccheques_emitidos_rechazados', 'mcheques_emitidos_rechazados'
# ]
# # Canales de atención
# callcenter = [
#     'tcallcenter', 'ccallcenter_transacciones', 
# ]
# cajas = [
#     'ccajas_transacciones',
#     'ccajas_depositos', 'ccajas_extracciones', 'ccajas_otras'
    
# ]
# atm = [
#      'catm_trx', 'matm', 'catm_trx_other', 'matm_other',
#      'cextraccion_autoservicio', 'mextraccion_autoservicio'
# ]
# app_homebanking = [
#     'thomebanking',
#     'chomebanking_transacciones',
#     'tmobile_app', 'cmobile_app_trx'
# ]
# # 1. Delinquency and Status
# delinquency_status = [
#     'Master_delinquency', 'Visa_delinquency'
# ]
# # 4. Balances and Amounts
#     # Balances
# card_limits = [   
#     'Master_mfinanciacion_limite', 'Visa_mfinanciacion_limite',
#     'Master_mlimitecompra', 'Visa_mlimitecompra',
# ]
    
# card_payments = [
#     # Payments
#     'Master_mpagado', 'Visa_mpagado',
#     'Master_mpagospesos', 'Visa_mpagospesos',
#     'Master_mpagosdolares', 'Visa_mpagosdolares',
#     'Master_mpagominimo', 'Visa_mpagominimo'
# ]

# # 5. Cash Advances
# cash_advances = [
#     'Master_madelantopesos', 'Visa_madelantopesos',
#     'Master_madelantodolares', 'Visa_madelantodolares',
#     'Master_cadelantosefectivo', 'Visa_cadelantosefectivo'
# ]

# # 6. Transactions and Usage
# consumo_tarjetas = [
#     'Master_cconsumos', 'Visa_cconsumos',
#     'ctarjeta_visa', 'ctarjeta_visa_transacciones', 'mtarjeta_visa_consumo', 
#     'ctarjeta_master', 'ctarjeta_master_transacciones', 'mtarjeta_master_consumo',
#     'Master_mconsumospesos', 'Visa_mconsumospesos',
#     'Master_mconsumototal', 'Visa_mconsumototal',
# ]
# consumo_tarjeta_dolares = [
#     'Master_mconsumosdolares', 'Visa_mconsumosdolares'
# ]
# saldo_tarjeta = [
#     'Visa_msaldototal','Visa_msaldopesos',
#     'Master_msaldototal','Master_msaldopesos'
# ]
# saldo_tarjeta_dolares = [
#     'Master_msaldodolares','Visa_msaldodolares'
# ]

# [ 'active_quarter','Master_Fvencimiento', 'Master_Finiciomora', 'Master_fultimo_cierre',
#        'Master_fechaalta', 'Visa_Fvencimiento', 'Visa_Finiciomora','Master_status','Visa_status',
#        'Visa_fultimo_cierre', 'Visa_fechaalta']