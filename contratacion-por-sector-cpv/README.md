# Contratación pública española por sector (CPV): volumen e importe

Conjunto de datos abierto con el **número de contratos** y el **importe total licitado** en cada uno de los **43 sectores** (divisiones del Vocabulario Común de Contratos Públicos, CPV) de la contratación pública española.

Responde a: *"¿qué sectores mueven más contratación pública, en número y en dinero?"*.

- **Fuente primaria:** Plataforma de Contratación del Sector Público (PLACSP) — https://contrataciondelestado.es
- **Elaboración:** LicitaPilot — https://licitapilot.com
- **Licencia:** [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- **Fecha de corte:** 2026-09-23 · **Cobertura:** España

## Columnas

| Columna | Tipo | Descripción |
|---|---|---|
| `cpv_division` | texto | Código de la división CPV (2 dígitos). |
| `sector` | texto | Denominación oficial de la división CPV. |
| `num_contratos` | entero | Nº de licitaciones registradas en esa división. |
| `importe_total_eur` | decimal | Suma del presupuesto base de licitación (sin IVA), en euros. |

## Metodología

- Agregado de las licitaciones registradas en PLACSP por división CPV (los 2 primeros dígitos del código).
- `importe_total_eur` suma el presupuesto base de licitación; algunas licitaciones pueden no tener importe informado y no computan en el sumatorio.
- Importes sin IVA y según figuran en la plataforma. **Datos no auditados.**

## Cómo citar

> LicitaPilot (2026). *Contratación pública española por sector (CPV)*. Elaboración propia a partir de PLACSP. CC BY 4.0. https://licitapilot.com/mercado

## Más datos

Analíticas de mercado por sector y provincia en **[licitapilot.com/mercado](https://licitapilot.com/mercado)**.
