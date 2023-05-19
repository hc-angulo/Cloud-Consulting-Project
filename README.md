# Cloud Consulting

Cloud Consulting es una empresa que se dedica a la implementación de proyectos de software.  Está en la búsqueda de un sistema que le permita gestionar dichos proyectos y salirse de los procesos manuales que hoy en día tienen a través de excels, documentos y repositorios que no se encuentran integrados ni automatizados.

## Funcionalidades requeridas
Las funcionalidades requeridas para solucionar las necesidades de _Cloud Consulting_ están relacionadas con las siguientes:

- [1. El cierre de oportunidad](#item1)
- [2. Alocación de recursos](#item2)
- [3. Asignacion de tareas](#item3)
- [4. Cargas de horas](#item4)
- [5. Demo](#item5)
- [6. Módelo de Datos](#item6)


El objetivo es desarrollar una aplicación que involucre programación declarativa, desarrollo Backend y Frontend.

A continuación, describiremos en que consiste cada funcionalidad y mostraremos la solución de cada una de estas.

<a name="item1"></a>
### Cierre de oportunidad
Cuando la oportunidad se cierra y la misma sea “Ganada”, se tiene que crear el proyecto con la información inicial que proviene desde la oportunidad:

- Cliente (Account).
- Cantidad de horas vendidas.
- Fecha inicio/fin del proyecto.
- Project Manager.
- Roles vendidos con cantidad de horas requeridas por rol.
- Oportunidad cerrada.
- Monto (Valor de la Oportunidad en Currency).

 El proyecto debe ser identificado con un estado “Pre-Kickoff”.
 
 **Herramientas:** Programación Declarativa.

<a name="item2"></a>
###  Alocación de recursos
 
 Para desarrollar esta funcionalidad, se tuvieron las siguientes consideraciones:
 
 - Mientras el proyecto se encuentra en etapa de “pre-kickoff”, solo el _Project Manager_ podrá asignar los recursos al proyecto.
 - Desplegar una interfaz que liste los recursos por rol (Arquitect, Consultant, Developer), negociados para dicho proyecto, que estén disponibles en el rango de fechas en el que se desarolla el proyecto.
 - Los encabezados de las tablas que almacenan recursos por rol deben reflejar las horas que fueron negociadas por cada rol. Estas deben actualizarse automáticamente al seleccionar los recursos de dichas tablas. Se estableció la equivalencia de 1 día igual 8 horas.
- Una vez seleccionado un recurso, la interfaz debe permitir eliminar cualquier recursos que haya sido seleccionado previamente. Si un recurso es eliminado, este debe aparecer nuevamente desplegado en la lista de recursos disponibles.
- Desde la Interfaz se debe permitir la asignación del Rol _Squad Lead_ a algún recurso que haya sido seleccionado previamente para trabajar en dicho proyecto.
- Un recurso no puede ser asignado en más de un proyecto a la vez para un cierto período de tiempo.
- Se debe permitir realizar la selección de recursos directamente desde la base de datos, es decir, sin uso de interfaz pero respetando el inciso anterior, un recurso no puede ser asignado en un proyecto si para la fecha que se desee asignar en dicho proyecto ya la tiene comprometida en otro proyecto. En caso de fallar con esta indicación, se debe mostrar un mensaje de advertencia y no puede permitir almacenar la selección del recurso en la base de datos.

**Herramientas:** Programación Declarativa, APEX, LWC.

<a name="item3"></a>
### Asignación de Tareas

Para llevar adelante el proyecto, es necesario que la herramienta permita gestionar las tareas que van a realizarse.

- Debe ser posible asignar tareas a los recursos que están trabajando en un proyecto.
- Dichas tareas deben ser creadas y asignadas por el que esté asignado como Squad Lead al proyecto, y por nadie más.
- Dichas tareas deben contener:

  - Recurso asignado.
  - Proyecto.
  - Resumen de la tarea a realizar.
  - Descripción.
  - Fecha inicio/Fin.
  - Horas estimadas.
  - Estado.

- Debe validarse que, al crear una tarea, la misma sea asignada a alguien que pertenezca al proyecto. Caso contrario, mostrará un error.
- Las tareas deben contemplar los estados “No Iniciada”, “En Progreso” y “Completada”.

**Herramientas:** Programación Declarativa, APEX, LWC.

<a name="item4"></a>
### Carga de Horas
Para desarrollar esta funcionalidad, se tuvieron las siguientes consideraciones:

- Contar con una interfaz que les permita a los recursos ir cargando las horas trabajadas sobre cada una de las tareas que le hayan asignado.
- Esta herramienta debe mostrar las tareas que la persona tenga asignadas, agrupadas por proyecto y ordenadas de forma ascendente por fecha de Inicio.
-La herramienta deberá mostrar el listado de tareas con estados “No Iniciada” y “En Progreso” (Mostrar las “En Progreso” primero).

**Herramientas:** APEX, LWC.
<a name="item5"></a>
### Demo
<a name="item6"></a>
### Módelo de Datos
![Sin título](https://github.com/Hilicarolina/Cloud-Consulting-Project/assets/14808063/2faf27d9-554c-4c82-9006-171bd67d8b88)



