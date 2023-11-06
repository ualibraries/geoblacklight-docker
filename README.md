# Docker orchestration for UAL GOB (Geoblacklight) development

## Overview

This Docker orchestration runs a fully decoupled GeoBlacklight search service that uses a Blacklight (Ruby on Rails) application querying the Solr & ZooKeeper middleware "ensemble".

**How does it work? 30K ft view...**

Here's a little diagram of the GOB and Solr Cloud interaction (WIP learning Mermaid syntax):

```mermaid
  graph TD;
      App-->Query_Request;
      Query_Request-->Cloud_Solr;
      Cloud_Solr-->Zookeeper;
      Zookeeper-->Cloud_Solr;
      Cloud_Solr-->Response_Data_Object;
      Response_Data_Object-->App;
```

 The GOB app container queries the Solr instance directly. "Sharding" information is managed by the ZooKeeper middleware. Using the "blacklight-core" metadata, Solr sends back its data response in a format that can be ingested by RoR models. See the [Blacklight module directory](https://github.com/projectblacklight/blacklight/tree/main/lib/blacklight/solr) for Solr class implementations.

## Setup

### Necessary tools:

  - Computer (okay, sorry, it's Monday!)
  - Terminal access
  - Git
  - Docker, either Desktop or just the straight engine if deploying on any of the Linux distros

**Preliminary Steps:**

Start by cloning this repository to pretty much anywhere on most filesystems that the Docker daemon has access to. There may be filesystem permission issues for your user. Either find your user's UID and GID or ask another IT compadre if they know what the heck I'm talking about. Put those ids in the `.env` file at the root of the project, replacing the UID and GID, respectively. Then proceed to ...

**1. Build the UAL-GOB Docker images (for GOB and Solr containers):**

```shell
$ ./dbuild.sh
```

**2. Start or rebuild the Docker network:**

```shell
$ ./start-me-up.sh
```

The GOB app is installed automatically if it does not already exist. This will take a little while and the server is still not started. A list of dependencies should print out as the GOB is installed. All data that matters to the app is statefully preserved on the host machine in the `./app` directory. The GOB RoR app will be in `./app/app` (Yes, two apps for the price of one!)

Build scripts set up Apache ZooKeeper and Solr decoupled to propagate search configuration and data in "cloud mode". Search data is located in Docker volumes on startup.

**3. View the application and Solr admin:**

See the following URLs:

* `localhost:3000` for the GeoBlacklight application
* `localhost:8983` for the Solr admin (admin is locked down; see the .env file for creds)

## Optional application container commands

**Stop the Docker network:**

This is non-destructive. All containers remain stateful, as well as volumes and network.

```shell
$ ./start-me-up.sh pause
```

**Run Rake commands in the containerized application directory:**

```shell
$ docker exec -it gob-app bash -c -l './rake_command.sh "<command-to-run>"'

# Example - populate Solr test fixtures:
$ docker exec -it gob-app bash -c -l './rake_command.sh "geoblacklight:index:seed[:remote]"'
```

See Geoblacklight tasks [here](https://github.com/geoblacklight/geoblacklight/blob/main/lib/tasks/geoblacklight.rake).

- `:geoblacklight` main namespace for all commands.
  - `:server` Solr & Geoblacklight startup (which this repo doesn't use). This also installs some seed data.
  - `:webpack` Runs the app and Solr together in interactive mode with the `foreman` gem.
  - `:index` child name for running fixtures.
    - `:seed` by itself runs local fixtures (spec/fixtures/solr_documents).
      - `[:remote]` reaches out to the github repo (see below) to get fixtures.
    - `:ingest_all` Ingests a GeoHydra transformed.json.
    - `:ingest` default to ingest blacklight.json files from directory `data` in project root.
      - `[:directory]` to pass a directory path to ingest files.
  - `:downloads` stuff to do with downloading files.
    - `:delete` deletes cached downloads.
    - `:mkdir` create the cache directory, like bash.
    - `:precache` programmatically add cache files.
  - `:solr:seed` same as `geoblacklight:index:seed`
  - `:application_asset_paths` echoes out all asset paths, kinda handy.

**Inspect GOB application logs for development**

```shell
$ ./inspect-app-logs.sh
```

**Tear-down**

WARNING: This destroys _all_ data, meaning containers and volumes. (It does not remove Docker images, however.) The dialogue will ask if you want to clean up any untracked files. Usually there are generated files that are ignored by git. However, if you have added something and not committed, those files may be deleted permanently. Please take a good look at the list to avoid this.

```shell
$ ./destroy.sh
```

## Notes

* https://geoblacklight.org/tutorial/2015/02/09/create-your-application.html#install-geoblacklight
* https://github.com/geoblacklight/geoblacklight
* https://github.com/geobtaa/geoportal-solr-config
* https://github.com/projectblacklight/blacklight
* https://solr.apache.org/guide/solr/latest/deployment-guide/zookeeper-ensemble.html
* https://github.com/docker-solr/docker-solr/tree/master/scripts
* https://github.com/geoblacklight/geoblacklight/tree/main/spec/fixtures/solr_documents
* https://github.com/OpenGeoMetadata/edu.berkeley/blob/master/ark28722/s7/059k/geoblacklight.json (example geoblacklight.json file in GBL ver.1 schema)
* https://opengeometadata.org/ogm-aardvark/ (for GBL ver.2 schema)
* https://opengeometadata.org/aardvark-gbl-1-crosswalk/

## Helpful hints

* Software versions are controlled in `.env`, as are a few other important environment variables.

