"""Genera un informe ejecutivo (HTML autocontenido) a partir de la ultima ejecucion.

Lee results/output.xml y las capturas en results/evidencias/<escenario>/ y produce
un informe con el resumen de resultados y las evidencias de cada paso por escenario.
El informe se sobrescribe en cada ejecucion en la carpeta "Informe ejecutivo".
"""

from __future__ import annotations

import base64
import sys
from datetime import datetime
from html import escape
from pathlib import Path

from robot.api import ExecutionResult

BASE_DIR = Path(__file__).resolve().parent
RESULTS_DIR = BASE_DIR / "results"
OUTPUT_XML = RESULTS_DIR / "output.xml"
EVIDENCIAS_DIR = RESULTS_DIR / "evidencias"
DESTINO_DIR = BASE_DIR / "Informe ejecutivo"
DESTINO_HTML = DESTINO_DIR / "informe_ejecutivo.html"

# Descripcion amigable de cada paso (nombre del archivo de evidencia -> explicacion).
DESCRIPCIONES: dict[str, str] = {
    "smoke-home": "Se abre el simulador y se verifica que la pagina inicial carga correctamente.",
    # Seccion 1: Proyecto
    "01-proyecto-inicio": "Inicio de la seccion Proyecto: se muestra el formulario del proyecto de vivienda.",
    "01-proyecto-aplicante": "Se selecciona el tipo de aplicante (Individual).",
    "01-proyecto-vivienda": "Se selecciona el tipo de vivienda (Casa).",
    "01-proyecto-ciudad": "Se elige la ciudad de la vivienda (Quito).",
    "01-proyecto-siguiente": "Se avanza a la seccion Finanzas con el boton Siguiente.",
    # Seccion 2: Finanzas
    "02-finanzas-inicio": "Inicio de la seccion Finanzas: formulario de situacion financiera.",
    "02-finanzas-situacion": "Se selecciona la situacion laboral (Empleado).",
    "02-finanzas-ingresos": "Se ingresan los ingresos netos mensuales.",
    "02-finanzas-ahorro": "Se ingresa el monto ahorrado para la cuota inicial.",
    "02-finanzas-nacimiento": "Se registra la fecha de nacimiento.",
    "02-finanzas-estado-civil": "Se selecciona el estado civil (Soltero).",
    "02-finanzas-siguiente": "Se avanza a la seccion Personaliza con el boton Siguiente.",
    # Seccion 3: Personaliza
    "03-personaliza-inicio": "Inicio de la seccion Personaliza: configuracion del credito.",
    "03-personaliza-monto": "Se ingresa el monto del prestamo deseado.",
    "03-personaliza-plazo": "Se selecciona el plazo del credito (20 anios).",
    "03-personaliza-cuota": "Se elige el tipo de cuota (Fija).",
    "03-personaliza-blur": "Se confirma el monto para habilitar el boton Siguiente.",
    "03-personaliza-siguiente": "Se avanza a la seccion Resultados con el boton Siguiente.",
    # Seccion 4: Resultados
    "04-resultados": "Se visualiza la cuota estimada y los seguros calculados.",
    "04-resultados-siguiente": "Se avanza a la seccion Capacidades con el boton Siguiente.",
    # Seccion 5: Capacidades
    "05-capacidades-inicio": "Inicio de la seccion Capacidades: datos personales del solicitante.",
    "05-capacidades-nombre": "Se ingresa el nombre completo.",
    "05-capacidades-cedula": "Se ingresa el numero de cedula/documento.",
    "05-capacidades-email": "Se ingresa el correo electronico.",
    "05-capacidades-telefono": "Se ingresa el telefono celular.",
    "05-capacidades-cargas": "Se indica el numero de cargas familiares.",
    "05-capacidades-empresa": "Se ingresa la empresa donde trabaja.",
    "05-capacidades-autoriza": "Se autoriza la consulta del historial crediticio.",
    "05-capacidades-siguiente": "Se avanza a la seccion Contacto con el boton Siguiente.",
    # Seccion 6: Contacto
    "06-contacto-inicio": "Inicio de la seccion Contacto: preferencias de contacto.",
    "06-contacto-horario": "Se selecciona el horario preferido de contacto (Maniana).",
    "06-contacto-medio": "Se selecciona el medio de contacto preferido.",
    "06-contacto-privacidad": "Se aceptan las politicas de privacidad.",
    "06-contacto-siguiente": "Se avanza a la seccion Confirmacion con el boton Siguiente.",
    # Seccion 7: Confirmacion
    "07-confirmacion-resumen": "Se muestra el resumen de la simulacion y el codigo generado.",
    "07-confirmacion-check": "Se confirma que la informacion es correcta y completa.",
    "07-confirmacion-listo": "El boton Aceptar y Enviar queda habilitado, listo para el envio.",
    "08-enviar": "Se hace clic en Aceptar y Enviar para enviar la simulacion.",
    "08-enviado": "Estado final de la pantalla tras el envio de la simulacion.",
}


