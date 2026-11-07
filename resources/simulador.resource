*** Settings ***
Documentation       Localizadores y keywords de negocio para el asistente
...                 "Simulación de Crédito Hipotecario" del Banco Pichincha.
...                 El asistente tiene 7 secciones: Proyecto, Finanzas, Personaliza,
...                 Resultados, Capacidades, Contacto y Confirmación.
Resource            comunes.robot


*** Variables ***
${URL_SIMULADOR}            https://brave-mud-0605ba20f.3.azurestaticapps.net/

# --- Sección 1: Proyecto ---
${PROY_INDIVIDUAL}          css=#individual
${PROY_PAREJA}              css=#pareja
${PROY_CASA}                css=#casa
${PROY_APARTAMENTO}         css=#apartamento

# --- Sección 2: Finanzas ---
${FIN_EMPLEADO}             css=#empleado
${FIN_INDEPENDIENTE}        css=#independiente
${FIN_EMPRESARIO}           css=#empresario
${FIN_INGRESOS}             [placeholder="Ingresos netos"]
${FIN_AHORRO}               [placeholder="Total ahorrado"]
${FIN_FECHA}                input[type="date"]

# --- Sección 3: Personaliza ---
${PER_MONTO}                [placeholder="Monto total del préstamo"]
${PER_FIJA}                 css=#fija
${PER_VARIABLE}             css=#variable

# --- Sección 5: Capacidades ---
${CAP_NOMBRE}               [placeholder="Nombre completo"]
${CAP_CEDULA}               [placeholder="Documento de identidad"]
${CAP_EMAIL}                input[type="email"]
${CAP_TELEFONO}             input[type="tel"]
${CAP_AUTORIZA}             css=#authorizeCreditCheck
${CAP_CARGAS}               [placeholder="Cargas familiares"]
${CAP_EMPRESA}              [placeholder="Compañía de tecnología S.A.S"]

# --- Sección 6: Contacto ---
${CON_MANANA}               input[name="preferredTime"][value="mañana"]
${CON_TARDE}                input[name="preferredTime"][value="tarde"]
${CON_LLAMADA}              input[name="contactMethod"][value="llamada"]
${CON_CORREO}               input[name="contactMethod"][value="correo"]
${CON_WHATSAPP}             input[name="contactMethod"][value="whatsapp"]
${CON_PRIVACIDAD}           css=#acceptsPrivacyPolicy
${CON_PRODUCTOS}            css=#wantsProductInfo

# --- Sección 7: Confirmación ---
${CNF_CONFIRMAR}            css=#confirmInformation

# --- Botones de navegación ---
${BTN_SIGUIENTE}            button:has-text("Siguiente")
${BTN_VOLVER}               button:has-text("Volver")
${BTN_GUARDAR}              button:has-text("Guardar formulario")
${BTN_ENVIAR}               button:has-text("Aceptar y Enviar")
${BTN_CANCELAR}             button:has-text("Cancelar")


*** Keywords ***
Abrir Simulador
    [Documentation]    Abre la aplicación y verifica que la primera sección cargó.
    Abrir Navegador    ${URL_SIMULADOR}
    Get Text    h1    ==    Tu Credito de Vivienda
    Verificar Seccion    Tu proyecto de vivienda

Verificar Seccion
    [Documentation]    Comprueba que el título (h2) de la sección actual es el esperado.
    [Arguments]    ${titulo}
    Get Text    h2    ==    ${titulo}

Ejecutar Paso
    [Documentation]    Ejecuta una acción de la prueba y guarda una captura de evidencia del paso.
    [Arguments]    ${descripcion}    ${keyword}    @{args}
    Run Keyword    ${keyword}    @{args}
    Capturar Evidencia    ${descripcion}

Completar Seccion Proyecto
    [Documentation]    Sección 1: tipo de aplicante, tipo de vivienda y ciudad.
    [Arguments]    ${aplicante}=${PROY_INDIVIDUAL}    ${vivienda}=${PROY_CASA}    ${ciudad}=Quito
    Verificar Seccion    Tu proyecto de vivienda
    Capturar Evidencia    01-proyecto-inicio
    Ejecutar Paso    01-proyecto-aplicante    Check Checkbox    ${aplicante}
    Ejecutar Paso    01-proyecto-vivienda    Check Checkbox    ${vivienda}
    Ejecutar Paso    01-proyecto-ciudad    Select Options By    select    label    ${ciudad}
    Ejecutar Paso    01-proyecto-siguiente    Click    ${BTN_SIGUIENTE}

