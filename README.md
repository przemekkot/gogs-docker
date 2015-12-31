# Gogs Docker Image

Openshift compatible Docker image for Gogs without SSH access.

## Configuration

Gogs does not seem to support configuration through the UI. Basic
configuration is implemented using [env parameters](#env-parameters) and
is therefore quite limited. The template used to generate the config on
startup is stored on the volume making it possible to edit the
configuration.

To edit the configuration:

* Edit `/gogs/volume/gogs/app.ini.template`
* Bounce the container

Any env parameter configured fields can be overwritten as necessary. The
original config template can be restored by removing the original
config.

To restore configuration:

* Run on host

```bash
docker exec -it <container> bash
rm /gogs/volume/gogs/app.ini.template
```

* Bounce the container

## Env Parameters

* `GOGS_DB_TYPE`: Database adapter type. `sqlite3`, `mysql` or
  `postgres`. (Default: `sqlite3`)
* `GOGS_DB_HOST`: Database host. (Default: `127.0.0.1:3306` Applies to db types: `mysql`, `postgres`.)
* `GOGS_DB_NAME`: Database name. (Default: `gogs`. Applies to db types: `mysql`, `postgres`.)
* `GOGS_DB_USER`: Username used to access database. (Default: `user`. Applies to db types: `mysql`, `postgres`.)
* `GOGS_DB_PASSWORD`: Password used to access database. (Default: `test`. Applies to db types: `mysql`, `postgres`.)
* `GOGS_DB_ROOT_PASSWORD`: Root password used when creating database. (Default: `""`. Applies to db types: `mysql`. )
* `GOGS_SECRET_KEY`: CSRF prevention secret. (Default: Generated
  random string)

## Persist Data

There is an exposed volume at `/gogs/volume` that is used to store any
data that should be persisted.

## Inital Setup

Initial setup in Docker is a PITA. Gogs does not allow creating a default
admin user through configuration or any other medium accessible by
simple scripts. Injecting the user using direct database access is not
a feasible solution.

As a last resort-ish solution creating new accounts without email
confirmation is enabled by default. After the first user is created the
account creation should be disabled.

