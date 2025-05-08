# Documentacion de GLPI

## Tabla de Contenidos

1. [Instalación](#instalación)
2. [Crear una nueva cola de tickets](#crear-una-nueva-cola-de-tickets)
3. [Abrir una incidencia](#abrir-un-incidencia)
4. [Resolverla con otro usuario](#resolverla-con-otro-usuario)
5. [Registrar un item en el inventario](#registrar-un-item-en-el-inventario)

----------

## Instalación

```bash
git clone https://github.com/jmlcas/glpi
cd glpi
docker-compose up -d
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' #ContainerID
```

Elegimos Español (España)

<img src="./imagenes/idioma.png">

Aceptamos la licencia

<img src="./imagenes/licencia.png">

Le damos a instalar

<img src="./imagenes/instalacion.png">

Le damos a continiuar

<img src="./imagenes/dependencias.png">

Nos pedira la ip, el usuario y contraseña de la base de datos que obtenemos al ver el archivo `mariadb.env`

<img src="./imagenes/credenciales.png">

Nos conectaremos a la base de datos y la seleccionamos

<img src="./imagenes/conexion.png">

Le damos a continuar

<img src="./imagenes/instalaciondb.png">

No enviamos estadisticas de uso

<img src="./imagenes/recopilacion.png">

Le damos a continuar

<img src="./imagenes/continuar.png">

Acabamos dandole a Utilizar GLPI

<img src="./imagenes/instalado.png">

Acedemos a GLPI

<img src="./imagenes/iniciosesion.png">


-----------


## Crear una nueva cola de tickets

En Administración/Entidades le damos a Añadir

<img src="./imagenes/cola1.png">

Nos pedira un nombre y comentarios y ya lo tenemos creado

<img src="./imagenes/cola2.png">

---------------

## Abrir un incidencia

Vamos a Soporte/Peticiones y creamos una incidencia con los datos necesarios

<img src="./imagenes/incidencia1.png">

Luego lo editamos para asignarlo a otro usuario

<img src="./imagenes/incidencia2.png">


-----------


## Resolverla con otro usuario

Entramos como Tech y mandamos una peticion de que esta solucionado
<img src="./imagenes/tech1.png">

Desde el administrador aceptamos la peticion

<img src="./imagenes/tech2.png">


---------


## Registrar un item en el inventario

Vamos a activos y por ejemplo en Software añadimos los campos necesarios
<img src="./imagenes/inventario.png">

**Autor: Xavier Quintero Carrejo**