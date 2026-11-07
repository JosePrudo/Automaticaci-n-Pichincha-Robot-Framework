*** Settings ***
Documentation       Prueba de humo para validar la instalación y que el simulador carga.
Resource            ../resources/simulador.resource
Test Teardown       Cerrar Navegador


*** Test Cases ***
El Simulador Carga Correctamente
    [Documentation]    Abre el simulador y verifica que la primera sección se muestra.
    [Tags]    smoke
    Abrir Simulador
    Verificar Seccion    Tu proyecto de vivienda
    Capturar Evidencia    smoke-home
