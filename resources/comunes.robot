*** Settings ***
Documentation       Configuración común y manejo de evidencias para Browser (Playwright).
...                 Toma captura automática ante cualquier fallo y permite capturar
...                 evidencias embebidas en el reporte.
Library             Browser    run_on_failure=Take Screenshot    timeout=0:00:20


*** Variables ***
${NAVEGADOR}        chromium
${HEADLESS}         ${True}


*** Keywords ***
Abrir Navegador
    [Documentation]    Abre un navegador y navega a la URL indicada.
    [Arguments]    ${url}
    New Browser    browser=${NAVEGADOR}    headless=${HEADLESS}
    New Context    viewport={'width': 1366, 'height': 768}
    New Page    ${url}

Cerrar Navegador
    [Documentation]    Cierra todos los navegadores y contextos abiertos.
    Close Browser    ALL

Capturar Evidencia
    [Documentation]    Inserta una captura de pantalla embebida en el log del reporte.
    [Arguments]    ${nombre}=evidencia
    Log    Evidencia: ${nombre}
    Take Screenshot    EMBED    fullPage=True
