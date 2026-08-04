# Multiusuario Design

Fecha: 2026-07-04
Proyecto: `multy_app`
Estado: Draft aprobado a nivel producto, pendiente de plan de implementación

## Objetivo

Agregar soporte multiusuario para que varios niños puedan usar la app en el mismo dispositivo con progreso, métricas, historial y preferencias separadas.

Además, conservar compatibilidad con los datos actuales migrándolos a un perfil persistente por defecto, e incorporar un modo `Invitado` temporal sin persistencia de progreso.

## Alcance de esta fase

- Soporte para hasta `4` perfiles persistentes.
- Selector de perfil en `home` antes de iniciar estudio o quiz.
- Pantalla de gestión de perfiles dentro de `settings`.
- Perfil `Invitado` temporal.
- Métricas acumuladas por perfil.
- Historial de sesiones por intento individual.
- Preparación de diseño para PIN por perfil en una fase futura.

## Decisiones de producto ya validadas

- Cada niño debe elegir su perfil antes de estudiar.
- Debe existir un perfil `Invitado`.
- `Invitado` no conserva progreso ni métricas al salir o cambiar de perfil.
- Los perfiles persistentes deben poder crearse, editarse, archivarse y borrarse definitivamente.
- Archivar debe ser la acción recomendada; borrar definitivamente debe requerir una confirmación más fuerte.
- Las métricas deben incluir acumulado e historial.
- El historial se guarda por intento individual.
- La UI puede mostrar promedios y resúmenes calculados a partir de ese historial.
- El límite inicial de perfiles persistentes será `4`.
- Por ahora no habrá PIN, pero debe quedar contemplado como mejora futura.

## Enfoque recomendado

Se implementará un modelo de perfiles completos, no una simple separación de estadísticas.

Esto permite cubrir necesidades actuales:

- nombre
- avatar
- color
- metas
- tablas favoritas
- historial
- métricas acumuladas

Y evita rehacer almacenamiento y UI cuando se agregue seguridad o personalización más adelante.

## Modelo de datos

### 1. `Profile`

Nueva entidad persistente para representar un perfil infantil.

Campos propuestos:

- `id`
- `name`
- `avatarKey`
- `colorValue`
- `goalDailySessions`
- `goalWeeklySessions`
- `favoriteTables`
- `isArchived`
- `createdAt`
- `updatedAt`

Notas:

- `favoriteTables` puede almacenarse inicialmente como lista serializada simple o estructura equivalente compatible con el stack actual.
- `avatarKey` debe representar una opción controlada por la app, no una ruta arbitraria.
- `colorValue` permitirá diferenciar visualmente cada perfil en el selector y pantallas relacionadas.

### 2. `ActiveProfile`

Estado de aplicación que representa el perfil actualmente seleccionado.

Campos/estado sugeridos:

- `selectedProfileId` persistido localmente para recordar la última selección persistente
- representación especial para `guest`

Notas:

- Aunque se recuerde el último perfil persistente, el flujo principal sigue siendo elegir perfil antes de estudiar.
- El valor persistido sirve para mejorar la UX y preseleccionar el último perfil usado.

### 3. `GuestSession`

No debe persistirse como perfil normal dentro de la base de datos principal de progreso.

Características:

- vive en memoria o en una capa temporal de sesión
- no guarda intentos, estadísticas ni preferencias al terminar
- puede reutilizar componentes de UI de perfil con una identidad especial `guest`

### 4. `QuizAttemp`

Entidad existente que debe ampliarse para pertenecer a un perfil.

Campo nuevo propuesto:

- `profileId`

Comportamiento:

- cada intento persistente queda asociado a un perfil
- los intentos de `Invitado` no se escriben en almacenamiento persistente

### 5. `TableOverallStats`

Entidad existente que debe ampliarse para pertenecer a un perfil.

Campos nuevos propuestos:

- `profileId`
- índice compuesto lógico por `profileId + tableNumber`

Comportamiento:

- las estadísticas dejan de ser globales
- cada perfil mantiene sus métricas agregadas por tabla

## Migración de datos

La app actualmente maneja métricas globales. En esta fase esas métricas se reinterpretarán como pertenecientes al perfil persistente por defecto.

### Estrategia de migración

1. Crear un perfil persistente inicial por defecto durante la migración.
2. Asociar todos los `QuizAttemp` existentes a ese perfil.
3. Asociar todas las `TableOverallStats` existentes a ese perfil.
4. Marcar este perfil como el primer perfil utilizable por el usuario.
5. Mantener la app funcional incluso si la migración encuentra datos parciales o estructuras vacías.

### Nombre del perfil migrado

Propuesta:

- `Perfil 1`

Alternativas válidas:

- `Mi perfil`
- un nombre localizado equivalente

Recomendación:

- usar un nombre neutro localizado, por ejemplo `Mi perfil`, para que no parezca técnico.

## Arquitectura de estado

Se recomienda separar responsabilidades en lugar de ampliar demasiado el provider actual.

### Providers/estado sugeridos

- `ProfileProvider`
  - listar perfiles activos
  - crear, editar, archivar, borrar definitivamente
  - validar límite de 4 perfiles
  - resolver perfil activo o invitado

- `QuizAttempProvider`
  - guardar intentos por perfil
  - cargar historial del perfil activo
  - recalcular estadísticas del perfil activo

- `GuestSessionProvider` o soporte dentro de `ProfileProvider`
  - manejar selección temporal de invitado
  - limpiar datos temporales al abandonar la sesión invitada

## Flujo de usuario

### Home

El `home` debe incorporar un widget de selección de perfil visible antes de las acciones principales.

Comportamiento esperado:

