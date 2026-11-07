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

Completar Seccion Proyecto
    [Documentation]    Sección 1: tipo de aplicante, tipo de vivienda y ciudad.
    [Arguments]    ${aplicante}=${PROY_INDIVIDUAL}    ${vivienda}=${PROY_CASA}    ${ciudad}=Quito
    Verificar Seccion    Tu proyecto de vivienda
    Check Checkbox    ${aplicante}
    Check Checkbox    ${vivienda}
    Select Options By    select    label    ${ciudad}
    Capturar Evidencia    01-proyecto
    Click    ${BTN_SIGUIENTE}

Completar Seccion Finanzas
    [Documentation]    Sección 2: situación laboral, ingresos, ahorro, nacimiento y estado civil.
    [Arguments]    ${situacion}=${FIN_EMPLEADO}    ${ingresos}=2500    ${ahorro}=40000
    ...    ${nacimiento}=1990-05-15    ${estado_civil}=Soltero
    Verificar Seccion    Tu situación financiera
    Check Checkbox    ${situacion}
    Fill Text    ${FIN_INGRESOS}    ${ingresos}
    Fill Text    ${FIN_AHORRO}    ${ahorro}
    Fill Text    ${FIN_FECHA}    ${nacimiento}
    Select Options By    select    label    ${estado_civil}
    Capturar Evidencia    02-finanzas
    Click    ${BTN_SIGUIENTE}

Completar Seccion Personalizacion
    [Documentation]    Sección 3: monto, plazo y tipo de cuota.
    [Arguments]    ${monto}=120000    ${plazo}=20 años    ${cuota}=${PER_FIJA}
    Verificar Seccion    Personaliza tu crédito de vivienda
    Fill Text    ${PER_MONTO}    ${monto}
    Select Options By    select    label    ${plazo}
    Check Checkbox    ${cuota}
    Click    h1    # Quita el foco del monto para habilitar "Siguiente"
    Capturar Evidencia    03-personaliza
    Click    ${BTN_SIGUIENTE}

Completar Seccion Resultados
    [Documentation]    Sección 4: muestra la cuota estimada y los seguros.
    Verificar Seccion    Tus resultados
    Capturar Evidencia    04-resultados
    Click    ${BTN_SIGUIENTE}

Completar Seccion Capacidades
    [Documentation]    Sección 5: datos personales y autorización de consulta crediticia.
    [Arguments]    ${nombre}=Juan Perez Gomez    ${cedula}=1712345678
    ...    ${email}=juan.perez@example.com    ${telefono}=0991234567
    ...    ${cargas}=2    ${empresa}=Empresa Tecnologica SAS
    Verificar Seccion    Tu capacidad real
    Fill Text    ${CAP_NOMBRE}    ${nombre}
    Fill Text    ${CAP_CEDULA}    ${cedula}
    Fill Text    ${CAP_EMAIL}    ${email}
    Fill Text    ${CAP_TELEFONO}    ${telefono}
    Fill Text    ${CAP_CARGAS}    ${cargas}
    Fill Text    ${CAP_EMPRESA}    ${empresa}
    Check Checkbox    ${CAP_AUTORIZA}
    Capturar Evidencia    05-capacidades
    Click    ${BTN_SIGUIENTE}

Completar Seccion Contacto
    [Documentation]    Sección 6: horario, medio de contacto y aceptación de políticas.
    [Arguments]    ${horario}=${CON_MANANA}    ${medio}=${CON_CORREO}
    Verificar Seccion    Quiero que me Contacten
    Check Checkbox    ${horario}
    Check Checkbox    ${medio}
    Check Checkbox    ${CON_PRIVACIDAD}
    Capturar Evidencia    06-contacto
    Click    ${BTN_SIGUIENTE}

Confirmar Simulacion
    [Documentation]    Sección 7: valida el resumen y habilita el envío.
    Verificar Seccion    Confirmación
    Wait For Elements State    text=Código de tu simulación    visible
    Wait For Elements State    text=Resumen de lo que simulaste    visible
    Check Checkbox    ${CNF_CONFIRMAR}
    Wait For Elements State    ${BTN_ENVIAR}    enabled
    Capturar Evidencia    07-confirmacion

Enviar Simulacion
    [Documentation]    Hace clic en "Aceptar y Enviar".
    Click    ${BTN_ENVIAR}

Completar Simulacion Completa
    [Documentation]    Recorre las 7 secciones del asistente de principio a fin.
    Completar Seccion Proyecto
    Completar Seccion Finanzas
    Completar Seccion Personalizacion
    Completar Seccion Resultados
    Completar Seccion Capacidades
    Completar Seccion Contacto
    Confirmar Simulacion
