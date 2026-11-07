*** Settings ***
Documentation       Automatización de las 7 secciones del asistente
...                 "Simulación de Crédito Hipotecario" del Banco Pichincha.
...                 Cada caso valida una sección y deja evidencias embebidas en el reporte.
Resource            ../resources/simulador.resource
Test Setup          Abrir Simulador
Test Teardown       Cerrar Navegador


*** Test Cases ***
Seccion 1 - Proyecto De Vivienda
    [Documentation]    Completa la sección Proyecto y avanza a Finanzas.
    [Tags]    seccion    proyecto
    Completar Seccion Proyecto
    Verificar Seccion    Tu situación financiera

Seccion 2 - Situacion Financiera
    [Documentation]    Completa la sección Finanzas y avanza a Personaliza.
    [Tags]    seccion    finanzas
    Completar Seccion Proyecto
    Completar Seccion Finanzas
    Verificar Seccion    Personaliza tu crédito de vivienda

Seccion 3 - Personaliza El Credito
    [Documentation]    Completa la sección Personaliza y avanza a Resultados.
    [Tags]    seccion    personaliza
    Completar Seccion Proyecto
    Completar Seccion Finanzas
    Completar Seccion Personalizacion
    Verificar Seccion    Tus resultados

Seccion 4 - Resultados
    [Documentation]    Visualiza la sección Resultados y avanza a Capacidades.
    [Tags]    seccion    resultados
    Completar Seccion Proyecto
    Completar Seccion Finanzas
    Completar Seccion Personalizacion
    Completar Seccion Resultados
    Verificar Seccion    Tu capacidad real

Seccion 5 - Capacidad Real
    [Documentation]    Completa la sección Capacidades y avanza a Contacto.
    [Tags]    seccion    capacidades
    Completar Seccion Proyecto
    Completar Seccion Finanzas
    Completar Seccion Personalizacion
    Completar Seccion Resultados
    Completar Seccion Capacidades
    Verificar Seccion    Quiero que me Contacten

Seccion 6 - Contacto
    [Documentation]    Completa la sección Contacto y avanza a Confirmación.
    [Tags]    seccion    contacto
    Completar Seccion Proyecto
    Completar Seccion Finanzas
    Completar Seccion Personalizacion
    Completar Seccion Resultados
    Completar Seccion Capacidades
    Completar Seccion Contacto
    Verificar Seccion    Confirmación

Seccion 7 - Confirmacion
    [Documentation]    Valida el resumen y que el botón de envío queda habilitado.
    [Tags]    seccion    confirmacion
    Completar Seccion Proyecto
    Completar Seccion Finanzas
    Completar Seccion Personalizacion
    Completar Seccion Resultados
    Completar Seccion Capacidades
    Completar Seccion Contacto
    Confirmar Simulacion
    Wait For Elements State    ${BTN_ENVIAR}    enabled

Flujo Completo - Simulacion De Credito Hipotecario
    [Documentation]    Recorre las 7 secciones de principio a fin y envía la simulación.
    [Tags]    e2e    regresion
    Completar Simulacion Completa
    Enviar Simulacion
    Capturar Evidencia    08-enviado
