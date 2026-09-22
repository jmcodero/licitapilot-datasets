# Contratación pública española por provincia: volumen e importe

Conjunto de datos abierto con el **número de contratos** y el **importe total licitado** en cada una de las **52 provincias** españolas.

Responde a: *"¿dónde se concentra la contratación pública, en número y en dinero?"*.

- **Fuente primaria:** Plataforma de Contratación del Sector Público (PLACSP) — https://contrataciondelestado.es
- **Elaboración:** LicitaPilot — https://licitapilot.com
- **Licencia:** [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- **Fecha de corte:** 2026-09-22 · **Cobertura:** España

## Columnas

| Columna | Tipo | Descripción |
|---|---|---|
| `provincia` | texto | Nombre de la provincia. |
| `comunidad` | texto | Comunidad autónoma. |
| `codigo_ine` | texto | Código INE de provincia (2 dígitos). |
| `num_contratos` | entero | Nº de licitaciones registradas en la provincia. |
| `importe_total_eur` | decimal | Suma del presupuesto base de licitación (sin IVA), en euros. |

## Metodología

- Las licitaciones se asignan a la provincia del lugar de ejecución / órgano de contratación, normalizada a las 52 provincias del INE.
- `importe_total_eur` suma el presupuesto base de licitación; las licitaciones sin importe informado no computan en el sumatorio.
- Importes sin IVA y según figuran en la plataforma. **Datos no auditados.**

## Cómo citar

> LicitaPilot (2026). *Contratación pública española por provincia*. Elaboración propia a partir de PLACSP. CC BY 4.0. https://licitapilot.com/provincia

## Más datos

Mapa y fichas por provincia en **[licitapilot.com/provincia](https://licitapilot.com/provincia)**.
