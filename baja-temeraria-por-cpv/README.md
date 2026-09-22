# Baja media en la contratación pública española, por sector (CPV)

Conjunto de datos abierto con la **baja media** (porcentaje de rebaja de la oferta adjudicataria respecto al presupuesto base de licitación) y el **número de contratos adjudicados** en cada sector, agregado por las **43 divisiones del Vocabulario Común de Contratos Públicos (CPV)**.

Es la señal que responde a una pregunta muy concreta del licitador: *"¿cuánto se suele rebajar el precio para ganar en mi sector?"*.

- **Fuente primaria:** Plataforma de Contratación del Sector Público (PLACSP) — https://contrataciondelestado.es
- **Elaboración:** LicitaPilot — https://licitapilot.com
- **Licencia:** [Creative Commons Attribution 4.0 (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)
- **Fecha de corte:** 2026-09-23
- **Cobertura geográfica:** España

## Ficheros

| Fichero | Descripción |
|---|---|
| `baja-media-por-cpv.csv` | Datos en CSV (UTF-8), una fila por división CPV. |
| `baja-media-por-cpv.json` | Los mismos datos en JSON, con metadatos. |

## Columnas

| Columna | Tipo | Descripción |
|---|---|---|
| `cpv_division` | texto | Código de la división CPV (2 dígitos). |
| `nombre` | texto | Denominación oficial de la división CPV. |
| `num_contratos` | entero | Nº de contratos adjudicados con baja calculable en esa división. |
| `baja_media_pct` | decimal | Baja media, en % del presupuesto base de licitación. |

## Metodología

- La **baja** de cada contrato se calcula como `(presupuesto base − importe de adjudicación) / presupuesto base × 100`.
- Se incluyen los contratos **adjudicados** en los que constan tanto el presupuesto base como el importe de adjudicación en PLACSP.
- `baja_media_pct` es la media aritmética de la baja de los contratos de cada división CPV.
- Las divisiones con **pocos contratos** tienen medias menos estables; interpreta esos valores con cautela (ver `num_contratos`).
- Importes sin IVA y según figuran en la plataforma. **Datos no auditados.**

## Qué NO afirma este conjunto de datos

No imputa irregularidad alguna: una baja alta o baja puede responder a la competencia, a la naturaleza del contrato o a la estructura de costes del sector. Describe un patrón agregado con datos públicos.

## Cómo citar

> LicitaPilot (2026). *Baja media en la contratación pública española por sector (CPV)*. Elaboración propia a partir de la Plataforma de Contratación del Sector Público (PLACSP). CC BY 4.0. https://licitapilot.com/estadisticas/baja-temeraria

## Más datos y contexto

Radiografía interactiva por CPV y provincia, barómetro de la baja y buscador de licitaciones en **[licitapilot.com](https://licitapilot.com/estadisticas/baja-temeraria)**.