- mostrar perfil activo actual
- permitir cambiar entre perfiles persistentes
- mostrar opción `Invitado`
- impedir iniciar estudio o quiz sin una selección explícita en la sesión actual
- usar color/avatar del perfil seleccionado para reforzar identidad

### Study y Quiz

Antes de iniciar:

- usar el perfil activo seleccionado en `home`

Durante la sesión:

- registrar intentos persistentes solo si el perfil no es `Invitado`

Al terminar:

- mostrar métricas de la sesión actual
- permitir revisar detalle individual del intento
- actualizar acumulados solo para perfiles persistentes

### Stats

La pantalla de estadísticas debe pasar de global a contextual por perfil.

Contenido sugerido:

- resumen acumulado del perfil activo
- estadísticas por tabla del perfil activo
- historial individual de sesiones
- capacidad futura de filtros por fecha o tabla

### Settings

Debe agregarse una sección o pantalla de perfiles con estas capacidades:

- listar perfiles persistentes activos
- crear perfil
- editar perfil
- archivar perfil
- borrar definitivamente perfil archivado o perfil seleccionado con confirmación reforzada

Reglas:

- no permitir crear más de 4 perfiles persistentes
- no permitir borrar el único perfil persistente disponible sin crear otro o sin migrar a un estado válido
- si se archiva el perfil activo, pedir selección de otro perfil activo

## UI propuesta

### Widget selector de perfiles en Home

Formato sugerido:

- carrusel horizontal o lista compacta de chips/tarjetas
- cada perfil con avatar, nombre y color
- `Invitado` como opción separada y claramente temporal

Recomendación:

- usar tarjetas compactas en horizontal para que la selección sea muy evidente y amigable para niños

### Gestión de perfiles en Settings

Estructura sugerida:

- bloque `Perfiles`
- lista de perfiles con acciones rápidas
- CTA para `Crear perfil`
- pantalla o modal para edición

Campos editables:

- nombre
- avatar
- color
- metas
- tablas favoritas

## Reglas de negocio

- máximo `4` perfiles persistentes
- `Invitado` no cuenta dentro del límite
- `Invitado` no persiste historial ni métricas
- archivar preserva todo el progreso del perfil
- borrar definitivamente elimina perfil, intentos, estadísticas y preferencias asociadas
- las estadísticas mostradas en `stats` siempre corresponden al perfil activo
- el historial persistente se guarda por intento individual
- los promedios y resúmenes se calculan a partir del historial y/o agregados por tabla

## Manejo de errores y casos límite

- si no existen perfiles persistentes tras una limpieza, crear uno inicial guiado
- si el perfil activo fue archivado o eliminado, redirigir a selección de perfil
- si una migración queda incompleta, priorizar no perder intentos históricos
- si el usuario intenta crear un quinto perfil, mostrar mensaje claro con límite alcanzado
- si se cambia a `Invitado`, limpiar cualquier estado temporal previo de invitado

## Testing esperado

### Datos/migración

- migración de intentos existentes hacia perfil por defecto
- migración de estadísticas existentes hacia perfil por defecto
- compatibilidad con base vacía

### Reglas de perfiles

- creación hasta el límite de 4
- edición de nombre/avatar/color/metas/favoritas
- archivado correcto
- borrado definitivo y limpieza asociada

### Flujo invitado

- selección de `Invitado`
- estudio/quiz sin persistencia
- limpieza al abandonar sesión invitada

### Métricas e historial

- guardado de intentos por perfil persistente
- cálculo de acumulados por perfil
- aislamiento total entre perfiles
- render correcto de historial individual

## Riesgos y mitigaciones

### Riesgo 1: migración de datos

Las entidades actuales no están separadas por perfil.

Mitigación:

- introducir migración explícita y testeable
- usar perfil por defecto localizado
- evitar borrar o recalcular a ciegas sin asociar datos previos

### Riesgo 2: complejidad en provider actual

El provider de métricas actual mezcla acceso a datos y agregación.

Mitigación:

- separar manejo de perfiles y manejo de intentos
- encapsular contexto de perfil activo

### Riesgo 3: UX confusa para niños

Si la selección de perfil queda escondida, el objetivo multiusuario se debilita.

Mitigación:

- hacer la selección visible en `home`
- resaltar perfil activo antes de mostrar acciones de estudio

## Fase futura: PIN por perfil

No se implementa en esta fase, pero debe considerarse desde ahora.

### Objetivo

Evitar que un niño entre accidentalmente al perfil del otro manteniendo una experiencia simple.

### Diseño futuro sugerido

- campo opcional `pinHash` o equivalente en `Profile`
- toggle `PIN activado`
- solicitud de PIN al cambiar a un perfil protegido
- opción para que el adulto gestione o restablezca el PIN

### Consideraciones UX

- el PIN debe ser opcional, no obligatorio
- debe poder activarse por perfil
- `Invitado` no requiere PIN
- la app debe seguir siendo rápida para entrar a estudiar

## Fase futura: mejoras adicionales

- recuperar perfiles archivados
- dashboard comparativo entre perfiles
- metas semanales más ricas
- streaks o rachas por perfil
- filtros del historial por tabla o fecha
- badges o recompensas por perfil

## Resumen

La app debe evolucionar de un modelo global a un modelo centrado en perfiles. El corazón de la solución es:

- perfiles persistentes completos
- invitado temporal
- métricas por perfil
- historial individual por intento
- selección de perfil en `home`
- gestión de perfiles en `settings`
- migración segura de datos actuales a un perfil por defecto

Esta base deja preparada la app para personalización y seguridad futura sin obligar a rehacer almacenamiento ni navegación más adelante.
