# Cloud Consulting

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

# Cloud Consulting - Final Project - Salesforce Bootcamp

Cloud Consulting es una empresa hipotética que se dedica a la implementación de proyectos de software.

Actualmente está en la búsqueda de un sistema que le permita gestionar dichos proyectos y salirse de los procesos manuales que hoy en día tienen a través de excels, documentos y repositorios que no se encuentran integrados ni automatizados.

## Funcionalidades requeridas
Las funcionalidades requeridas del proyecto están relacionadas con:

- El cierre de oportunidad.
- Alocación de recursos.
- Asignacion de tareas.
- Cargas de horas.


El objetivo es desarrollar un proyecto que involucre tanto la programación declarativa, como el desarrollo Backend y Frontend.

A continuación, describiremos en que consiste cada funcionalidad y mostraremos la solución de cada una de estas.

## Cierre de oportunidad
Cuando la oportunidad se cierra y la misma sea “Ganada”, se tiene que crear el proyecto con la información inicial que proviene desde la oportunidad:

- Cliente (Account).
- Cantidad de horas vendidas.
- Fecha inicio/fin del proyecto.
- Project Manager.
- Roles vendidos con cantidad de horas requeridas por rol.
- Oportunidad cerrada.
- Monto (Valor de la Oportunidad en Currency).

 El proyecto debe ser identificado con un estado “Pre-Kickoff”.

 ##  Alocación de recursos
Mientras el proyecto se encuentra en etapa de “pre-kickoff”, solo el Project Manager podrá asignar sus recursos al proyecto.

Para esto deberá contar con una interfaz que le muestre los recursos por rol, que fueron negociado para dicho proyecto, que estén disponibles en el rango de fechas en el que se desarollará el proyecto.

IMAGEN

Luego de asignar los recursos, las tablas por rol deberán refrescarse y actualizar los valores de horas en las cabeceras. 

**Importante:** un recurso no puede ser asignado en más de un proyecto a la vez para un cierto período de tiempo.

## Asignación de Tareas

Para llevar adelante el proyecto, es necesario que la herramienta permita gestionar las tareas que van a realizarse.

Debe ser posible asignar tareas a los recursos que están trabajando en un proyecto.

Dichas tareas deben ser creadas y asignadas por el que esté asignado como Squad Lead al proyecto, y por nadie más.

Dichas tareas deben contener:

- Recurso asignado.
- Proyecto.
- Resumen de la tarea a realizar.
- Descripción.
- Fecha inicio/Fin.
- Horas estimadas.
- Estado.

Algunas consideraciones:

1. Debe validarse que, al crear una tarea, la misma sea asignada a alguien que pertenezca al proyecto. Caso contrario, mostrará un error.

2. No se debe permitir asignar Tareas si el estado del proyecto es diferente a “En Progreso”.

3. Las tareas deben contemplar los estados “No Iniciada”, “En Progreso” y “Completada”.

4. El sistema no debe dejar pasar el proyecto a “Completado” en caso de que tenga tareas relacionadas con estado diferente de “Completada”.

## Carga de Horas

Se debe contar con una herramienta que les permita a los recursos ir cargando las horas trabajadas sobre cada una de las tareas que le hayan asignado.

Esta herramienta debe mostrar las tareas que la persona tenga asignadas, agrupadas por proyecto y ordenadas de forma ascendente por fecha de Inicio.

La herramienta deberá mostrar el listado de tareas con estados “No Iniciada” y “En Progreso” (Mostrar las “En Progreso” primero).

