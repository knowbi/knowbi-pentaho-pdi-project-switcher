project_switcher
================

In this repository you can find the project switcher scripts to easily change from projects or environments in kettle.
When working with PDI on a project, or as a consultant on multiple projects you often have to switch your configuration files, or in my case… remember what kettle version the client was actually using.

To solve this problem we created a startup script (both for linux and windows) and an organised file structure to easily switch from one project to another.

Filestructure:
* Kettle
  * pdi_4.8
  * pdi_5.0
  * pdi_5.2CE
  * pdi_5.2EE
* client1
  * project1
  * project2
  * project3
* client2
  * dev
  * test
  * prod

There is a Kettle folder containing all different version that are currently in use (CE,EE) and there are project folders. The script is created to be able to go 2 levels deep, level one are the projects/customers you are working on and on the second level are environments (DEV1,DEV2,ACC,…).
On the lowest level we add the configuration files needed to switch from one project to another.

    config.cfg
    jdbc.default
    a pwd folder

The config.cfg file contains one key value pair this specifies where it has to go in the kettle folder. For each version of data-integration I created a folder with the version number. As you can see in the first screenshot I added the kettle versions I currently use for my projects and gave them a easy name without spaces.

The script changes your kettle home folder to the project folders. After using your new project for the first time you will see a .kettle folder in the project folder. there you can find the kettle.properties file for this specific project. the JDBC connection information is copied from your project folder to the specified kettle folder the same is done with the pwd folder which holds your carte information.
