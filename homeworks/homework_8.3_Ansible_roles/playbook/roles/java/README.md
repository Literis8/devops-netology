Java
=========

Simple role to install openjdk from remote or any jdk in local.

Role Variables
--------------

| Variable name | Default | Description |
|--------------|-----------------------------|------------------------------------------------|
| jdk_distr_type | remote | Define type of distr. Possible value: remote, local |
| jdk_url | "{{ openjdk[11] }}" | Need to set only when `jdk_distr_type` set to remote. This vaiable use dict from `/vars/main.yml` |
| jdk_distr_name | openjdk-11-linux.tar.gz | Name of destination archive |
| jdk_folder | "{{ jdk_distr_name.split('-')[:2] | join('-')  }}" | Name of directory to unarchive. By default it used jinja template from archive name |
| java_home | "/opt/jdk/{{ jdk_folder }}" | Specify JAVA_HOME environment |

Example Playbook
----------------

```yaml
- hosts: all
  roles:
      - mnt-homeworks-ansible
```
Or, if you specify rolename to java:
```yaml
- hosts: all
  roles:
      - java
```

License
-------

BSD

Author Information
------------------

Alexey Metlyakov