def _formatear_duracion(ms: float) -> str:
    segundos = ms / 1000.0
    if segundos < 60:
        return f"{segundos:.1f} s"
    minutos, resto = divmod(int(segundos), 60)
    return f"{minutos} min {resto} s"


def _recolectar_tests(suite, acumulado):
    for test in suite.tests:
        acumulado.append((suite.name, test))
    for hija in suite.suites:
        _recolectar_tests(hija, acumulado)


def _descripcion(nombre_archivo: str) -> str:
    stem = Path(nombre_archivo).stem
    if stem in DESCRIPCIONES:
        return DESCRIPCIONES[stem]
    return stem.replace("-", " ").replace("_", " ").strip()


def _img_base64(ruta: Path) -> str:
    datos = base64.b64encode(ruta.read_bytes()).decode("ascii")
    return f"data:image/png;base64,{datos}"


def _evidencias_de(test_name: str):
    carpeta = EVIDENCIAS_DIR / test_name
    if not carpeta.is_dir():
        return []
    return sorted(carpeta.glob("*.png"), key=lambda p: p.name)


def _elapsed_ms(test) -> float:
    valor = getattr(test, "elapsedtime", None)
    if valor is not None:
        return float(valor)
    elapsed = getattr(test, "elapsed_time", None)
    if elapsed is not None:
        return elapsed.total_seconds() * 1000.0
    return 0.0