Completar Seccion Finanzas
    [Documentation]    Sección 2: situación laboral, ingresos, ahorro, nacimiento y estado civil.
    [Arguments]    ${situacion}=${FIN_EMPLEADO}    ${ingresos}=2500    ${ahorro}=40000
    ...    ${nacimiento}=1990-05-15    ${estado_civil}=Soltero
    Verificar Seccion    Tu situación financiera
    Capturar Evidencia    02-finanzas-inicio
    Ejecutar Paso    02-finanzas-situacion    Check Checkbox    ${situacion}
    Ejecutar Paso    02-finanzas-ingresos    Fill Text    ${FIN_INGRESOS}    ${ingresos}
    Ejecutar Paso    02-finanzas-ahorro    Fill Text    ${FIN_AHORRO}    ${ahorro}
    Ejecutar Paso    02-finanzas-nacimiento    Fill Text    ${FIN_FECHA}    ${nacimiento}
    Ejecutar Paso    02-finanzas-estado-civil    Select Options By    select    label    ${estado_civil}
    Ejecutar Paso    02-finanzas-siguiente    Click    ${BTN_SIGUIENTE}

Completar Seccion Personalizacion
    [Documentation]    Sección 3: monto, plazo y tipo de cuota.
    [Arguments]    ${monto}=120000    ${plazo}=20 años    ${cuota}=${PER_FIJA}
    Verificar Seccion    Personaliza tu crédito de vivienda
    Capturar Evidencia    03-personaliza-inicio
    Ejecutar Paso    03-personaliza-monto    Fill Text    ${PER_MONTO}    ${monto}
    Ejecutar Paso    03-personaliza-plazo    Select Options By    select    label    ${plazo}
    Ejecutar Paso    03-personaliza-cuota    Check Checkbox    ${cuota}
    Ejecutar Paso    03-personaliza-blur    Click    h1
    Ejecutar Paso    03-personaliza-siguiente    Click    ${BTN_SIGUIENTE}

Completar Seccion Resultados
    [Documentation]    Sección 4: muestra la cuota estimada y los seguros.
    Verificar Seccion    Tus resultados
    Capturar Evidencia    04-resultados
    Ejecutar Paso    04-resultados-siguiente    Click    ${BTN_SIGUIENTE}

Completar Seccion Capacidades
    [Documentation]    Sección 5: datos personales y autorización de consulta crediticia.
    [Arguments]    ${nombre}=Juan Perez Gomez    ${cedula}=1712345678
    ...    ${email}=juan.perez@example.com    ${telefono}=0991234567
    ...    ${cargas}=2    ${empresa}=Empresa Tecnologica SAS
    Verificar Seccion    Tu capacidad real
    Capturar Evidencia    05-capacidades-inicio
    Ejecutar Paso    05-capacidades-nombre    Fill Text    ${CAP_NOMBRE}    ${nombre}
    Ejecutar Paso    05-capacidades-cedula    Fill Text    ${CAP_CEDULA}    ${cedula}
    Ejecutar Paso    05-capacidades-email    Fill Text    ${CAP_EMAIL}    ${email}
    Ejecutar Paso    05-capacidades-telefono    Fill Text    ${CAP_TELEFONO}    ${telefono}
    Ejecutar Paso    05-capacidades-cargas    Fill Text    ${CAP_CARGAS}    ${cargas}
    Ejecutar Paso    05-capacidades-empresa    Fill Text    ${CAP_EMPRESA}    ${empresa}
    Ejecutar Paso    05-capacidades-autoriza    Check Checkbox    ${CAP_AUTORIZA}
    Ejecutar Paso    05-capacidades-siguiente    Click    ${BTN_SIGUIENTE}

Completar Seccion Contacto
    [Documentation]    Sección 6: horario, medio de contacto y aceptación de políticas.
    [Arguments]    ${horario}=${CON_MANANA}    ${medio}=${CON_CORREO}
    Verificar Seccion    Quiero que me Contacten
    Capturar Evidencia    06-contacto-inicio
    Ejecutar Paso    06-contacto-horario    Check Checkbox    ${horario}
    Ejecutar Paso    06-contacto-medio    Check Checkbox    ${medio}
    Ejecutar Paso    06-contacto-privacidad    Check Checkbox    ${CON_PRIVACIDAD}
    Ejecutar Paso    06-contacto-siguiente    Click    ${BTN_SIGUIENTE}

Confirmar Simulacion
    [Documentation]    Sección 7: valida el resumen y habilita el envío.
    Verificar Seccion    Confirmación
    Wait For Elements State    text=Código de tu simulación    visible
    Wait For Elements State    text=Resumen de lo que simulaste    visible
    Capturar Evidencia    07-confirmacion-resumen
    Ejecutar Paso    07-confirmacion-check    Check Checkbox    ${CNF_CONFIRMAR}
    Wait For Elements State    ${BTN_ENVIAR}    enabled
    Capturar Evidencia    07-confirmacion-listo

Enviar Simulacion
    [Documentation]    Hace clic en "Aceptar y Enviar".
    Ejecutar Paso    08-enviar    Click    ${BTN_ENVIAR}

Completar Simulacion Completa
    [Documentation]    Recorre las 7 secciones del asistente de principio a fin.
    Completar Seccion Proyecto
    Completar Seccion Finanzas
    Completar Seccion Personalizacion
    Completar Seccion Resultados
    Completar Seccion Capacidades
    Completar Seccion Contacto
    Confirmar Simulacion
