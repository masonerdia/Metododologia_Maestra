---
title: Resolver null → creación lazy confirmada en flujo conversacional
date: 2026-06-23
source: Denti HOTFIX-0024
tags: [voz, asistente, ux, backend, saas, conversacional]
---

## Lección

Cuando un resolver de entidades (paciente, doctor, producto, cuenta) devuelve `null` porque la entidad no existe, NO terminar con un error terminal. En cambio, devolver `tipo: 'confirmar'` con una oferta de creación lazy: "No encontré a X. ¿Lo doy de alta y continúo?"

Al confirmar, una segunda acción atómica crea la entidad e inmediatamente ejecuta la operación original en una sola transacción.

## Por qué importa

Un flujo conversacional (voz o chat) que termina en "No encontré al profesional" obliga al usuario a salir del flujo, ir a otra pantalla, crear el registro, volver y repetir el comando. En mobile esto es cuatro taps y pérdida total del contexto. El usuario abandona o comete errores.

Además, los catálogos de referencia (doctores, productos, cuentas) en un negocio real siempre están incompletos al principio. Diseñar solo para el happy path "la entidad ya existe" crea fricciones permanentes durante el onboarding.

## Cómo aplicar

1. En la función `resolverX()`, cuando no hay match, devolver `{ tipo: 'confirmar', payload: { oferta: 'crear', nombre: inputUsuario } }` en lugar de `null` o error.
2. En el asistente, detectar `tipo === 'confirmar' && payload.oferta === 'crear'` y mostrar tarjeta: "¿Dar de alta a [nombre] y continuar?"
3. Al confirmar, llamar a `crearXYAgregarOperacion(datos)` que en una sola transacción:
   a. Inserta la entidad nueva.
   b. Re-valida cualquier conflicto (ver nota sobre re-validación con ID null).
   c. Ejecuta la operación original usando el ID recién generado.
4. En caso de error en la creación (duplicado, validación), devolver mensaje accionable y ofrecer reintento.
5. Guardar el `payload` de la oferta en el estado conversacional entre turnos para no perder el contexto.

**Anti-patrón a evitar:** devolver error terminal y pedirle al usuario que "primero cree el registro en configuración". Eso rompe el flujo y confunde en voice UX.