def generar() -> int:
    if not OUTPUT_XML.exists():
        print(f"[informe] No se encontro {OUTPUT_XML}. Ejecuta primero las pruebas.")
        return 1

    resultado = ExecutionResult(str(OUTPUT_XML))
    total = resultado.statistics.total
    pasaron = total.passed
    fallaron = total.failed
    omitidas = getattr(total, "skipped", 0)
    total_tests = pasaron + fallaron + omitidas
    tasa = (pasaron / total_tests * 100) if total_tests else 0.0

    tests: list = []
    _recolectar_tests(resultado.suite, tests)

    generado = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    estado_global = "APROBADO" if fallaron == 0 and total_tests else "CON FALLOS"
    clase_global = "ok" if fallaron == 0 and total_tests else "fail"

    partes: list[str] = []
    partes.append(f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Informe Ejecutivo · Simulación de Crédito Hipotecario</title>
<style>
  :root {{ --amarillo:#FFDD00; --azul:#003a70; --verde:#1e8e3e; --rojo:#d93025; --gris:#5f6368; }}
  * {{ box-sizing: border-box; }}
  body {{ font-family: 'Segoe UI', Arial, sans-serif; margin:0; background:#f1f3f4; color:#202124; }}
  header {{ background:var(--azul); color:#fff; padding:24px 32px; border-bottom:6px solid var(--amarillo); }}
  header h1 {{ margin:0; font-size:22px; }}
  header p {{ margin:4px 0 0; opacity:.85; font-size:13px; }}
  main {{ max-width:1100px; margin:0 auto; padding:24px 32px 64px; }}
  .cards {{ display:grid; grid-template-columns:repeat(auto-fit,minmax(150px,1fr)); gap:16px; margin:24px 0; }}
  .card {{ background:#fff; border-radius:10px; padding:18px; box-shadow:0 1px 3px rgba(0,0,0,.12); text-align:center; }}
  .card .num {{ font-size:30px; font-weight:700; }}
  .card .lbl {{ font-size:12px; color:var(--gris); text-transform:uppercase; letter-spacing:.5px; margin-top:4px; }}
  .badge {{ display:inline-block; padding:4px 12px; border-radius:20px; font-size:12px; font-weight:700; color:#fff; }}
  .badge.ok {{ background:var(--verde); }}
  .badge.fail {{ background:var(--rojo); }}
  .global.ok {{ color:var(--verde); }}
  .global.fail {{ color:var(--rojo); }}
  .barra {{ height:10px; background:#e0e0e0; border-radius:6px; overflow:hidden; margin-top:8px; }}
  .barra > span {{ display:block; height:100%; background:var(--verde); }}
  .escenario {{ background:#fff; border-radius:10px; margin:18px 0; box-shadow:0 1px 3px rgba(0,0,0,.12); overflow:hidden; }}
  .escenario > summary {{ cursor:pointer; padding:16px 20px; font-size:16px; font-weight:600; display:flex; justify-content:space-between; align-items:center; list-style:none; }}
  .escenario > summary::-webkit-details-marker {{ display:none; }}
  .escenario .meta {{ padding:0 20px 8px; color:var(--gris); font-size:13px; }}
  .pasos {{ display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:16px; padding:16px 20px 24px; }}
  .paso {{ border:1px solid #e0e0e0; border-radius:8px; overflow:hidden; background:#fafafa; }}
  .paso img {{ width:100%; display:block; border-bottom:1px solid #e0e0e0; }}
  .paso .cap {{ padding:8px 10px; font-size:12px; color:#333; }}
  .paso .idx {{ color:var(--azul); font-weight:700; margin-right:6px; }}
  .sin {{ padding:16px 20px; color:var(--gris); font-style:italic; }}
  .intro {{ background:#fff; border-left:5px solid var(--amarillo); border-radius:8px; padding:16px 20px; margin:18px 0; box-shadow:0 1px 3px rgba(0,0,0,.12); }}
  .intro h2 {{ margin-top:0; }}
  .intro p {{ font-size:14px; line-height:1.55; color:#333; }}
  .intro .nota {{ font-size:13px; color:var(--gris); }}
  footer {{ text-align:center; color:var(--gris); font-size:12px; padding:24px; }}
</style>
</head>
<body>
<header>
  <h1>Informe Ejecutivo &middot; Simulación de Crédito Hipotecario</h1>
  <p>Banco Pichincha &middot; Generado el {escape(generado)}</p>
</header>
<main>
  <h2 class="global {clase_global}">Resultado global: {estado_global}</h2>
  <div class="cards">
    <div class="card"><div class="num">{total_tests}</div><div class="lbl">Escenarios</div></div>
    <div class="card"><div class="num" style="color:var(--verde)">{pasaron}</div><div class="lbl">Aprobados</div></div>
    <div class="card"><div class="num" style="color:var(--rojo)">{fallaron}</div><div class="lbl">Fallidos</div></div>
    <div class="card"><div class="num">{tasa:.0f}%</div><div class="lbl">Tasa de exito</div>
      <div class="barra"><span style="width:{tasa:.0f}%"></span></div>
    </div>
  </div>
  <section class="intro">
    <h2>¿Qué valida esta prueba?</h2>
    <p>Se automatiza el simulador de <strong>Credito Hipotecario</strong> del Banco Pichincha, un asistente
    de <strong>7 secciones</strong>: Proyecto, Finanzas, Personaliza, Resultados, Capacidades, Contacto y
    Confirmacion. En cada escenario se completan los campos de una o varias secciones y se verifica que el
    asistente avanza correctamente. Debajo de cada escenario encontraras las <strong>evidencias paso a paso</strong>
    (una captura por accion) con una breve explicacion de lo que ocurre en cada una.</p>
    <p class="nota">Nota: el envio final ("Aceptar y Enviar") depende de un servicio externo; las pruebas validan
    el flujo hasta habilitar el envio, sin asumir la respuesta del servidor.</p>
  </section>
  <h2>Detalle por escenario</h2>
""")

    for suite_name, test in tests:
        estado = test.status
        clase = "ok" if estado == "PASS" else "fail"
        etiqueta = "APROBADO" if estado == "PASS" else "FALLIDO"
        doc = escape(test.doc or "")
        duracion = _formatear_duracion(_elapsed_ms(test))
        mensaje = escape(test.message or "")
        abierto = "open" if estado != "PASS" else ""

        partes.append(f"""  <details class="escenario" {abierto}>
    <summary><span>{escape(test.name)}</span><span class="badge {clase}">{etiqueta}</span></summary>
    <div class="meta">Suite: {escape(suite_name)} &middot; Duracion: {duracion}{(' &middot; ' + mensaje) if mensaje else ''}</div>
""")
        if doc:
            partes.append(f'    <div class="meta">{doc}</div>\n')

        evidencias = _evidencias_de(test.name)
        if evidencias:
            partes.append('    <div class="pasos">\n')
            for i, img in enumerate(evidencias, start=1):
                partes.append(
                    f'      <figure class="paso" style="margin:0">'
                    f'<img src="{_img_base64(img)}" alt="{escape(img.stem)}">'
                    f'<figcaption class="cap"><span class="idx">{i:02d}</span>{escape(_descripcion(img.name))}</figcaption>'
                    f'</figure>\n'
                )
            partes.append('    </div>\n')
        else:
            partes.append('    <div class="sin">Sin evidencias registradas para este escenario.</div>\n')

        partes.append("  </details>\n")

    partes.append("""  </main>
<footer>Informe generado automaticamente tras la ultima ejecucion de las pruebas.</footer>
</body>
</html>
""")

    DESTINO_DIR.mkdir(parents=True, exist_ok=True)
    DESTINO_HTML.write_text("".join(partes), encoding="utf-8")
    print(f"[informe] Informe ejecutivo actualizado: {DESTINO_HTML}")
    return 0


if __name__ == "__main__":
    sys.exit(generar())
