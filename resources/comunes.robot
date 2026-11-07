*** Settings ***
Documentation       Configuración común y manejo de evidencias para Browser (Playwright).
...                 Toma captura automática ante cualquier fallo y permite capturar
...                 evidencias embebidas en el reporte.
Library             Browser    run_on_failure=Take Screenshot    timeout=0:00:20


*** Variables ***
${NAVEGADOR}        chromium
${HEADLESS}         ${True}
${CAMARA_LENTA}     0:00:00


*** Keywords ***
Abrir Navegador
    [Documentation]    Abre un navegador y navega a la URL indicada.
    [Arguments]    ${url}
    New Browser    browser=${NAVEGADOR}    headless=${HEADLESS}    slowMo=${CAMARA_LENTA}
    New Context    viewport={'width': 1366, 'height': 768}
    New Page    ${url}

Cerrar Navegador
    [Documentation]    Cierra todos los navegadores y contextos abiertos.
    Close Browser    ALL

Capturar Evidencia
    [Documentation]    Guarda la captura como archivo en results/evidencias/<escenario> y la muestra en el log.
    [Arguments]    ${nombre}=evidencia
    Log    Evidencia: ${nombre}
    Take Screenshot    filename=${OUTPUT_DIR}/evidencias/${TEST_NAME}/${nombre}
